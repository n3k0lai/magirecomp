; Taken from the $6591 loop when [$D016] is nonzero. Each value leaves
; through ContinueStartup after planting the fourth script record at $C71B.
;
; 2 sets wSoundIndex to 2, runs bank 5's $57BA twice, then the shared path.
; 4 skips that preamble and enters the shared path. The shared path walks
; four words at $D36E. A zero word is skipped. Otherwise C * $37 is added
; to $D17E, which is $D147 plus one record of the stride ClearMarksAndWalkSlots
; uses. The big-endian word at record+7 is added to the big-endian word at
; $D14E, plus one, and clamped to the big-endian word at $D150. Two bytes at
; record+5 are copied to three bytes past the list word. SRAM bank
; wSRAMBank+1 is enabled for that copy and for the store of $D14E at $A005
; (sMapWord1 in draw_start_screen_map.asm). Bank 5's $42F6 and bank 2's
; $54D9 run, and $C71B becomes bank $4C, pointer $4B5B, handler $0A66.
;
; 3 runs $57BA with the $D0C0 values swapped, plants pointer $45AB, calls
; bank 5's $5A1A, then bank 7's $4850. It repeats bank 7's $489D, bank 7's
; $474F, and FinishFrame while the byte at $C9DE counts down from $20.
; $C9D8, $C9DA, $C9DB, and $C9DC are set first. The HRAM script bank and
; pointer come from $D3D0 and the little-endian word at $D3D1.
;
; Any other value writes $D14E to sMapWord1 the same way. A zero word becomes
; $0001 in SRAM, low byte only. $C71B gets pointer $4A17.
;
; The shared tail calls $5A1A unless [$D016] is 4, turns the LCD off, calls
; bank 4's $62BE, and copies [$C923] into wSoundIndex when it differs.
; Each sound update clears $C92A and stores $0F at $C92C. WRAM bank 7 is
; selected. The HRAM script bank and pointer come from $D3CD and the
; little-endian word at $D3CE. ContinueStartup forces the handler to $0A66.
;
; wSoundIndex ($C920), wSoundActive ($C91E), and wSoundSelect ($C92A) are
; the names from select_sound_command.asm. wUnknownC92C is the name from
; handle_start_press.asm. wSRAMBank, rRAMB, and SRAM_ENABLE are the names
; from handle_start_press.asm. wUnknownC9D8 is the name from
; indexed_tail_07.asm. wEntryRecord ($C9DC) and wEntryRecordField ($C9DE)
; are the names from record_ptr_from_id.asm. $C71B is the fourth script
; record FinishFrame runs. rRAMG, hScriptBank, hScriptPtr, and
; INITIAL_SCRIPT_HANDLER are the names from reset.asm. wCurrentWRAMBank
; and rSVBK are the names from timer_overflow.asm. CallBankedHL, MulCByB,
; TurnOffLCD, FinishFrame, and ContinueStartup are already source.
; $57BA, $42F6, $54D9, $5A1A, $4850, $489D, $474F, and $62BE are still INCBIN.

; Mode byte tested by the $6591 loop.
DEF wD016 EQU $D016

; Four destination words. A zero word skips that slot.
DEF wDestList EQU $D36E
DEF DEST_COUNT EQU $04

; First of the four records. Stride matches the $D147 records.
DEF wRecord1 EQU $D17E
DEF D016_RECORD_STRIDE EQU $37
DEF RECORD_COPY_OFF EQU $0005
DEF RECORD_WORD_OFF EQU $0007

; Big-endian running total and its big-endian clamp.
DEF wRunningTotal EQU $D14E
DEF wRunningLimit EQU $D150

; Map word in SRAM bank wSRAMBank+1. High byte first.
; draw_start_screen_map.asm names this sMapWord1.
DEF sRunningAtA005 EQU $A005

; Arguments for the two bank 5 $57BA calls.
DEF wSetupSrc EQU $D338
DEF wSetupD0C0 EQU $D0C0
DEF wSetupD0C1 EQU $D0C1
DEF wSetupD0C2 EQU $D0C2

; Fourth script record. Bank, then a little-endian pointer, then $0A66.
DEF wScriptC71B EQU $C71B
DEF SCRIPT_BANK_4C EQU $4C
DEF SCRIPT_PTR_MODE2 EQU $4B5B
DEF SCRIPT_PTR_MODE3 EQU $45AB
DEF SCRIPT_PTR_OTHER EQU $4A17

; Sound index stored on the mode 2 path.
DEF SOUND_INDEX_MODE2 EQU $02

; Byte copied into wSoundIndex on the other paths. Role still unknown.
DEF wUnknownC923 EQU $C923

; Mode 3 writes these before the $20-pass loop. $C9DA and $C9DB are a
; little-endian word $7FFF. What bank 7 reads from them is still unknown.
DEF wUnknownC9DA EQU $C9DA
DEF wUnknownC9DB EQU $C9DB
DEF MODE3_PASSES EQU $20
DEF MODE3_C9D8 EQU $0F
DEF MODE3_WORD EQU $7FFF

; HRAM script source on the shared tail, then on the mode 3 tail.
DEF wTailScript EQU $D3CD
DEF wMode3Script EQU $D3D0

; Value stored at wUnknownC92C by every sound update.
DEF C92C_VALUE EQU $0F

DispatchNonzeroD016::
    ld a, [wD016]
    cp SOUND_INDEX_MODE2
    jp nz, .notMode2
    push de
    ld a, SOUND_INDEX_MODE2
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .soundReady2
    ld a, e
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a
.soundReady2:
    xor a
    ld [wSoundSelect], a
    ld a, C92C_VALUE
    ld [wUnknownC92C], a
    pop de
    ld a, [wSetupSrc]
    ld [wSetupD0C2], a
    ld a, $04
    ld [wSetupD0C0], a
    ld a, $0C
    ld [wSetupD0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    ld a, $58
    ld [wSetupD0C2], a
    ld a, $03
    ld [wSetupD0C0], a
    ld a, $0B
    ld [wSetupD0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
; Mode 4 jumps here. C is the slot and B stays the record stride.
.clampFour:
    ld hl, wDestList
    ld c, $00
    ld b, D016_RECORD_STRIDE
.slot:
    push hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .nextSlot
    ld de, $0003
    add hl, de
    push hl
    call MulCByB
    ld de, wRecord1
    add hl, de
    ld de, RECORD_COPY_OFF
    add hl, de
    push hl
; Subtract the copy offset, then add the word offset. HL is record+7.
    ld de, RECORD_COPY_OFF
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld de, RECORD_WORD_OFF
    add hl, de
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    ld hl, wRunningTotal
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, de
    inc hl
    ld a, [wRunningLimit]
    ld d, a
    ld a, [wRunningLimit + 1]
    ld e, a
    ld a, e
    sub l
    ld a, d
    sbc a, h
    jp nc, .keepSum
    ld h, d
    ld l, e
.keepSum:
    ld a, h
    ld [wRunningTotal], a
    ld a, l
    ld [wRunningTotal + 1], a
    pop hl
    pop de
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    xor a
    ld [rRAMG], a
.nextSlot:
    pop hl
    inc bc
    ld a, DEST_COUNT
    cp c
    jr z, .storeTotal
    inc hl
    inc hl
    jr .slot
.storeTotal:
    ld bc, wRunningTotal
    ld hl, sRunningAtA005
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    xor a
    ld [rRAMG], a
    ld hl, $42F6
    ld e, $05
    call CallBankedHL
    call $54D9
    ld hl, wScriptC71B
    ld a, SCRIPT_BANK_4C
    ld [hl+], a
    ld a, LOW(SCRIPT_PTR_MODE2)
    ld [hl+], a
    ld a, HIGH(SCRIPT_PTR_MODE2)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    jp .join
.notMode2:
    cp $03
    jp nz, .notMode3
    ld a, [wSetupSrc]
    ld [wSetupD0C2], a
    ld a, $03
    ld [wSetupD0C0], a
    ld a, $0C
    ld [wSetupD0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    ld a, $58
    ld [wSetupD0C2], a
    ld a, $04
    ld [wSetupD0C0], a
    ld a, $0B
    ld [wSetupD0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    ld hl, wScriptC71B
    ld a, SCRIPT_BANK_4C
    ld [hl+], a
    ld a, LOW(SCRIPT_PTR_MODE3)
    ld [hl+], a
    ld a, HIGH(SCRIPT_PTR_MODE3)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, MODE3_PASSES
    ld [wEntryRecordField], a
    ld a, MODE3_C9D8
    ld [wUnknownC9D8], a
    ld a, LOW(MODE3_WORD)
    ld [wUnknownC9DA], a
    ld a, HIGH(MODE3_WORD)
    ld [wUnknownC9DB], a
    ld hl, $4850
    ld e, $07
    call CallBankedHL
    ld a, $01
    ld [wEntryRecord], a
.mode3Pass:
    ld hl, $489D
    ld e, $07
    call CallBankedHL
    ld hl, $474F
    ld e, $07
    call CallBankedHL
    call FinishFrame
    ld a, [wEntryRecordField]
    dec a
    ld [wEntryRecordField], a
    jr nz, .mode3Pass
    call TurnOffLCD
    ld hl, $62BE
    ld e, $04
    call CallBankedHL
    ld a, [wUnknownC923]
    push de
; `ld a, a` keeps the $C923 byte in A. The following bytes match the mode 2 update.
    ld a, a
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .soundReady3
    ld a, e
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a
.soundReady3:
    xor a
    ld [wSoundSelect], a
    ld a, C92C_VALUE
    ld [wUnknownC92C], a
    pop de
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wMode3Script]
    ldh [hScriptBank], a
    ld hl, wMode3Script + 1
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, hScriptPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    jp ContinueStartup
.notMode3:
    cp $04
    jp z, .clampFour
    ld bc, wRunningTotal
    ld hl, sRunningAtA005
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld d, a
    ld a, [bc]
    ld [hl+], a
    inc bc
    or d
    jr nz, .totalWritten
; A zero total is stored as high $00, low $01.
    dec hl
    inc [hl]
.totalWritten:
    xor a
    ld [rRAMG], a
    ld hl, wScriptC71B
    ld a, SCRIPT_BANK_4C
    ld [hl+], a
    ld a, LOW(SCRIPT_PTR_OTHER)
    ld [hl+], a
    ld a, HIGH(SCRIPT_PTR_OTHER)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
.join:
    ld a, [wD016]
    cp $04
    jr z, .after5A1A
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
.after5A1A:
    call TurnOffLCD
    ld hl, $62BE
    ld e, $04
    call CallBankedHL
    ld a, [wUnknownC923]
    push de
    ld a, a
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .soundReadyJoin
    ld a, e
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a
.soundReadyJoin:
    xor a
    ld [wSoundSelect], a
    ld a, C92C_VALUE
    ld [wUnknownC92C], a
    pop de
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wTailScript]
    ldh [hScriptBank], a
    ld hl, wTailScript + 1
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, hScriptPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    jp ContinueStartup
