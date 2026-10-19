; Bank 4 at $5A5B. CopiedBlockWindowChoice calls here for a choice other
; than 0, 4, or $FE. This bank stays mapped. The routine does not write
; rROMB0.
;
; $6160 in bank 4 is stored at wCallback and RefreshFrame runs. $CD4E
; is set to $FFFF so a skipped third cost still reads as $FF. The
; 8-byte record is at $CD22 plus eight times ([$CD81] - 1).
;
; The little-endian word at record+5 is subtracted from the SRAM word
; at $A3A5. The difference is stored at $CD4A. Record+1 indexes the
; SRAM byte table at $A4A6; record+2 is subtracted from that byte and
; the result is stored at $CD4D. The index is saved at $CD4C. When
; record+4 is not 0, record+3 indexes the same table, record+4 is
; subtracted, and the result is stored at $CD4F with the index at
; $CD4E. Each subtract is a two's-complement add. No carry means the
; SRAM value was smaller, and control leaves through $5DF5.
;
; SRAM bank wSRAMBank is selected with `add a, $00`, enabled, read,
; and disabled. rRAMB, wSRAMBank, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
;
; Three strip blocks then point $C93D at wListTailDest and store 1 at
; $C6EB. The tile pointer is written at $C6E9 and again at $C941. The
; map cells are $9DA1, $9DE1, and $9E02. The first tile of each row is
; stored at $C944 and $C946, $8F sits between them at $C945, and the
; tile just past the row is stored at $C947. $C93B points at $481A,
; $4826, then $4830. The pass count is the row length plus one, via
; `inc a`: $0C, $0A, and $07. $C939 points at $2B8F. RunWindowStripPasses
; runs after each block.
;
; $CC52 and $CC53 are set to 1. The slot is armed with table index 5,
; mark $F3, and id 5. $CCB6 points at $CC4D. $CCB0 and $CCB2 both hold
; $42E3. $CCB9 and $CCBA are 0, written with the immediate form, so
; LoadArmedSlotRecord returns before ReloadSlotPosition. $CCA7 is set
; to $FF. Each wait pass calls RefreshChoiceCursor, then RefreshFrame,
; and loops while $CCA7 stays $FF. The record pointer is popped. A
; choice other than 5 returns here. Choice 5 continues in the bytes
; that are still INCBIN.
;
; wCallback and wCallbackBank are the names from default_state.asm.
; wListTailDest is the name from setup_command_4d.asm. wCurrentWRAMBank
; is the name from timer_overflow.asm. MultiplyCByB is the name from
; draw_cgb_notice.asm. RefreshFrame, CallBankedHL, RefreshChoiceCursor,
; RunWindowStripPasses, and LoadArmedSlotRecord are already source.
; $5DF5 is still INCBIN.

DEF OTHER_CALLBACK_BANK EQU $04
DEF OTHER_CALLBACK EQU $6160

DEF OTHER_RECORD_BASE EQU $CD22
DEF OTHER_RECORD_STRIDE EQU $08
DEF OTHER_SLOT_ID EQU $CD81
DEF OTHER_COST_WORD EQU $A3A5
DEF OTHER_COST_BYTES EQU $A4A6
DEF OTHER_DIFF_WORD EQU $CD4A
DEF OTHER_INDEX_A EQU $CD4C
DEF OTHER_DIFF_A EQU $CD4D
DEF OTHER_SENTINEL EQU $CD4E
DEF OTHER_DIFF_B EQU $CD4F

DEF OTHER_CHOICE EQU $CCA7
DEF OTHER_CHOICE_WAIT EQU $FF
DEF OTHER_CHOICE_FIVE EQU $05

DEF OTHER_SLOT_INDEX EQU $05
DEF OTHER_SLOT_MARK EQU $F3
DEF OTHER_SLOT_PTR EQU $CC4D
DEF OTHER_SLOT_WORD EQU $42E3
DEF OTHER_RECORD_BANK EQU $03

DEF OTHER_TEXT_BUF EQU $C93D
DEF OTHER_STRIP_FLAG EQU $C6EB
DEF OTHER_STRIP_FLAG_ON EQU $01
DEF OTHER_TILE_PTR EQU $C6E9
DEF OTHER_TILE_PTR_ECHO EQU $C941
DEF OTHER_MAP_CELL EQU $C93F
DEF OTHER_TILE_LO EQU $C944
DEF OTHER_TILE_LO_COPY EQU $C946
DEF OTHER_TILE_MID EQU $C945
DEF OTHER_TILE_MID_VAL EQU $8F
DEF OTHER_TILE_HI EQU $C947
DEF OTHER_STRIP_TEXT EQU $C93B
DEF OTHER_STRIP_PASSES EQU $CCB5
DEF OTHER_STRIP_ROUTINE EQU $C939
DEF OTHER_STRIP_FN EQU $2B8F

DEF OTHER_ROW_1_TILE EQU $8EE0
DEF OTHER_ROW_1_MAP EQU $9DA1
DEF OTHER_ROW_1_LO EQU $EE
DEF OTHER_ROW_1_HI EQU $FA
DEF OTHER_ROW_1_TEXT EQU $481A
DEF OTHER_ROW_1_LEN EQU $0C

DEF OTHER_ROW_2_TILE EQU $8FA0
DEF OTHER_ROW_2_MAP EQU $9DE1
DEF OTHER_ROW_2_LO EQU $FA
DEF OTHER_ROW_2_HI EQU $04
DEF OTHER_ROW_2_TEXT EQU $4826
DEF OTHER_ROW_2_LEN EQU $0A

DEF OTHER_ROW_3_TILE EQU $9040
DEF OTHER_ROW_3_MAP EQU $9E02
DEF OTHER_ROW_3_LO EQU $04
DEF OTHER_ROW_3_HI EQU $0B
DEF OTHER_ROW_3_TEXT EQU $4830
DEF OTHER_ROW_3_LEN EQU $07

; \1 tile pointer, \2 map cell, \3 first tile, \4 tile past the row,
; \5 text pointer, \6 row length before the increment.
MACRO plant_other_choice_strip
    ld a, LOW(wListTailDest)
    ld [OTHER_TEXT_BUF], a
    ld a, HIGH(wListTailDest)
    ld [OTHER_TEXT_BUF + 1], a
    ld a, OTHER_STRIP_FLAG_ON
    ld [OTHER_STRIP_FLAG], a
    ld a, LOW(\1)
    ld [OTHER_TILE_PTR], a
    ld [OTHER_TILE_PTR_ECHO], a
    ld a, HIGH(\1)
    ld [OTHER_TILE_PTR + 1], a
    ld [OTHER_TILE_PTR_ECHO + 1], a
    ld a, LOW(\2)
    ld [OTHER_MAP_CELL], a
    ld a, HIGH(\2)
    ld [OTHER_MAP_CELL + 1], a
    ld a, \3
    ld [OTHER_TILE_LO], a
    ld [OTHER_TILE_LO_COPY], a
    ld a, OTHER_TILE_MID_VAL
    ld [OTHER_TILE_MID], a
    ld a, \4
    ld [OTHER_TILE_HI], a
    ld a, LOW(\5)
    ld [OTHER_STRIP_TEXT], a
    ld a, HIGH(\5)
    ld [OTHER_STRIP_TEXT + 1], a
    ld a, \6
    inc a
    ld [OTHER_STRIP_PASSES], a
    ld a, LOW(OTHER_STRIP_FN)
    ld [OTHER_STRIP_ROUTINE], a
    ld a, HIGH(OTHER_STRIP_FN)
    ld [OTHER_STRIP_ROUTINE + 1], a
    ld hl, RunWindowStripPasses
    ld e, OTHER_RECORD_BANK
    call CallBankedHL
ENDM

TryAffordOtherChoice::
    ld a, OTHER_CALLBACK_BANK
    ld [wCallbackBank], a
    ld a, LOW(OTHER_CALLBACK)
    ld [wCallback], a
    ld a, HIGH(OTHER_CALLBACK)
    ld [wCallback + 1], a
    call RefreshFrame
    ld bc, $FFFF
    ld hl, OTHER_SENTINEL
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [OTHER_SLOT_ID]
    dec a
    ld b, a
    ld c, OTHER_RECORD_STRIDE
    call MultiplyCByB
    ld bc, OTHER_RECORD_BASE
    add hl, bc
    push hl
    ld bc, $0005
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld b, h
    ld c, l
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, OTHER_COST_WORD
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    ld [rRAMG], a
    add hl, bc
    ld a, h
    ld [OTHER_DIFF_WORD + 1], a
    ld a, l
    ld [OTHER_DIFF_WORD], a
    pop hl
    jp nc, ShowUnaffordableChoice

    push hl
    ld bc, $0002
    add hl, bc
    ld e, [hl]
    ld d, $00
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    pop hl
    push hl
    ld bc, $0001
    add hl, bc
    ld a, [hl]
    ld [OTHER_INDEX_A], a
    ld c, a
    ld b, $00
    ld hl, OTHER_COST_BYTES
    add hl, bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld l, [hl]
    ld h, $00
    xor a
    ld [rRAMG], a
    add hl, de
    ld a, l
    ld [OTHER_DIFF_A], a
    pop hl
    jp nc, ShowUnaffordableChoice

    push hl
    ld bc, $0004
    add hl, bc
    ld e, [hl]
    xor a
    cp e
    jr z, .strips

    ld d, $00
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    pop hl
    push hl
    ld bc, $0003
    add hl, bc
    ld a, [hl]
    ld [OTHER_SENTINEL], a
    ld c, a
    ld b, $00
    ld hl, OTHER_COST_BYTES
    add hl, bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld l, [hl]
    ld h, $00
    xor a
    ld [rRAMG], a
    add hl, de
    ld a, l
    ld [OTHER_DIFF_B], a
    pop hl
    jp nc, ShowUnaffordableChoice

    push hl

.strips
    plant_other_choice_strip OTHER_ROW_1_TILE, OTHER_ROW_1_MAP, OTHER_ROW_1_LO, OTHER_ROW_1_HI, OTHER_ROW_1_TEXT, OTHER_ROW_1_LEN
    plant_other_choice_strip OTHER_ROW_2_TILE, OTHER_ROW_2_MAP, OTHER_ROW_2_LO, OTHER_ROW_2_HI, OTHER_ROW_2_TEXT, OTHER_ROW_2_LEN
    plant_other_choice_strip OTHER_ROW_3_TILE, OTHER_ROW_3_MAP, OTHER_ROW_3_LO, OTHER_ROW_3_HI, OTHER_ROW_3_TEXT, OTHER_ROW_3_LEN
    ld hl, $CC52
    ld a, $01
    ld [hl+], a
    ld [hl+], a
    ld a, OTHER_SLOT_INDEX
    ld [$CCB4], a
    ld a, OTHER_SLOT_MARK
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, OTHER_SLOT_PTR
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, OTHER_SLOT_WORD
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, OTHER_SLOT_WORD
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, OTHER_SLOT_INDEX
    ld [OTHER_SLOT_ID], a
    ld a, $00
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, OTHER_RECORD_BANK
    call CallBankedHL
    ld a, OTHER_CHOICE_WAIT
    ld [OTHER_CHOICE], a

.waitChoice
    ld hl, RefreshChoiceCursor
    ld e, OTHER_RECORD_BANK
    call CallBankedHL
    call RefreshFrame
    ld a, [OTHER_CHOICE]
    cp OTHER_CHOICE_WAIT
    jr z, .waitChoice

    pop hl
    cp OTHER_CHOICE_FIVE
    ret nz
