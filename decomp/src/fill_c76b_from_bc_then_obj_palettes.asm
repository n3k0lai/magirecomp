; Bank 0 at $2EE9. CallScriptBankedPtrThenCall2EE9 maps a script bank and
; calls here with BC pointing at a block in that bank.
;
; CopyWordPairs writes $20 word pairs from BC into $C76B. $87 is stored
; at wUnknownC9D8. Bank 7 is mapped, and RunPanelIndexThrough2EB6 uses
; that index: high nibble $08 selects the block just written at $C76B,
; and low nibble $07 copies it $80 bytes ahead to the object palettes
; at $C7EB. Bank 7 is stored again, then CopyC7EBToOBJPalettes runs.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. wUnknownC9D8
; is the name from indexed_tail_07.asm. CopyWordPairs,
; RunPanelIndexThrough2EB6, and CopyC7EBToOBJPalettes are already source.
; $C76B is still unnamed.

FillC76BFromBCThenOBJPalettes::
    ld hl, $C76B
    ld e, $00
    ld a, $20
    call CopyWordPairs
    ld a, $87
    ld [wUnknownC9D8], a
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a

ApplyIndex87ThroughPanel::
    call RunPanelIndexThrough2EB6

RemapBank7AndCopyOBJPalettes::
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call CopyC7EBToOBJPalettes
    ret
