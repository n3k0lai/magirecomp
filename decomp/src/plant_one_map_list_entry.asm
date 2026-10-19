; Bank 3 at $6B43. SetupPrefixedBlockChoice calls here after the
; $52E5 tile copy, while this bank stays mapped.
;
; VRAM bank 0 is selected with the 3-byte store. The SRAM bank at $C727
; is stored to $4000 with `add a, $00` in between, which keeps that bank
; byte and sets flags nobody reads. SRAM is enabled, the word at $A3A5
; is loaded into DE, and SRAM is disabled. FormatStartDigits turns the
; low 10 bits of that word into the three places at $C92F, $C92E, and
; $C92D.
;
; $CCEC then receives one list entry: count $01, the map cell $9DCE
; stored high byte then low byte, and $FE. HL is left on the next byte.
; $6B0C reads those three digits and calls $77E7 with E=$EE for each.
; What $77E7 writes, and whether it uses HL, is still unknown.
;
; rVBK is the name from setup_window.asm. rRAMG is the name from
; reset.asm. FormatStartDigits is already source. $C727, $4000, and the
; enable value $0A are named wSRAMBank, rRAMB, and SRAM_ENABLE in
; handle_start_press.asm, which is included later, so this file uses
; those addresses. $6B0C is still INCBIN.

; SRAM word formatted into the three digit bytes.
DEF sDigitWordA3A5 EQU $A3A5

; BG map cell stored in the list, high byte first.
DEF vMapCell9DCE EQU $9DCE

; One-entry list. The walker at $6C1A reads the count, then the pointer.
DEF wOneEntryList EQU $CCEC

DEF LIST_COUNT_ONE EQU $01
DEF LIST_BYTE_FE EQU $FE

; Still INCBIN in this bank.
DEF Bank3_6B0C EQU $6B0C

PlantOneMapListEntry::
    xor a
    ld [rVBK], a
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    ld a, $0A
    ld [rRAMG], a
    ld hl, sDigitWordA3A5
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    xor a
    ld [rRAMG], a
    call FormatStartDigits
    ld hl, vMapCell9DCE
    ld b, h
    ld c, l
    ld hl, wOneEntryList
    ld [hl], LIST_COUNT_ONE
    inc hl
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    ld [hl], LIST_BYTE_FE
    inc hl
    call Bank3_6B0C
    ret

PlantOneMapListEntryEnd:
