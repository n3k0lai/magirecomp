; Bank 0 at $25FA. PlantOffset7ThenStoreFF lands here when wLCDC is
; nonzero. PlantScriptPtrReadSramByte has just returned: DE is the
; record word, C is the SRAM byte at that word, B is the record's third
; byte, and HL is three bytes past the record. wLCDC is the name from
; turn_off_lcd.asm.
;
; B AND C nonzero plants hScriptBank $22 and hScriptPtr $405B, then
; returns. Zero continues. BC and DE are saved. $C921, named
; wSoundSlotA later in select_sound_command.asm, becomes $11. The next
; two bytes at HL fill wBank7ArgC9FC and the byte after it, and
; wBank7ArgC9FC + 2 becomes 1. HL is saved.
;
; Bank 7 is written to wCurrentROMBank and rROMB0, then CopyThreeBank7
; ($7350) runs. hScriptBank is written back with the 3-byte load. HL is
; restored. The word at $C93D becomes $C949. $C93D is wUnknownC93D and
; $C949 is wListTailDest in setup_command_4d.asm, which is included
; later.
;
; A zero byte at wBank7ArgC9FC + 1 drops the two saved pairs and plants
; hScriptBank $22 with hScriptPtr $4074, then returns. Any other value
; plants hScriptBank $22 with hScriptPtr $4048, restores DE and BC,
; enables SRAM, writes B OR C over the byte at DE, and disables SRAM.
; E becomes $FF and control jumps to StoreEThroughWordInWram3.
;
; wBank7ArgC9FC and CopyThreeBank7 are the names from
; copy_three_c9fc_bank7.asm. hScriptBank, hScriptPtr, wCurrentROMBank,
; rROMB0, and rRAMG are the names from reset.asm. SRAM_ENABLE is the
; name from handle_start_press.asm. StoreEThroughWordInWram3 is the
; name from store_e_through_word.asm.

; Script bank shared by the three exits.
DEF OFFSET7_SCRIPT_BANK EQU $22

; Planted when the bank 7 byte at wBank7ArgC9FC + 1 is nonzero.
DEF OFFSET7_SCRIPT_OR EQU $4048

; Planted when B AND C is nonzero, before the bank 7 call.
DEF OFFSET7_SCRIPT_AND EQU $405B

; Planted when the bank 7 byte at wBank7ArgC9FC + 1 comes back zero.
DEF OFFSET7_SCRIPT_ZERO EQU $4074

; Stored at $C921 before the bank 7 call. Role still unknown.
DEF OFFSET7_SLOT_A EQU $11

; Word written at $C93D after the bank 7 call. Role still unknown.
DEF OFFSET7_TAIL_PTR EQU $C949

LCDOnAfterOffset7Record::
    ld a, b
    and c
    jp nz, .plantScriptAnd

    push bc
    push de
    ld a, OFFSET7_SLOT_A
    ld [$c921], a
    ld a, [hl+]
    ld [wBank7ArgC9FC], a
    ld a, [hl+]
    ld [wBank7ArgC9FC + 1], a
    ld a, $01
    ld [wBank7ArgC9FC + 2], a
    push hl
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call CopyThreeBank7
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop hl
    ld a, LOW(OFFSET7_TAIL_PTR)
    ld [$c93d], a
    ld a, HIGH(OFFSET7_TAIL_PTR)
    ld [$c93e], a
    ld a, [wBank7ArgC9FC + 1]
    and a
    jr z, .plantScriptZero

    ld a, OFFSET7_SCRIPT_BANK
    ldh [hScriptBank], a
    ld a, LOW(OFFSET7_SCRIPT_OR)
    ldh [hScriptPtr], a
    ld a, HIGH(OFFSET7_SCRIPT_OR)
    ldh [hScriptPtr + 1], a
    pop de
    pop bc
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, b
    or c
    ld [de], a
    xor a
    ld [rRAMG], a
    ld e, $ff
    jp StoreEThroughWordInWram3

.plantScriptAnd:
    ld a, OFFSET7_SCRIPT_BANK
    ldh [hScriptBank], a
    ld a, LOW(OFFSET7_SCRIPT_AND)
    ldh [hScriptPtr], a
    ld a, HIGH(OFFSET7_SCRIPT_AND)
    ldh [hScriptPtr + 1], a
    ret

.plantScriptZero:
    pop af
    pop af
    ld a, OFFSET7_SCRIPT_BANK
    ldh [hScriptBank], a
    ld a, LOW(OFFSET7_SCRIPT_ZERO)
    ldh [hScriptPtr], a
    ld a, HIGH(OFFSET7_SCRIPT_ZERO)
    ldh [hScriptPtr + 1], a
    ret
