; Bank 1 at $4B7B. FinishYStepAfterCameraNudge calls here when the
; vertical step at $C6D3 is zero. $4CBF, still INCBIN, points HL at the
; map cell one row below the object and selects WRAM bank 5.
;
; Bit 0 of $C9A4 is the A button in the pressed-button copy FinishFrame
; writes from wButtonsPressed. When that bit is clear this returns, and
; the caller continues at $51B6. When it is set, `pop af` drops that
; return address. Bit 2 of $FFAA is set, and E becomes the cell byte at
; HL in WRAM bank 5.
;
; A cell of $0B needs the byte at $C9A6 to be at least 2. It plants
; hScriptPtr with $5609 and jumps to StampMapCellInWramBanks. A cell of
; $09 needs $C9A6 to be at least 1. It plants hScriptPtr with $55BD and
; jumps to $5DA2. A short count, a cell whose high three bits are clear,
; or a cell with bit 7 set jumps to $5D9B. Any other cell with bit 5 or
; bit 6 set jumps to $4B61. Those three addresses are still INCBIN.
;
; hScriptPtr is the name from reset.asm. The A-button bit is the name
; from read_joypad.asm. FinishFrame copies wButtonsPressed to $C9A4.
; What $C9A6 counts is still unknown. The stores to hScriptPtr are the
; 3-byte form.

; Cell bytes that plant a script pointer. Both are compared with `cp`.
DEF CELL_BELOW_STAMP EQU $0B
DEF CELL_BELOW_TAIL EQU $09

; Minimum value of $C9A6 for each of those cells. The test is `sub`.
DEF CELL_BELOW_STAMP_MIN EQU $02
DEF CELL_BELOW_TAIL_MIN EQU $01

; Little-endian script pointers planted at hScriptPtr.
DEF CellBelowStampScript EQU $5609
DEF CellBelowTailScript EQU $55BD

; High three bits of the cell. Bit 7 leaves for $5D9B. Bit 5 or bit 6
; leaves for $4B61. None of them also leaves for $5D9B.
DEF CELL_BELOW_HIGH_BITS EQU $E0

DispatchCellBelowOnButtonA::
    call PointAtCellOneRowDown
    ld a, [$c9a4]
    bit 0, a
    ret z

    pop af
    ldh a, [$ffaa]
    set 2, a
    ldh [$ffaa], a
    ld a, [hl]
    ld e, a
    cp CELL_BELOW_STAMP
    jr nz, .notStamp

    ld a, [$c9a6]
    sub CELL_BELOW_STAMP_MIN
    jp c, CommitScriptRecord

    ld a, LOW(CellBelowStampScript)
    ld [hScriptPtr], a
    ld a, HIGH(CellBelowStampScript)
    ld [hScriptPtr + 1], a
    jp StampMapCellInWramBanks

.notStamp:
    cp CELL_BELOW_TAIL
    jr nz, .highBits

    ld a, [$c9a6]
    sub CELL_BELOW_TAIL_MIN
    jp c, CommitScriptRecord

    ld a, LOW(CellBelowTailScript)
    ld [hScriptPtr], a
    ld a, HIGH(CellBelowTailScript)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord

.highBits:
    and CELL_BELOW_HIGH_BITS
    jp z, CommitScriptRecord

    bit 7, a
    jp nz, CommitScriptRecord

    jp SaveCellBelowAndStageThirdScript
