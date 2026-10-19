; Bank 1 at $4BCC. ResumeLeftWhileDownRecord calls here when the X
; step at wClearedOnRecordLoad ($C6D2) is zero. ResumeLeftHeldRecord
; calls here after StepCell82EveryFourthFrame.
; PointAtCellOneColumnLeft points HL at the map cell one column left
; and selects WRAM bank 5.
;
; Bit 0 of $C9A4 is the A button in the pressed-button copy FinishFrame
; writes from wButtonsPressed. When that bit is clear this returns, and
; the caller continues. When it is set, `pop af` drops that return
; address. Bit 2 of $FFAA is set, and E becomes the cell byte at HL in
; WRAM bank 5.
;
; A cell of $0B needs the byte at $C9A6 to be at least 2. It plants
; hScriptPtr with $562F and jumps to StampMapCellInWramBanks. A cell of
; $09 needs $C9A6 to be at least 1. It plants hScriptPtr with $554B and
; jumps to PlantHandlerAndHeadWord. A short count, a cell whose high
; three bits are clear, or a cell with bit 7 set jumps to
; CommitScriptRecord. Any other cell with bit 5 or bit 6 set jumps to
; SaveCellBelowAndStageThirdScript. $562F and $554B are still INCBIN.
;
; hScriptPtr is the name from reset.asm. The A-button bit is the name
; from read_joypad.asm. FinishFrame copies wButtonsPressed to $C9A4.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; What $C9A6 counts is still unknown. The stores to hScriptPtr are the
; 3-byte form. CommitScriptAndRecordHead is the EQU in
; plant_handler_and_head_word.asm.

; Cell bytes that plant a script pointer. Both are compared with `cp`.
DEF CELL_LEFT_STAMP EQU $0B
DEF CELL_LEFT_TAIL EQU $09

; Minimum value of $C9A6 for each of those cells. The test is `sub`.
DEF CELL_LEFT_STAMP_MIN EQU $02
DEF CELL_LEFT_TAIL_MIN EQU $01

; Little-endian script pointers planted at hScriptPtr. Both still INCBIN.
DEF CellLeftStampScript EQU $562F
DEF CellLeftTailScript EQU $554B

; High three bits of the cell. Bit 7 leaves for CommitScriptRecord.
; Bit 5 or bit 6 leaves for SaveCellBelowAndStageThirdScript. None of
; them also leaves for CommitScriptRecord.
DEF CELL_LEFT_HIGH_BITS EQU $E0

DispatchCellLeftOnButtonA::
    call PointAtCellOneColumnLeft
    ld a, [$c9a4]
    bit 0, a
    ret z

    pop af
    ldh a, [$ffaa]
    set 2, a
    ldh [$ffaa], a
    ld a, [hl]
    ld e, a
    cp CELL_LEFT_STAMP
    jr nz, .notStamp

    ld a, [$c9a6]
    sub CELL_LEFT_STAMP_MIN
    jp c, CommitScriptAndRecordHead

    ld a, LOW(CellLeftStampScript)
    ld [hScriptPtr], a
    ld a, HIGH(CellLeftStampScript)
    ld [hScriptPtr + 1], a
    jp StampMapCellInWramBanks

.notStamp:
    cp CELL_LEFT_TAIL
    jr nz, .highBits

    ld a, [$c9a6]
    sub CELL_LEFT_TAIL_MIN
    jp c, CommitScriptAndRecordHead

    ld a, LOW(CellLeftTailScript)
    ld [hScriptPtr], a
    ld a, HIGH(CellLeftTailScript)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord

.highBits:
    and CELL_LEFT_HIGH_BITS
    jp z, CommitScriptAndRecordHead

    bit 7, a
    jp nz, CommitScriptAndRecordHead

    jp SaveCellBelowAndStageThirdScript
