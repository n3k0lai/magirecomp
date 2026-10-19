; Hide shadow-OAM sprites this frame did not rewrite, then reset the cursor.
;
; FinishFrame calls this after ROM bank 1's $407D. $095F, still INCBIN, also
; calls it. $C728 is the low byte of the next free slot in the shadow OAM at
; $C000. $C729 is that cursor from the previous pass. default_state.asm clears
; both during setup. Writers before this address, still INCBIN, store four-byte
; entries through $C728.
;
; A is the new cursor minus the old one. When the new cursor is at or past the
; old one, those slots were overwritten and the hide is skipped. Otherwise the
; gap is negated and divided by 4, the sprite stride. That many Y bytes, from
; the new cursor forward, are set to $FF so the leftover sprites sit off
; screen. $C729 then takes the new cursor and $C728 is cleared for the next
; pass.
;
; wShadowOAM, OAM_STRIDE, and SPRITE_OFFSCREEN_Y are the names from
; park_sprites.asm. Nothing in these notes calls $063B or $0644.

DEF wShadowOAMCursor EQU $C728
DEF wShadowOAMPrevEnd EQU $C729

HideLeftoverSprites::
    ld a, [wShadowOAMPrevEnd]
    ld b, a
    ld a, [wShadowOAMCursor]
    sub b
    jr nc, .remember
    cpl
    inc a
    srl a
    srl a
    ld e, a
    ld bc, OAM_STRIDE
    ld h, HIGH(wShadowOAM)
; $063B. HL is the first leftover sprite. E is how many to hide.
.hide:
    ld a, [wShadowOAMCursor]
    ld l, a
    ld a, SPRITE_OFFSCREEN_Y
.y_byte:
    ld [hl], a
    add hl, bc
    dec e
; $0644. The displacement is the loop back to .y_byte.
    jr nz, .y_byte
.remember:
    ld a, [wShadowOAMCursor]
    ld [wShadowOAMPrevEnd], a
    ld a, $00
    ld [wShadowOAMCursor], a
    ret
