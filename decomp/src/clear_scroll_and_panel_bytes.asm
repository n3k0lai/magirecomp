; Bank 4 at $629C. The loop at $632E calls this once $C9AE is
; nonzero, then returns. That loop is still INCBIN.
;
; $C9AF and $C9B0 are the scroll bytes LcdOffSetup copies to the camera
; and to rSCX and rSCY. The eight bytes at wPanelBytes ($C9B3-$C9BA) are
; the panel slots ApplyC9B3Bytes stages. Both are set here the same way
; ClearMapScrollBytes sets them: scroll to zero, panels to $F0.
;
; wScrollX ($C9AF) and wScrollY ($C9B0) are the names from
; lcd_off_setup.asm. wPanelBytes ($C9B3) is the name from
; stage_panel_glyph_dest.asm. Those constants are defined later, so
; the stores here use the addresses.

ClearScrollAndPanelBytes::
    xor a
    ld [$C9AF], a
    ld [$C9B0], a
    ld a, $F0
    ld [$C9B3], a
    ld [$C9B4], a
    ld [$C9B5], a
    ld [$C9B6], a
    ld [$C9B7], a
    ld [$C9B8], a
    ld [$C9B9], a
    ld [$C9BA], a
    ret
