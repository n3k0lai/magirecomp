; Bank 1 at $4C6E. ResumeOtherLeftCellScript calls here when the Y
; step at wClearedOnRecordLoad + 1 ($C6D3) is zero. Other zero-Y-step
; paths in this bank call it the same way. PointAtCellOneRowUp points
; HL at the map cell one row above the object and selects WRAM bank 5.
; rROMB0 is left alone.
;
; Bit 0 of $C9A4 is the A button in the pressed-button copy FinishFrame
; writes from wButtonsPressed. When that bit is clear this returns, and
; the caller continues. When it is set, `pop af` drops that return
; address. Bit 2 of $FFAA is set, and E becomes the cell byte at HL in
; WRAM bank 5.
;
; A cell of $0B needs the byte at $C9A6 to be at least 2. It plants
; hScriptPtr with $55E3 and jumps to StampMapCellInWramBanks. A cell of
; $09 needs $C9A6 to be at least 1. It plants hScriptPtr with $5597 and
; jumps to PlantHandlerAndHeadWord. A short count, a cell whose high
; three bits are clear, or a cell with bit 7 set jumps to
; CommitScriptAndRecordHead. Any other cell with bit 5 or bit 6 set
; jumps to SaveCellBelowAndStageThirdScript. $55E3 falls inside
; ResumeRightWhileDownRecord. $5597 falls inside
; ResumeLeftWhileDownRecord.
;
; hScriptPtr is the name from reset.asm. The A-button bit is the name
; from read_joypad.asm. FinishFrame copies wButtonsPressed to $C9A4.
; What $C9A6 counts is still unknown. The stores to hScriptPtr are the
; 3-byte form. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm. wClearedOnRecordLoad is the name
; from load_record_head.asm.

; Cell bytes that plant a script pointer. Both are compared with `cp`.
DEF CELL_ABOVE_STAMP EQU $0B
DEF CELL_ABOVE_TAIL EQU $09

; Minimum value of $C9A6 for each of those cells. The test is `sub`.
DEF CELL_ABOVE_STAMP_MIN EQU $02
DEF CELL_ABOVE_TAIL_MIN EQU $01

; Little-endian script pointers planted at hScriptPtr.
DEF CellAboveStampScript EQU $55E3
DEF CellAboveTailScript EQU $5597

; High three bits of the cell. Bit 7 leaves for CommitScriptAndRecordHead.
; Bit 5 or bit 6 leaves for SaveCellBelowAndStageThirdScript. None of
; them also leaves for CommitScriptAndRecordHead.
DEF CELL_ABOVE_HIGH_BITS EQU $E0

DispatchCellAboveOnButtonA::
    call PointAtCellOneRowUp
    ld a, [$c9a4]
    bit 0, a
    ret z

    pop af
    ldh a, [$ffaa]
    set 2, a
    ldh [$ffaa], a
    ld a, [hl]
    ld e, a
    cp CELL_ABOVE_STAMP
    jr nz, .notStamp

    ld a, [$c9a6]
    sub CELL_ABOVE_STAMP_MIN
    jp c, CommitScriptAndRecordHead

    ld a, LOW(CellAboveStampScript)
    ld [hScriptPtr], a
    ld a, HIGH(CellAboveStampScript)
    ld [hScriptPtr + 1], a
    jp StampMapCellInWramBanks

.notStamp:
    cp CELL_ABOVE_TAIL
    jr nz, .highBits

    ld a, [$c9a6]
    sub CELL_ABOVE_TAIL_MIN
    jp c, CommitScriptAndRecordHead

    ld a, LOW(CellAboveTailScript)
    ld [hScriptPtr], a
    ld a, HIGH(CellAboveTailScript)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord

.highBits:
    and CELL_ABOVE_HIGH_BITS
    jp z, CommitScriptAndRecordHead

    bit 7, a
    jp nz, CommitScriptAndRecordHead

    jp SaveCellBelowAndStageThirdScript
