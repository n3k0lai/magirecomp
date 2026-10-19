; Queue one sprite list into the shadow OAM, or return if it is off the map.
;
; HL points at 4-byte records: relative Y, relative X, tile offset, and
; attributes. A relative Y of $80 ends the list. Kept records are written
; at wShadowOAM plus the low byte in wShadowOAMCursor, in OAM order
; (Y, X, tile, attributes). The cursor is stored back afterward.
;
; $FF91 and $FF92 are the object's map cell. $FF8F and $FF90 are pixel
; offsets inside that cell. $C85F and $C860 are the camera column and row.
; The object stays when its cell is in [column-2, column+11] and
; [row-2, row+10]. A miss returns before any sprite is written.
;
; $FF97 is copied to $FF98, then set to $FF. When the object is kept,
; $FF97 becomes its screen Y and $FF96 its screen X. Screen X is
; cellX * 16 + 8 + fine X - $C935. Screen Y is cellY * 16 + 16 + fine Y
; - $C934. The +8 and +16 are the OAM origin. $FF95 is added to each
; record's tile byte.
;
; $0587 skips the copy of $FF97. $05A3 continues the row test with A
; already holding row-2. $05B0 is that test's `ret z`. $05D1 adds the
; OAM Y origin in B, and $05D2 stores the sum. $05DB is the copy loop.
; $0618, still INCBIN, jumps there with D and E already the X and Y bases.
; $05EC continues after the X byte has been stored.

DEF hObjectFineX EQU $FF8F
DEF hObjectFineY EQU $FF90
DEF hObjectCellX EQU $FF91
DEF hObjectCellY EQU $FF92
DEF hSpriteTileBase EQU $FF95
DEF hSpriteScreenX EQU $FF96
DEF hSpriteScreenY EQU $FF97
DEF hPrevSpriteScreenY EQU $FF98
DEF wCameraPixelY EQU $C934
DEF wCameraPixelX EQU $C935
DEF wMapRow EQU $C860
DEF SPRITE_LIST_END EQU $80
DEF OAM_ORIGIN_X EQU 8
DEF OAM_ORIGIN_Y EQU 16

QueueSpriteList::
    ldh a, [hSpriteScreenY]
    ldh [hPrevSpriteScreenY], a
; $0587. The previous screen Y stays where the caller left it.
.havePrevY:
    ld a, $ff
    ldh [hSpriteScreenY], a
    ld a, [wMapColumn]
    add $fe
    ld c, a
    ld a, [hObjectCellX]
    ld d, a
    sub c
    bit 7, a
    ret nz

    add $f2
    bit 7, a
    ret z

    ld a, [wMapRow]
    add $fe
; $05A3. A is already row minus 2.
.rowWindow:
    ld c, a
    ld a, [hObjectCellY]
    ld e, a
    sub c
    bit 7, a
    ret nz

    add $f3
    bit 7, a
; $05B0. Return when the row window's high bit is clear.
.rowInside:
    ret z

    ld a, [wCameraPixelX]
    ld c, a
    ld a, d
    add a
    add a
    add a
    add a
    ld b, OAM_ORIGIN_X
    add b
    ld b, a
    ld a, [hObjectFineX]
    add b
    sub c
    ld d, a
    ldh [hSpriteScreenX], a
    ld a, [wCameraPixelY]
    ld c, a
    ld a, e
    add a
    add a
    add a
    add a
    ld b, OAM_ORIGIN_Y
; $05D1. B holds the OAM Y origin, 16.
.addOriginY:
    add b
; $05D2. B takes the cell Y in pixels, before the camera subtract.
.haveCellY:
    ld b, a
    ld a, [hObjectFineY]
    add b
    sub c
    ld e, a
    ldh [hSpriteScreenY], a
; $05DB. D is screen X and E is screen Y. Copy until a record Y of $80.
.copyList:
    ld b, HIGH(wShadowOAM)
    ld a, [wShadowOAMCursor]
    ld c, a
.next:
    ld a, [hli]
    cp SPRITE_LIST_END
    jr z, .storeCursor

    add e
    ld [bc], a
    inc c
    ld a, [hli]
    add d
    ld [bc], a
; $05EC. BC is the next OAM byte and HL points at the tile offset.
.afterX:
    inc c
    ldh a, [hSpriteTileBase]
    add [hl]
    inc hl
    ld [bc], a
    inc c
    ld a, [hli]
    ld [bc], a
    inc c
    jr .next

.storeCursor:
    ld a, c
    ld [wShadowOAMCursor], a
    ret
