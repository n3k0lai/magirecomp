; PrimeChannelFromTag and the record walker at $4F44 call this at
; $4DFA. ROM bank $30 stays mapped. A is a tag, B is a priority, C is a
; channel hint, and D is saved at $DFFE for the period fold below.
;
; The tag indexes a word in the directory at $5A88. That word is an
; offset from the same base to a record. A record whose first byte is
; not $0E keeps C. A record that starts with $0E reads the next byte:
;   bit 4 set: bit 7 of that byte is kept in C, and bit 0 of C becomes
;     bit 5 of $DFA6. Bit 6 of $DFA6 is set on the first such record,
;     with bit 5 taken from bit 0 of the incoming C. Bit 5 is then
;     toggled, and the bit that was there is written back into C.
;   $FF: C keeps its low bits and gains bit 7
;   anything else: C is replaced with that byte
;
; Bit 7 of C jumps to $4EDE and returns from there. C = 2 compares B
; with the byte at $DF9F. When B is at least that byte, bit 6 of $DF74
; stops the timer and clears the timer bits of rIE and rIF ($1B keeps
; the other enables). $DF74 is then cleared.
;
; $4EDE returns Z when it rejects B, and also when the channel index is
; 0. This returns Z in both cases. A nonzero channel stores $0F at
; $DF70 and zero at $DF09 and $DF0D. Channel 3 skips the slide words.
; When the saved D is zero, the words at $DF15 and $DF23 are added into
; $DF29. $DF1D and $DF23 are cleared, then $DF15 is cleared. The byte
; at $4EDA indexed by the channel is ORed into $DF11, DropChannelOutput
; runs, and rlca leaves that routine's A and flags for the caller.

DEF wSavedTagParam EQU $DFFE
DEF wTagPriorityLimit EQU $DF9F
DEF wPeriodSum EQU $DF23
DEF wFoldedPeriod EQU $DF29
DEF wChannelOwnMask EQU $DF11

OpenChannelForTag:
    ld e, a
    ld a, d
    ld [wSavedTagParam], a
    ld d, $00
    sla e
    rl d
    ld hl, SoundStreamTable
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    ld hl, SoundStreamTable
    add hl, de
    ld a, [hl]
    cp $0e
    jr nz, .have_channel

    inc hl
    ld a, [hl+]
    bit 4, a
    jr z, .plain_channel

    and $80
    ld e, a
    ld a, [wCountdownFlags]
    bit 6, a
    jr nz, .mix_flag_bit

    set 6, a
    ld d, a
    ld a, c
    and $01
    sla a
    swap a
    or d
    ld [wCountdownFlags], a

.mix_flag_bit:
    ld d, a
    swap a
    srl a
    and $01
    or e
    ld c, a
    ld a, d
    xor $20
    ld [wCountdownFlags], a
    jr .have_channel

.plain_channel:
    cp $ff
    jr nz, .store_channel

    ld a, $80
    or c

.store_channel:
    ld c, a

.have_channel:
    bit 7, c
    jp nz, InstallTagStream

    ld a, c
    cp $02
    jr nz, .install

    ld a, [wTagPriorityLimit]
    ld e, a
    ld a, b
    cp e
    jr c, .install

    ld a, [wSoundFlags]
    bit 6, a
    jr z, .clear_sound_flags

    xor a
    ldh [rTAC], a
    ldh a, [rIE]
    and $1b
    ldh [rIE], a
    ldh a, [rIF]
    and $1b
    ldh [rIF], a

.clear_sound_flags:
    xor a
    ld [wSoundFlags], a

.install:
    call InstallTagStream
    ret z

    ld hl, wPhaseLevel
    add hl, bc
    ld [hl], $0f
    ld hl, wChannelSlideFlags
    add hl, bc
    ld [hl], a
    ld hl, wChannelFlags
    add hl, bc
    ld [hl], a
    sla c
    ld a, c
    cp $06
    jr z, .clear_period

    ld a, [wSavedTagParam]
    and a
    jr nz, .clear_slide_words

    ld hl, wSlideSumA
    add hl, bc
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld hl, wPeriodSum
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld e, l
    ld d, h
    ld hl, wFoldedPeriod
    add hl, bc
    ld a, e
    ld [hl+], a
    ld [hl], d

.clear_slide_words:
    xor a
    ld hl, wSlideSumB
    add hl, bc
    ld [hl+], a
    ld [hl], a
    ld hl, wPeriodSum
    add hl, bc
    ld [hl+], a
    ld [hl], a

.clear_period:
    xor a
    ld hl, wSlideSumA
    add hl, bc
    ld [hl+], a
    ld [hl], a
    srl c
    ld hl, ChannelOwnMasks
    add hl, bc
    ld a, [wChannelOwnMask]
    or [hl]
    ld [wChannelOwnMask], a
    push bc
    call DropChannelOutput
    pop bc
    rlca
    ret
