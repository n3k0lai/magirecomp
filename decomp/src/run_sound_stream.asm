; RunSoundStream ($5032). StepSoundStreams calls this with the stream
; pointer in HL while ROM bank $30 stays mapped.
;
; The command byte at HL is consumed and the advanced pointer is stored
; at $DF9A. That byte indexes the word table at $4DA6. The looked-up
; address is called through the `jp hl` at $505B. Command $04 returns
; after that call. Any other command continues from the pointer now at
; $DF9A. A zero pointer ends the walk.

RunSoundStream:
.command:
    ld a, [hl+]
    cp $04
    push af
    ld c, l
    ld b, h
    ld hl, wSoundStreamCursor
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, SoundCommandTable
    sla a
    add l
    ld l, a
    ld a, h
    adc $00
    ld h, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call $505B
    pop af
    ret z

    ld hl, wSoundStreamCursor
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    or h
    jr nz, .command
    ret
