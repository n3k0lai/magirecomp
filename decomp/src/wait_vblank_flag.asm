; Set bit 7 of hVBlankFlags and wait until that bit is clear.
;
; FinishFrame and the routine at $095F store 7 first, so the byte becomes
; $87. The VBlank handler then clears the whole byte. halt waits for an
; interrupt; nop is the following byte. The loop polls bit 7 until it is
; clear. hVBlankFlags is the name from draw_cgb_notice.asm.

WaitVBlankFlag::
    ldh a, [hVBlankFlags]
    set 7, a
    ldh [hVBlankFlags], a
    halt
    nop
.wait:
    ldh a, [hVBlankFlags]
    bit 7, a
    jr nz, .wait
    ret
