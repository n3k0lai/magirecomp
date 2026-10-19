; Park all 40 sprites below the screen.
;
; default_state.asm calls this address as HideSprites. An OAM entry is
; 4 bytes, and Y is the first byte. $0568 loads the count, 40, and expects
; the stride in DE. $056A takes that count in A. The shadow pass writes
; $FF to that many Y bytes at $C000. The OAM pass writes $FF to 40 Y bytes
; at $FE00. Y = $FF sits below the visible picture.
;
; A is $FF and B is 0 on return. DE still holds the stride. HL is $FEA0,
; the address after the last OAM byte.

DEF wShadowOAM EQU $C000
DEF OAMRAM EQU $FE00
DEF OAM_STRIDE EQU 4
DEF SPRITE_COUNT EQU 40
DEF SPRITE_OFFSCREEN_Y EQU $FF

ParkSprites::
    ld de, OAM_STRIDE
; $0568. DE is the stride between Y bytes.
.stride:
    ld a, SPRITE_COUNT
; $056A. A is how many shadow-buffer entries to park. DE is the stride.
.count:
    ld b, a
    ld hl, wShadowOAM
    ld a, SPRITE_OFFSCREEN_Y
.shadow:
    ld [hl], a
    add hl, de
    dec b
    jr nz, .shadow
    ld a, SPRITE_COUNT
    ld b, a
    ld hl, OAMRAM
    ld a, SPRITE_OFFSCREEN_Y
.oam:
    ld [hl], a
    add hl, de
    dec b
    jr nz, .oam
    ret
