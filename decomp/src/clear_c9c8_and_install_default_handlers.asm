; Bank 4 at $7413. Clears $C9C8, then installs the same two pointers
; SetupDefaultState writes at $084B: DefaultVBlank ($2A49) at
; wVBlankRoutine ($C6E2) and EmptyStatHandler ($2AB7) at
; hSTATHandler ($FF99). Both stores are the 3-byte form. This routine
; does not write rROMB0 and does not call out.
;
; wVBlankRoutine, DefaultVBlank, and EmptyStatHandler are the names from
; default_state.asm. hSTATHandler is the name from lcd_stat.asm. What
; $C9C8 means is still unknown.

ClearC9C8AndInstallDefaultHandlers::
    xor a
    ld [$C9C8], a
    ld a, LOW(DefaultVBlank)
    ld [wVBlankRoutine], a
    ld a, HIGH(DefaultVBlank)
    ld [wVBlankRoutine + 1], a
    ld a, LOW(EmptyStatHandler)
    ld [hSTATHandler], a
    ld a, HIGH(EmptyStatHandler)
    ld [hSTATHandler + 1], a
    ret
