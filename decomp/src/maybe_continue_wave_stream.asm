; When bit 4 of wSoundFlags is set, tail-jump to $3B7C; otherwise return.

MaybeContinueWaveStream::
    ld hl, wSoundFlags
    bit 4, [hl]
    ret z
    jp $3B7C
