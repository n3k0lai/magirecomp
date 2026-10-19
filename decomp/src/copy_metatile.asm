; DrawMetatileWindow calls this address as CopyMetatile, after
; BuildMetatilePointers. DE is the $9800 tilemap address of the top-left
; tile. HL is the definition in WRAM bank 2: four tile bytes, then four
; attribute bytes $400 later.
;
; A routine still in the INCBIN just above falls through to this entry
; after it has loaded those same two pointers.
;
; VRAM bank 0 receives the tiles and bank 1 the attributes. Each half is a
; 2x2 block. The second tile of a row is the next address (inc e; a metatile
; never starts on a low byte of $FF). C is $1F and B is 0, so adding BC from
; that second tile steps one BG row of 32 bytes. The last byte of each half
; is read with [hl], not [hl+].
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm. rVBK is
; the name from setup_window.asm. The WRAM shadow uses the 3-byte store.
; Both VRAM stores are ldh.

DEF METATILE_WRAM EQU $02
DEF METATILE_ROW_SKIP EQU $1F
DEF METATILE_ATTR_PAGE EQU $04

CopyMetatile2x2::
    ld a, METATILE_WRAM
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ldh [rVBK], a
    ld b, a
    ld c, METATILE_ROW_SKIP
    push de
    push hl
    ld a, [hli]
    ld [de], a
    inc e
    ld a, [hli]
    ld [de], a
    ld a, c
    add e
    ld e, a
    ld a, b
    adc d
    ld d, a
    ld a, [hli]
    ld [de], a
    inc e
    ld a, [hl]
    ld [de], a
    ld a, $01
    ldh [rVBK], a
    pop hl
    pop de
    ld a, METATILE_ATTR_PAGE
    add h
    ld h, a
    ld a, [hli]
    ld [de], a
    inc e
    ld a, [hli]
    ld [de], a
    ld a, c
    add e
    ld e, a
    ld a, b
    adc d
    ld d, a
    ld a, [hli]
    ld [de], a
    inc e
    ld a, [hl]
    ld [de], a
    ret
