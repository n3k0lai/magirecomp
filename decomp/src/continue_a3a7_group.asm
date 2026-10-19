; Bank 5 at $4BAA. PrepareA3A7GroupOrRet falls in here when the word at
; wGroupPointers is nonzero. JumpHL entered that routine for [$D104] = 2.
;
; Two five-byte script records are written at wScriptC71BRecord. Each is
; bank 2, a little-endian pointer, and the trailing bytes $66 $0A. The
; pointers are $5CBA and $5CB8. FinishFrame runs until [wUnknownC6EE] is 0,
; then again until it is 2.
;
; A zero [wGroupCopyGate] skips both row passes. Otherwise $D074 walks the
; five group pointers. Each pass subtracts wGroupSRAM from the pointer.
; The first pass multiplies that low byte by $22, adds wGroupAddend, and
; calls CopyGroupBytes in bank 7. The $0D bytes at $CD9D are painted at
; $8860 + index * $D0, map cell $9C02 + index * $20. The second pass reads
; one SRAM byte through the pointer. Zero stores $F0 for all three digits.
; Any other byte is formatted by FormatStartDigits. The three ASCII digits
; are painted from $8C70 + index * $30, map cell $9C10 + index * $20.
; $2B8F runs through JumpHL once per tile, and FinishFrame follows.
;
; The five pointers are then compared with wGroupSRAM. A match stores 0 at
; wEntryFlags + index; any other pointer stores a nonzero byte. Two $01
; bytes follow. SRAM walks down from the first pointer and up from the
; fifth, the same miss rules as ScanGroupBytes, and a miss clears one of
; those $01 bytes. SRAM is disabled. wCallback becomes $3931 and FinishFrame
; runs once.
;
; The choice block is filled: STAT handler $2AC1, $CCB4 = 4, $CCA9 = $F3,
; $CCB8 copies the WRAM bank, $CCB6 points at wEntryFlags, and $CCB0 and
; $CCB2 both point at HoldLcdOff. $CD81 is 0, $CCB9 is 1, and $CCBA is 0.
; Bank 3 at $417C runs once. $CCA7 becomes $FF and wButtonsPressed is
; cleared. Each pass calls bank 3 at $4141 and FinishFrame until $CCA7 is
; no longer $FF. $FE returns. A value of 5 or more jumps back to the shared
; tail at $4B70. A smaller value selects that group pointer, calls
; CopyGroupBytes again, and either returns the scaled word at $D107 or
; stores $02 at wSoundSlotA and installs the choice block again.
;
; `add a, $00` keeps the SRAM bank byte. `cp $00` and `ld a, $00` are the
; immediate forms. The HRAM stores are the 3-byte form. `and c` retests the
; offset already in C. The second `ld b, a` is not on this path.
; wCurrentWRAMBank and rSVBK are not written again here. rRAMG is the name
; from reset.asm. rRAMB, wSRAMBank, SRAM_ENABLE, wUnknownCD81, wUnknownCCA9,
; wUnknownCCB0, wUnknownCCB2, wUnknownCCB6, and wUnknownCCB9 are the names
; from handle_start_press.asm. wGroupPointers is the name from
; write_group_row_digits.asm. wGroupSRAM, wGroupAddend, wGroupScaled,
; wGroupListPtr, wGroupList0B, and wGroupCopyGate are the names from
; scan_group_bytes.asm. wUnknownC6EE is the name from setup_window.asm.
; wScriptC71BRecord, SCRIPT_BANK_02, SCRIPT_TAIL_66, SCRIPT_TAIL_0A, and
; wEntryFlags are the names from load_five_sram_entry_digits.asm.
; CHOICE_SCRIPT_PTR and the wStrip* names are from run_d0b1_map_strips.asm.
; wUnknownC93D and wListTailDest are the names from setup_command_4d.asm.
; wStartDigitOnes, wStartDigitTens, and wStartDigitHundreds are the names
; from format_start_digits.asm. ASCII_DIGIT_BASE is the name from
; write_indexed_names_and_count.asm. wCallback is the name from
; default_state.asm. hSTATHandler is the name from lcd_stat.asm.
; wButtonsPressed is the name from main_loop.asm. wSoundSlotA is the name
; from select_sound_command.asm. wChosenSlot and CHOSEN_SLOT_NONE are the
; names from load_five_sram_entry_digits.asm. CopyGroupBytes, HoldLcdOff,
; LoadArmedSlotRecord, RefreshChoiceCursor, JumpHL, FinishFrame, MulCByB,
; FormatStartDigits, and DispatchIfD0E0AboveD102 are already source.

; Row index 0 through 4. Compared with 5 after each increment.
DEF wGroupRow EQU $D074
DEF GROUP_ROW_LIMIT EQU $05

; Low byte of (pointer - wGroupSRAM) is multiplied by the scale just stored.
DEF GROUP_SCALE_VALUE EQU $22

; First row of tiles and map cells. The second row uses the digit buffer.
DEF GROUP_ROW_TILES EQU $8860
DEF GROUP_ROW_MAP EQU $9C02
DEF GROUP_DIGIT_TILES EQU $8C70
DEF GROUP_DIGIT_MAP EQU $9C10
DEF GROUP_TILE_SHIFT EQU $04
DEF GROUP_MAP_STRIDE EQU $20
DEF GROUP_LIST_SKIP EQU $0C
DEF GROUP_DIGIT_COUNT EQU $03

; Blank digit stored when the SRAM byte is zero.
DEF GROUP_DIGIT_BLANK EQU $F0

; Choice block filled before the $CCA7 wait.
DEF GROUP_CHOICE_MARK EQU $04
DEF GROUP_CHOICE_F3 EQU $F3
DEF GROUP_CHOICE_BANK EQU $03
DEF GROUP_STAT_LO EQU $C1
DEF GROUP_STAT_HI EQU $2A
DEF GROUP_CALLBACK EQU $3931
DEF GROUP_SOUND_RETRY EQU $02
DEF GROUP_SLOT_LIMIT EQU $05

; Bit tested in the byte CopyGroupBytes left at $CD9A.
DEF wGroupCopiedFlag EQU $CD9A
DEF GROUP_COPIED_BIT EQU $01
DEF wGroupCopiedD103 EQU $CD96
DEF wGroupCopiedD102 EQU $CD95
DEF wGroupCopiedD105 EQU $CD98
DEF wGroupChosenWord EQU $D107

; HL is the text pointer, DE the tile pointer, BC the map address.
; \1 is the tile span. The pass count is that span plus one.
MACRO stage_group_strip
    ld a, l
    ld [wStripText], a
    ld a, h
    ld [wStripText + 1], a
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld a, STRIP_FLAG
    ld [wStripFlag], a
    ld a, e
    ld [wGlyphDest], a
    ld [wStripTileEcho], a
    ld a, d
    ld [wGlyphDest + 1], a
    ld [wStripTileEcho + 1], a
    ld a, c
    ld [wStripMapCell], a
    ld a, b
    ld [wStripMapCell + 1], a
    ld a, GROUP_TILE_SHIFT
.shift\@
    srl d
    rr e
    dec a
    jr nz, .shift\@
    ld a, e
    ld [wStripTileLo], a
    ld [wStripTileLoCopy], a
    ld a, STRIP_TILE_MID
    ld [wStripTileMid], a
    ld a, e
    add \1
    ld [wStripTileHi], a
    ld a, \1
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

ContinueA3A7Group::
    ld hl, wScriptC71BRecord
    ld a, SCRIPT_BANK_02
    ld [hl+], a
    ld a, LOW(CHOICE_SCRIPT_PTR + 2)
    ld [hl+], a
    ld a, HIGH(CHOICE_SCRIPT_PTR + 2)
    ld [hl+], a
    ld a, SCRIPT_TAIL_66
    ld [hl+], a
    ld a, SCRIPT_TAIL_0A
    ld [hl+], a
.waitScript0:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .secondScript
    call FinishFrame
    jr .waitScript0
.secondScript:
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
.waitScript2:
    ld a, [wUnknownC6EE]
    cp $02
    jr z, .gate
    call FinishFrame
    jr .waitScript2
.gate:
    ld a, [wGroupCopyGate]
    and a
    jp z, .markMatchingPointers
    xor a
    ld [wGroupRow], a
.rowTiles:
    ld hl, wGroupPointers
    ld a, [wGroupRow]
    ld c, a
    ld b, $00
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wGroupSRAM + 1]
    ld d, a
    ld a, [wGroupSRAM]
    ld e, a
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld b, l
    ld c, GROUP_SCALE_VALUE
    call MulCByB
    ld a, [wGroupAddend + 1]
    ld b, a
    ld a, [wGroupAddend]
    ld c, a
    add hl, bc
    ld a, h
    ld [wGroupScaled + 1], a
    ld a, l
    ld [wGroupScaled], a
    ld bc, wGroupList0B
    ld hl, wGroupListPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, GROUP_BUILD_BANK
    call CallBankedHL
    ld hl, wGroupList0B
    ld bc, GROUP_LIST_SKIP
    add hl, bc
    push hl
    ld a, [wGroupRow]
    ld b, a
    ld c, GROUP_BLOCK_COUNT
    call MulCByB
    ld a, GROUP_TILE_SHIFT
.shiftTileRow:
    sla l
    rl h
    dec a
    jr nz, .shiftTileRow
    ld bc, GROUP_ROW_TILES
    add hl, bc
    push hl
    ld a, [wGroupRow]
    ld b, a
    ld c, GROUP_MAP_STRIDE
    call MulCByB
    ld bc, GROUP_ROW_MAP
    add hl, bc
    ld b, h
    ld c, l
    pop de
    pop hl
    stage_group_strip GROUP_BLOCK_COUNT
    ld hl, wGroupRow
    inc [hl]
    ld a, GROUP_ROW_LIMIT
    cp [hl]
    jp nz, .rowTiles
    xor a
    ld [wGroupRow], a
.rowDigits:
    ld hl, wGroupPointers
    ld a, [wGroupRow]
    ld c, a
    ld b, $00
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld e, [hl]
    ld d, $00
    xor a
    ld [rRAMG], a
    xor a
    cp e
    jr nz, .formatDigit
    ld a, GROUP_DIGIT_BLANK
    ld hl, wStartDigitOnes
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    jr .storeDigits
.formatDigit:
    call FormatStartDigits
.storeDigits:
    ld hl, wGroupList0B
    ld a, [wStartDigitHundreds]
    add ASCII_DIGIT_BASE
    ld [hl+], a
    ld a, [wStartDigitTens]
    add ASCII_DIGIT_BASE
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add ASCII_DIGIT_BASE
    ld [hl+], a
    ld a, [wGroupRow]
    ld b, a
    ld c, GROUP_DIGIT_COUNT
    call MulCByB
    ld a, GROUP_TILE_SHIFT
.shiftDigitRow:
    sla l
    rl h
    dec a
    jr nz, .shiftDigitRow
    ld bc, GROUP_DIGIT_TILES
    add hl, bc
    push hl
    ld a, [wGroupRow]
    ld b, a
    ld c, GROUP_MAP_STRIDE
    call MulCByB
    ld bc, GROUP_DIGIT_MAP
    add hl, bc
    ld b, h
    ld c, l
    ld hl, wGroupList0B
    pop de
    stage_group_strip GROUP_DIGIT_COUNT
    ld hl, wGroupRow
    inc [hl]
    ld a, GROUP_ROW_LIMIT
    cp [hl]
    jp nz, .rowDigits
.markMatchingPointers:
    ld hl, wGroupPointers
    ld de, wEntryFlags
    ld c, GROUP_ROW_LIMIT
.nextPointer:
    push de
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    push hl
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, h
    or l
    pop hl
    pop de
    ld [de], a
    inc de
    inc hl
    dec c
    jr nz, .nextPointer
    ld a, $01
    ld [de], a
    inc de
    ld [de], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld hl, wGroupPointers
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld b, $00
    ld c, l
.scanDown:
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    dec bc
    ld a, $ff
    cp c
    jr z, .missDown
    add hl, bc
    ld a, [hl]
    and a
    jr z, .scanDown
    jr .scanUpSetup
.missDown:
    xor a
    ld [wEntryFlags + 5], a
.scanUpSetup:
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld hl, wGroupPointers + 8
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld b, $00
    ld c, l
    ld a, c
    and c
    jr z, .missUp
.scanUp:
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc bc
    ld a, $ff
    cp c
    jr z, .missUp
    add hl, bc
    ld a, [hl]
    and a
    jr z, .scanUp
    jr .disableSram
.missUp:
    xor a
    ld [wEntryFlags + 6], a
.disableSram:
    xor a
    ld [rRAMG], a
    ld a, LOW(GROUP_CALLBACK)
    ld [wCallback], a
    ld a, HIGH(GROUP_CALLBACK)
    ld [wCallback + 1], a
    call FinishFrame
.installChoice:
    ld a, GROUP_STAT_LO
    ld [hSTATHandler], a
    ld a, GROUP_STAT_HI
    ld [hSTATHandler + 1], a
    ld a, GROUP_CHOICE_MARK
    ld [$CCB4], a
    ld a, GROUP_CHOICE_F3
    ld [wUnknownCCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, wEntryFlags
    ld hl, wUnknownCCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $00
    ld [wUnknownCD81], a
    ld a, $01
    ld [wUnknownCCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, GROUP_CHOICE_BANK
    call CallBankedHL
    ld a, $ff
    ld [wChosenSlot], a
    ld hl, wButtonsPressed
    xor a
    ld [hl], a
.waitChoice:
    ld hl, RefreshChoiceCursor
    ld e, GROUP_CHOICE_BANK
    call CallBankedHL
    call FinishFrame
    ld a, [wChosenSlot]
    cp $ff
    jr z, .waitChoice
    cp CHOSEN_SLOT_NONE
    ret z
    cp GROUP_SLOT_LIMIT
    jp nc, PrepareA3A7GroupOrRet.reenterWith0D
    ld c, a
    ld b, $00
    ld hl, wGroupPointers
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wGroupSRAM + 1]
    ld d, a
    ld a, [wGroupSRAM]
    ld e, a
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld b, l
    ld c, GROUP_SCALE_VALUE
    call MulCByB
    ld a, [wGroupAddend + 1]
    ld b, a
    ld a, [wGroupAddend]
    ld c, a
    add hl, bc
    push hl
    ld a, h
    ld [wGroupScaled + 1], a
    ld a, l
    ld [wGroupScaled], a
    ld bc, wGroupList0B
    ld hl, wGroupListPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, GROUP_BUILD_BANK
    call CallBankedHL
    ld a, [wGroupCopiedFlag]
    and GROUP_COPIED_BIT
    jr z, .soundAndChoice
    ld a, [wGroupCopiedD103]
    ld [$D103], a
    ld a, [wGroupCopiedD102]
    ld [$D102], a
    ld a, [wGroupCopiedD105]
    ld [$D105], a
    call DispatchIfD0E0AboveD102
    ld a, [$D0AF]
    and a
    jr nz, .storeChosenWord
.soundAndChoice:
    pop bc
    ld a, GROUP_SOUND_RETRY
    ld [wSoundSlotA], a
    jp .installChoice
.storeChosenWord:
    pop bc
    ld hl, wGroupChosenWord
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret
