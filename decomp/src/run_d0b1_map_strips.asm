; Bank 5 at $45B0. DriveD0B1Choice calls this through CallBankedHL after
; bank 2 at $5F4D, with bank 5 still mapped.
;
; A nonzero [$D0B1] writes the bank-2 script $02 $5CB8 $66 $0A at
; wScriptC71BRecord and calls FinishFrame until [wUnknownC6EE] is 2.
; ([$D0B1] - 1) * $14 is added to $30 and stored at $D0B3. wCallbackBank
; becomes 5 and wCallback becomes $5C81, then FinishFrame runs once.
;
; A zero [$D0B1] rotates three 7-byte rows: $D02A into $D04D, $D031 into
; $D02A, and $D04D into $D031.
;
; Both paths call bank 5 at $4B05 and $4A9D, select WRAM bank 7, and paint
; $9C00 map strips. Each strip points wUnknownC93D at wListTailDest, copies
; one tile pointer into wUnknownC6E9 and $C941, and calls $2B8F through
; JumpHL. The pass count loaded below is incremented once, so $2B8F runs
; that many times plus one. FinishFrame follows every pass.
;
; This slice stops after the eighth strip, at $4967. The same routine
; continues in the next INCBIN and returns at $4A9C.
;
; wCurrentWRAMBank, rSVBK, and WRAM_BANK_ENTRY are already defined.
; wCallback and wCallbackBank are the names from default_state.asm.
; wUnknownC6EE is the name from setup_window.asm. wUnknownC6E9 is the
; name from indexed_tail_07.asm. wUnknownC93D and wListTailDest are the
; names from setup_command_4d.asm. wScriptC71BRecord, SCRIPT_BANK_02,
; SCRIPT_TAIL_66, and SCRIPT_TAIL_0A are the names from
; load_five_sram_entry_digits.asm. JumpHL, FinishFrame, and MulCByB are
; already source. $4B05, $4A9D, $2B8F, and $5C81 are still INCBIN.

DEF CHOICE_SCRIPT_PTR EQU $5CB8
DEF CHOICE_CALLBACK EQU $5C81
DEF CHOICE_CALLBACK_BANK EQU $05
DEF CHOICE_READY EQU $02
DEF CHOICE_STRIDE EQU $14
DEF TILE_ID_BASE EQU $30
DEF wChoiceTile EQU $D0B3

DEF wRowD02A EQU $D02A
DEF wRowD031 EQU $D031
DEF wRowD04D EQU $D04D
DEF ROW_BYTES EQU $07

; Flag stored as 1 before each strip. What reads it is unknown.
DEF wStripFlag EQU $C6EB
; Second copy of the tile pointer at wUnknownC6E9. What reads it is unknown.
DEF wStripTileEcho EQU $C941
; Low byte of a $9Cxx tilemap cell, then $9C.
DEF wStripMapCell EQU $C93F
DEF STRIP_MAP_HI EQU $9C
; Tile bytes. The first is stored twice, with $8F between the two copies.
DEF wStripTileLo EQU $C944
DEF wStripTileLoCopy EQU $C946
DEF wStripTileMid EQU $C945
DEF wStripTileHi EQU $C947
DEF STRIP_TILE_MID EQU $8F
; Text pointer and the $2B8F pass count.
DEF wStripText EQU $C93B
DEF wStripPasses EQU $CCB5
DEF wStripRoutine EQU $C939
DEF STRIP_ROUTINE EQU $2B8F
DEF STRIP_FLAG EQU $01

; \1 \2 tile pointer, \3 map low byte, \4 \5 tile bytes, \6 \7 text pointer,
; \8 pass immediate before the increment.
MACRO paint_choice_strip
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld a, STRIP_FLAG
    ld [wStripFlag], a
    ld a, \1
    ld [wUnknownC6E9], a
    ld [wStripTileEcho], a
    ld a, \2
    ld [wUnknownC6E9 + 1], a
    ld [wStripTileEcho + 1], a
    ld a, \3
    ld [wStripMapCell], a
    ld a, STRIP_MAP_HI
    ld [wStripMapCell + 1], a
    ld a, \4
    ld [wStripTileLo], a
    ld [wStripTileLoCopy], a
    ld a, STRIP_TILE_MID
    ld [wStripTileMid], a
    ld a, \5
    ld [wStripTileHi], a
    ld a, \6
    ld [wStripText], a
    ld a, \7
    ld [wStripText + 1], a
    ld a, \8
    inc a
    ld [wStripPasses], a
    ld a, LOW(STRIP_ROUTINE)
    ld [wStripRoutine], a
    ld a, HIGH(STRIP_ROUTINE)
    ld [wStripRoutine + 1], a
.pass\@
    ld hl, wStripRoutine
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    call FinishFrame
    ld hl, wStripPasses
    dec [hl]
    jr nz, .pass\@
ENDM

RunD0B1MapStrips::
    ld a, [$D0B1]
    and a
    jr z, .rotateRows
    ld hl, wScriptC71BRecord
    ld a, SCRIPT_BANK_02
    ld [hl+], a
    ld a, LOW(CHOICE_SCRIPT_PTR)
    ld [hl+], a
    ld a, HIGH(CHOICE_SCRIPT_PTR)
    ld [hl+], a
    ld a, SCRIPT_TAIL_66
    ld [hl+], a
    ld a, SCRIPT_TAIL_0A
    ld [hl+], a
.waitReady:
    ld a, [wUnknownC6EE]
    cp CHOICE_READY
    jr z, .indexFromChoice
    call FinishFrame
    jr .waitReady
.indexFromChoice:
    ld a, [$D0B1]
    dec a
    ld b, CHOICE_STRIDE
    ld c, a
    call MulCByB
    ld a, l
    add TILE_ID_BASE
    ld [wChoiceTile], a
    ld a, CHOICE_CALLBACK_BANK
    ld [wCallbackBank], a
    ld a, LOW(CHOICE_CALLBACK)
    ld [wCallback], a
    ld a, HIGH(CHOICE_CALLBACK)
    ld [wCallback + 1], a
    call FinishFrame
    jr .paint

.rotateRows:
    ld hl, wRowD02A
    ld bc, wRowD04D
    ld d, ROW_BYTES
.copyToHold:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyToHold
    ld hl, wRowD031
    ld bc, wRowD02A
    ld d, ROW_BYTES
.copyToFirst:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyToFirst
    ld hl, wRowD04D
    ld bc, wRowD031
    ld d, ROW_BYTES
.copyToSecond:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyToSecond

.paint:
    call $4B05
    call $4A9D
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    paint_choice_strip $90, $8A, $0D, $A9, $B0, $23, $D0, $07
    paint_choice_strip $60, $88, $05, $86, $8D, $2A, $D0, $07
    paint_choice_strip $D0, $88, $25, $8D, $94, $31, $D0, $07
    paint_choice_strip $00, $8B, $2F, $B0, $B3, $57, $D0, $03
    paint_choice_strip $40, $89, $45, $94, $9B, $38, $D0, $07
    paint_choice_strip $30, $8B, $4F, $B3, $B6, $5A, $D0, $03
    paint_choice_strip $B0, $89, $65, $9B, $A2, $3F, $D0, $07
    paint_choice_strip $60, $8B, $6F, $B6, $B9, $5D, $D0, $03
