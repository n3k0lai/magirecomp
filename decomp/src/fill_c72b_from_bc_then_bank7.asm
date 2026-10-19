; Bank 0 at $2EC3. LoadFiveBankedMapSources calls this with BC pointing
; at the first banked source, while that source's bank is mapped.
;
; CopyWordPairs writes $20 word pairs from BC into $C72B. $07 is stored
; at wUnknownC9D8. Bank 7 is mapped, and RunPanelIndexThrough2EB6 uses
; that index. Bank 7 is stored again, then CopyC7ABToBGPalettes runs.
; $2EDA and $2EDD are the two bank-7 calls. $2EE9, still INCBIN, is the
; sibling that fills $C76B and calls $44EA.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. wUnknownC9D8
; is the name from indexed_tail_07.asm. CopyWordPairs,
; RunPanelIndexThrough2EB6, and CopyC7ABToBGPalettes are already source.
; $C72B is still unnamed.

FillC72BFromBCThenBank7::
    ld hl, $C72B
    ld e, $00
    ld a, $20
    call CopyWordPairs
    ld a, $07
    ld [wUnknownC9D8], a
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a

CallBank7PanelIndex::
    call RunPanelIndexThrough2EB6

RemapBank7AndCopyBGPalettes::
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call CopyC7ABToBGPalettes
    ret
