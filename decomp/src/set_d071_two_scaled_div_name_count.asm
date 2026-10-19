; Bank 2 at $49DE. [$D071] is set to 2.
;
; MaskDivByC with C = 7 returns rDIV masked to 0–7. One is added, then
; the byte is doubled twice, so A is 4, 8, …, or 32. That value is
; stored at [$D077]. [$D070] and [$D076] are both set to 1, so
; WriteIndexedNamesAndCount prints [$D077] as the name count.
;
; MaskDivByC is already source. rDIV is the name from mask_div_by_c.asm.
; wNameCountFlag and wNameCountAlt are the names from
; write_indexed_names_and_count.asm.

SetD071TwoScaledDivNameCount::
    ld a, $02
    ld [$D071], a
    ld c, $07
    call MaskDivByC
    inc a
    add a, a
    add a, a
    ld [$D077], a
    ld a, $01
    ld [$D070], a
    ld [$D076], a
    ret
