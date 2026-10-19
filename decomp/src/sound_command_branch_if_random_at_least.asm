; Random branch: operand 0 is a threshold. When StepDf03 returns at least
; that, SoundCommand06 takes the 2-byte branch; otherwise the branch operand
; is skipped and the cursor saved past it.

SoundCommandBranchIfRandomAtLeast::
    ld a, [bc]
    ld e, a
    inc bc
    call StepDf03
    cp e
    jp nc, SoundCommand06
    inc bc
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret
