; Bank 3 at $58CB. StageWindowTilesArmSlot jumps here after the window
; tiles are staged, the slot is armed, and the LCD is on. This bank stays
; mapped. The routine does not write rROMB0.
;
; Each pass calls bank 3 at $415D, then RefreshFrame, and reads $CCA7.
; $FF sends it back to the top. Any other value is saved at $CD74.
;
; Zero, and $08, turn the LCD off, reload the seven choice pairs, and
; paint the indexed rows. The slot is armed again with table index 7,
; mark $F3, and id 1. $CCB6 points at $CC4D. $CCB0 and $CCB2 both hold
; $42E3. $CCB9 and $CCBA are 0, written with the immediate form, so
; LoadArmedSlotRecord returns before ReloadSlotPosition. $CCA7 is set
; back to $FF, TurnOnLCDIfOff runs, and control returns to the top.
;
; $FE leaves through $567B. Any other value calls $5BC3 and reads $CD69.
; Zero jumps to the tail that arms the same block but stores $CD81 back
; onto itself, then loops. $03 falls into the saved-choice arm. $01 calls
; $64B1 first. Anything else leaves through $567B.
;
; The saved-choice arm uses [$CD74] as the slot id, calls $565B, then
; LoadArmedSlotRecord, and sets $CCA7 to $FF. Two strip blocks follow.
; Both point $C93D at $C949 and store 1 at $C6EB. The tile pointer is
; written at $C6E9 and again at $C941. The map cell is $9DA1, then $9DC1,
; the two rows PaintWindowIndexedRows filled with ascending tiles. The
; first tile of each row is stored at $C944 and $C946, $8F sits between
; them at $C945, and the tile just past the row is stored at $C947.
; $C93B points at $48C5, then $48D6. The pass count is the row length
; plus one: $11 becomes $12, and $0F becomes $10, via `inc a`. $C939
; points at $2B8F. Bank 3 at $4260 runs after each block. Control then
; returns to the top.
;
; wCurrentWRAMBank is the name from timer_overflow.asm. CallBankedHL,
; RefreshFrame, TurnOffLCD, LoadPagedSRAMChoicePairs,
; PaintWindowIndexedRows, LoadArmedSlotRecord, and TurnOnLCDIfOff are
; already source. $415D, $4260, $565B, $567B, $5BC3, and $64B1 are still
; INCBIN. $CCB4 is the table index LoadArmedSlotRecord reads.

; Still INCBIN in this bank.
DEF Bank3_415D EQU $415D
DEF Bank3_565B EQU $565B

DEF WIN_BANK EQU $03
DEF WIN_CHOICE EQU $CCA7
DEF WIN_CHOICE_WAIT EQU $FF
DEF WIN_CHOICE_SAVED EQU $CD74
DEF WIN_CHOICE_EIGHT EQU $08
DEF WIN_CHOICE_CANCEL EQU $FE
DEF WIN_RESULT EQU $CD69
DEF WIN_RESULT_NONE EQU $00
DEF WIN_RESULT_ONE EQU $01
DEF WIN_RESULT_THREE EQU $03

DEF WIN_SLOT_INDEX EQU $07
DEF WIN_SLOT_MARK EQU $F3
DEF WIN_SLOT_PTR EQU $CC4D
DEF WIN_SLOT_ID EQU $01
DEF WIN_SLOT_INDEX_ADDR EQU $CD81

; Strip block planted for $4260. $C949 is the text buffer later files
; call wListTailDest. $2B8F is the strip routine those files call.
DEF WIN_TEXT_BUF EQU $C949
DEF WIN_STRIP_FLAG EQU $C6EB
DEF WIN_STRIP_FLAG_ON EQU $01
DEF WIN_TILE_PTR EQU $C6E9
DEF WIN_TILE_PTR_ECHO EQU $C941
DEF WIN_MAP_CELL EQU $C93F
DEF WIN_MAP_ROW_1 EQU $9DA1
DEF WIN_MAP_ROW_2 EQU $9DC1
DEF WIN_TILE_LO EQU $C944
DEF WIN_TILE_LO_COPY EQU $C946
DEF WIN_TILE_MID EQU $C945
DEF WIN_TILE_MID_VAL EQU $8F
DEF WIN_TILE_HI EQU $C947
DEF WIN_STRIP_TEXT EQU $C93B
DEF WIN_TEXT_1 EQU $48C5
DEF WIN_TEXT_2 EQU $48D6
DEF WIN_STRIP_PASSES EQU $CCB5
DEF WIN_ROW_1_COUNT EQU $11
DEF WIN_ROW_2_COUNT EQU $0F
DEF WIN_STRIP_ROUTINE EQU $C939
DEF WIN_STRIP_FN EQU $2B8F
DEF WIN_ROW_1_TILE EQU $8DD0
DEF WIN_ROW_1_LO EQU $DD
DEF WIN_ROW_1_HI EQU $EE
DEF WIN_ROW_2_TILE EQU $8EE0
DEF WIN_ROW_2_LO EQU $EE
DEF WIN_ROW_2_HI EQU $FD

MACRO arm_window_slot
    ld a, WIN_SLOT_INDEX
    ld [$CCB4], a
    ld a, WIN_SLOT_MARK
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, WIN_SLOT_PTR
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
ENDM

; \1 tile pointer, \2 map cell, \3 first tile, \4 tile past the row,
; \5 text pointer, \6 row length before the increment.
MACRO plant_window_strip
    ld a, LOW(WIN_TEXT_BUF)
    ld [$C93D], a
    ld a, HIGH(WIN_TEXT_BUF)
    ld [$C93E], a
    ld a, WIN_STRIP_FLAG_ON
    ld [WIN_STRIP_FLAG], a
    ld a, LOW(\1)
    ld [WIN_TILE_PTR], a
    ld [WIN_TILE_PTR_ECHO], a
    ld a, HIGH(\1)
    ld [WIN_TILE_PTR + 1], a
    ld [WIN_TILE_PTR_ECHO + 1], a
    ld a, LOW(\2)
    ld [WIN_MAP_CELL], a
    ld a, HIGH(\2)
    ld [WIN_MAP_CELL + 1], a
    ld a, \3
    ld [WIN_TILE_LO], a
    ld [WIN_TILE_LO_COPY], a
    ld a, WIN_TILE_MID_VAL
    ld [WIN_TILE_MID], a
    ld a, \4
    ld [WIN_TILE_HI], a
    ld a, LOW(\5)
    ld [WIN_STRIP_TEXT], a
    ld a, HIGH(\5)
    ld [WIN_STRIP_TEXT + 1], a
    ld a, \6
    inc a
    ld [WIN_STRIP_PASSES], a
    ld a, LOW(WIN_STRIP_FN)
    ld [WIN_STRIP_ROUTINE], a
    ld a, HIGH(WIN_STRIP_FN)
    ld [WIN_STRIP_ROUTINE + 1], a
    ld hl, RunWindowStripPasses
    ld e, WIN_BANK
    call CallBankedHL
ENDM

ServiceWindowChoice::
    ld hl, Bank3_415D
    ld e, WIN_BANK
    call CallBankedHL
    call RefreshFrame
    ld a, [WIN_CHOICE]
    cp WIN_CHOICE_WAIT
    jr z, ServiceWindowChoice
    ld [WIN_CHOICE_SAVED], a
    and a
    jr nz, .choiceSet
.reloadWindow:
    call TurnOffLCD
    call LoadPagedSRAMChoicePairs
    call PaintWindowIndexedRows
    arm_window_slot
    ld a, WIN_SLOT_ID
    ld [WIN_SLOT_INDEX_ADDR], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, WIN_BANK
    call CallBankedHL
    ld a, WIN_CHOICE_WAIT
    ld [WIN_CHOICE], a
    call TurnOnLCDIfOff
    jp ServiceWindowChoice
.choiceSet:
    cp WIN_CHOICE_EIGHT
    jr z, .reloadWindow
    cp WIN_CHOICE_CANCEL
    jr nz, .dispatchResult
    jp LeaveWindowChoiceReloadTiles
.dispatchResult:
    call ResolveArmedListChoice
    ld a, [WIN_RESULT]
    cp WIN_RESULT_NONE
    jp z, .armUnchanged
    cp WIN_RESULT_THREE
    jr z, .armSavedChoice
    cp WIN_RESULT_ONE
    jp nz, LeaveWindowChoiceReloadTiles
    call MarkWindowChoiceCells
.armSavedChoice:
    call Bank3_565B
    arm_window_slot
    ld a, [WIN_CHOICE_SAVED]
    ld [WIN_SLOT_INDEX_ADDR], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, WIN_BANK
    call CallBankedHL
    ld a, WIN_CHOICE_WAIT
    ld [WIN_CHOICE], a
    plant_window_strip WIN_ROW_1_TILE, WIN_MAP_ROW_1, WIN_ROW_1_LO, WIN_ROW_1_HI, WIN_TEXT_1, WIN_ROW_1_COUNT
    plant_window_strip WIN_ROW_2_TILE, WIN_MAP_ROW_2, WIN_ROW_2_LO, WIN_ROW_2_HI, WIN_TEXT_2, WIN_ROW_2_COUNT
    jp ServiceWindowChoice
.armUnchanged:
    arm_window_slot
    ld a, [WIN_SLOT_INDEX_ADDR]
    ld [WIN_SLOT_INDEX_ADDR], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, WIN_BANK
    call CallBankedHL
    ld a, WIN_CHOICE_WAIT
    ld [WIN_CHOICE], a
    jp ServiceWindowChoice
