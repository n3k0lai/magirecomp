; Bank 5 at $4F54. Word 1 of D104WordTable. JumpHL enters here for
; [$D104] = 1 and the callee's ret returns through CallWordAt4054ForD104.
;
; WRAM bank 7 is stored at wCurrentWRAMBank and selected with rSVBK.
; [$D0C0] becomes 1 and [$CD81] becomes 4. $CDD6, the entry index, is
; cleared. Two five-byte script records are written at $C71B. Each is a
; bank, a little-endian pointer, and the trailing bytes $66 $0A. FinishFrame
; runs the record until [$C6EE] is 0, then again until [$C6EE] is 2.
; CallBankedHL then maps bank 6 and calls $5385.
;
; $D054 is filled with $0F spaces. Five bytes at $D09B are cleared. SRAM
; bank $C727 is enabled just long enough to read $A11D. That byte plus 1
; is stored at $D0A0 and $D0A1 is cleared. WRAM bank 7 is selected again.
;
; The index in $CDD6 selects five ids at $A118. $FF skips that slot. Any
; other id times $25 selects a record in the next SRAM bank. The record's
; first byte is saved. $FF skips the slot. Otherwise the flag at
; $D09B + slot is set to 1, the word at record+$07 is formatted by
; FormatStartDigits, and the three digits plus $30 are stored at
; $D054 + slot * 3. The index advances after the first four slots.
;
; SRAM is disabled. If [$D063] is 9, the five-byte mask is $D37F; otherwise
; it is $D37A. A mask byte of 2 clears the matching flag at $D09B. The next
; seven bytes from $D09B are summed. A zero sum stores $FE at $CCA7 and
; returns. A nonzero sum jumps to the byte after this ret.
;
; `add a, $00` keeps the SRAM bank byte. The second `ld b, a` after `cp $FF`
; repeats the copy that already followed the compare. rSVBK and
; wCurrentWRAMBank are the names from timer_overflow.asm. rRAMG is the name
; from reset.asm. rRAMB, wSRAMBank, SRAM_ENABLE, and wUnknownCD81 are the
; names from handle_start_press.asm. wUnknownC6EE is the name from
; setup_window.asm. sEntryIds, sEntryBase, and ENTRY_STRIDE are the names
; from indexed_tail_07.asm. wStartDigitHundreds, wStartDigitTens, and
; wStartDigitOnes are the names from format_start_digits.asm.
; ASCII_DIGIT_BASE is the name from write_indexed_names_and_count.asm.
; FinishFrame, CallBankedHL, MulCByB, and FormatStartDigits are already
; source.

; Entry index walked from 0 through 4.
DEF wEntryIndex EQU $CDD6

; Five present-flags, then the two bytes stored from $A11D.
DEF wEntryFlags EQU $D09B
DEF wEntryFlagCount EQU $05
DEF wEntrySumCount EQU $07

; [$A11D] + 1, then a cleared byte. Both sit in the seven-byte sum.
DEF wEntryA11DPlus1 EQU $D0A0

; Byte read while SRAM bank $C727 is enabled. What it counts is unknown.
DEF sUnknownA11D EQU $A11D

; Three ASCII digits for each of the five slots. Filled with spaces first.
DEF wEntryDigits EQU $D054
DEF ENTRY_DIGIT_BYTES EQU $0F
DEF ENTRY_SPACE EQU $20

; Word inside an entry record that FormatStartDigits turns into digits.
DEF ENTRY_DIGIT_WORD EQU $07

; Compared with 9 to pick which five mask bytes can clear the flags.
DEF wUnknownD063 EQU $D063
DEF wEntryMask EQU $D37A
DEF ENTRY_MASK_ALT EQU $05
DEF ENTRY_MASK_CLEAR EQU $02

; Chosen slot. $FE means none of the seven summed bytes was set.
DEF wChosenSlot EQU $CCA7
DEF CHOSEN_SLOT_NONE EQU $FE

; Script records written at $C71B. Bank 2, then a pointer, then $66 $0A.
DEF wScriptC71BRecord EQU $C71B
DEF SCRIPT_BANK_02 EQU $02
DEF SCRIPT_TAIL_66 EQU $66
DEF SCRIPT_TAIL_0A EQU $0A

; One id at sEntryIds[wEntryIndex]. \1 is the flag, \2 the digit dest.
; \3 is 1 when this slot advances wEntryIndex.
MACRO load_one_entry
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wEntryIndex]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc
    ld a, [hl]
    cp $ff
    ld b, a
    jr z, .noId\@
    ld b, a
    ld c, ENTRY_STRIDE
    call MulCByB
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld bc, sEntryBase
    add hl, bc
    ld b, [hl]
.noId\@
    xor a
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, b
    cp $ff
    jr z, .absent\@
    ld a, $01
    ld [\1], a
    ld c, ENTRY_DIGIT_WORD
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld hl, \2
    ld a, [wStartDigitHundreds]
    add ASCII_DIGIT_BASE
    ld [hl+], a
    ld a, [wStartDigitTens]
    add ASCII_DIGIT_BASE
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add ASCII_DIGIT_BASE
    ld [hl+], a
.absent\@
    IF \3
        ld hl, wEntryIndex
        inc [hl]
    ENDC
ENDM

LoadFiveSramEntryDigits::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, $01
    ld [wSetupD0C0], a
    ld a, $04
    ld [wUnknownCD81], a
    xor a
    ld [wEntryIndex], a
    ld hl, wScriptC71BRecord
    ld a, SCRIPT_BANK_02
    ld [hl+], a
    ld a, $ba
    ld [hl+], a
    ld a, $5c
    ld [hl+], a
    ld a, SCRIPT_TAIL_66
    ld [hl+], a
    ld a, SCRIPT_TAIL_0A
    ld [hl+], a
.waitC6EEZero:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .scriptAt5CB8
    call FinishFrame
    jr .waitC6EEZero
.scriptAt5CB8:
    ld hl, wScriptC71BRecord
    ld a, SCRIPT_BANK_02
    ld [hl+], a
    ld a, $b8
    ld [hl+], a
    ld a, $5c
    ld [hl+], a
    ld a, SCRIPT_TAIL_66
    ld [hl+], a
    ld a, SCRIPT_TAIL_0A
    ld [hl+], a
.waitC6EETwo:
    ld a, [wUnknownC6EE]
    cp $02
    jr z, .afterScripts
    call FinishFrame
    jr .waitC6EETwo
.afterScripts:
    ld hl, $5385
    ld e, $06
    call CallBankedHL
    ld a, ENTRY_SPACE
    ld hl, wEntryDigits
    ld b, ENTRY_DIGIT_BYTES
.fillSpaces:
    ld [hl+], a
    dec b
    jr nz, .fillSpaces
    xor a
    ld hl, wEntryFlags
    ld b, wEntryFlagCount
.clearFlags:
    ld [hl+], a
    dec b
    jr nz, .clearFlags
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [sUnknownA11D]
    push af
    xor a
    ld [rRAMG], a
    pop af
    inc a
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    load_one_entry wEntryFlags, wEntryDigits, 1
    load_one_entry wEntryFlags + 1, wEntryDigits + 3, 1
    load_one_entry wEntryFlags + 2, wEntryDigits + 6, 1
    load_one_entry wEntryFlags + 3, wEntryDigits + 9, 1
    load_one_entry wEntryFlags + 4, wEntryDigits + 12, 0
    xor a
    ld [rRAMG], a
    ld c, $00
    ld a, [wUnknownD063]
    cp $09
    jr nz, .maskAtD37A
    ld c, ENTRY_MASK_ALT
.maskAtD37A:
    ld b, $00
    ld hl, wEntryMask
    add hl, bc
    ld bc, wEntryFlags
    ld d, wEntryFlagCount
.maskOne:
    ld a, [hl+]
    cp ENTRY_MASK_CLEAR
    jr nz, .maskNext
    xor a
    ld [bc], a
.maskNext:
    inc bc
    dec d
    jr nz, .maskOne
    ld hl, wEntryFlags
    ld d, wEntrySumCount
    xor a
.sumFlags:
    add [hl]
    inc hl
    dec d
    jr nz, .sumFlags
    and a
    jr nz, .pastRet
    ld a, CHOSEN_SLOT_NONE
    ld [wChosenSlot], a
    ret

.pastRet:
