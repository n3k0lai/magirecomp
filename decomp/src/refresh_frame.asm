; Shorter sibling of FinishFrame. HandleStartPress calls here after it has
; already hidden leftover sprites.
;
; The WRAM bank at $C937 and the ROM bank are saved and restored. $C937 is
; wCurrentWRAMBank and $FF70 is rSVBK; both names are defined in
; timer_overflow.asm. Restoring $FF70 is the 3-byte form. The saved value is
; also written back to $C937.
;
; ROM bank 7 is mapped and $4CF5 and $5198 run. What those calls do is still
; unknown. $C843 and $C844, the horizontal and vertical scroll deltas, are
; cleared. HideLeftoverSprites runs, bank 7 is mapped again, and $5897 runs.
; hVBlankFlags is set to 7, and WaitVBlankFlag sets bit 7 and waits until
; that bit clears.
;
; wCurrentROMBank, rROMB0, and BANK_INIT are the names from reset.asm.
; hVBlankFlags is the name from draw_cgb_notice.asm.

RefreshFrame::
    ld a, [$c937]
    push af
    ld a, [wCurrentROMBank]
    push af
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $4cf5
    call $5198
    xor a
    ld [$c843], a
    ld [$c844], a
    call HideLeftoverSprites
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $5897
    ld a, $07
    ldh [hVBlankFlags], a
    call WaitVBlankFlag
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop af
    ld [$c937], a
    ld [$ff70], a
    ret
