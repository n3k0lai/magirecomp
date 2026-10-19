; Sound command with a 1-byte operand that is ignored: skip it and save the
; stream cursor past it.

SoundCommandSkipByte::
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret
