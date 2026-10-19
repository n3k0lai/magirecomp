; Bank 2 at $4AE6. A is bank $4C and BC is $4D35.
; StagePointerUnlessD0B6Matches returns immediately when [$D0B6]
; equals [$D103]; otherwise it plants that bank and pointer.
; Bank $4C at $4D35 is file $0130D35 and is still INCBIN.
;
; MaskDivByC with C = 7 returns rDIV masked to 0–7. One is added, then
; the byte is doubled, so A is 2, 4, …, or 16. That value is stored at
; [$D077]. [$D070] and [$D076] are both set to 1, so
; WriteIndexedNamesAndCount prints [$D077] as the name count.
;
; StagePointerUnlessD0B6Matches and MaskDivByC are already source.
; rDIV is the name from mask_div_by_c.asm. wNameCountFlag and
; wNameCountAlt are the names from write_indexed_names_and_count.asm.

Stage4D35ThenScaledDivNameCount::
    ld a, $4C
    ld bc, $4D35
    call StagePointerUnlessD0B6Matches
    ld c, $07
    call MaskDivByC
    inc a
    add a, a
    ld [$D077], a
    ld a, $01
    ld [$D070], a
    ld [$D076], a
    ret

Stage4D35ThenScaledDivNameCountEnd:
