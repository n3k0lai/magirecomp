; CopyTwelveWordPairsThenWriteC9E5. Bank 0 at $358E.
;
; DrawEntryFieldsVRAM0 calls this with BC from $C9D5 after that
; record's bank is already mapped. $C831 is cleared. CopyWordPairs
; doubles E and adds it to HL, then copies A words from BC. Here HL
; is $C72B, E is $00, and A is $0C, so twelve word pairs land at
; $C72B. ROM bank 7 is mapped and WriteC9E5WordAtSlots00And0C runs.
; $C831 is set to $01 before the return.
;
; $C831 and $C72B are still unnamed. wCurrentROMBank and rROMB0 are
; the names from reset.asm. CopyWordPairs is the name from
; copy_word_pairs.asm. WriteC9E5WordAtSlots00And0C is the name from
; write_c9e5_word_at_slots_00_and_0c.asm.

CopyTwelveWordPairsThenWriteC9E5::
    xor a
    ld [$C831], a
    ld hl, $C72B
    ld e, $00
    ld a, $0C
    call CopyWordPairs
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call WriteC9E5WordAtSlots00And0C
    ld a, $01
    ld [$C831], a
    ret
