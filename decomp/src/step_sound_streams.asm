; UpdateSound calls this at $5006 while ROM bank $30 stays mapped.
;
; Four stream words sit at $DF7E, spaced two bytes apart (indexes 0-3).
; A zero word is skipped. Otherwise the index is stored at $DF9C and
; $5032, still INCBIN, runs that stream. The callee leaves the advanced
; pointer in $DF9A; this routine writes that word back into the slot.
; The walk ends when the byte index reaches 6, after that last slot.

DEF wSoundStreamPointers EQU $DF7E
DEF wSoundStreamCursor EQU $DF9A
DEF wSoundStreamIndex EQU $DF9C

StepSoundStreams:
    ld de, $0000

.next_stream:
    ld hl, wSoundStreamPointers
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    or h
    jr z, .store_done

    push de
    ld a, e
    srl a
    ld [wSoundStreamIndex], a
    call $5032
    pop de
    ld hl, wSoundStreamPointers
    add hl, de
    ld a, [wSoundStreamCursor]
    ld [hl+], a
    ld a, [wSoundStreamCursor + 1]
    ld [hl], a

.store_done:
    ld a, e
    cp $06
    ret z

    inc e
    inc e
    jr .next_stream
