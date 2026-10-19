; StepUpperSoundCountdowns calls this at $48DD when a slot's 24-bit
; count has expired and bit 1 of the channel flag at $DF09 is clear.
; ROM bank $30 stays mapped. The caller stored the channel index at
; $DF9C and left B = 0.
;
; The command just before this entry (still INCBIN) can fall into the
; sla below with A holding an operand other than $FF. B is then the
; high byte of that stream cursor.
;
; A doubled index selects the word at $DF86. A zero word is left alone.
; A nonzero word is copied to the stream cursor at $DF9A and to the
; stream pointer at $DF7E, and the word at $DF92 is cleared.
;
; Bit 7 of the channel flag at $DF0D is set. Bits 0, 1, 2, and 4 of
; that flag then decide the rest:
;   none of them set, or bit 4 set: return with bit 7 set
;   bit 2 set: store (B & $F0) | $08 over the flag and return
;   otherwise: keep the high nibble, force the low nibble to $08, and
;   copy one word into the phase step at $DF68. The word is read from
;   the script pointer at $DF58, plus 1 when flag bit 0 is clear and
;   plus 3 when it is set. Both of those tables are indexed by the
;   channel number itself.

ArmChannelAfterCountdown:
    ld a, [$DF9C]

.scale_index:
    sla a
    ld e, a
    ld d, $00
    ld hl, $DF86
    add hl, de
    ld a, [hl+]
    ld c, a
    or [hl]
    jr z, .mark_flag

    ld a, [hl]
    ld hl, $DF9B
    ld [hl-], a
    ld [hl], c
    ld hl, $DF7F
    add hl, de
    ld [hl-], a
    ld [hl], c
    ld hl, $DF92
    xor a
    ld [hl+], a
    ld [hl], a

.mark_flag:
    srl e
    ld hl, $DF0D
    add hl, de
    ld a, [hl]
    or $80
    ld [hl], a
    ld c, a
    and $17
    ret z

    bit 4, a
    ret nz

    bit 2, a
    jr z, .load_step

    ld a, b
    and $f0
    or $08
    ld [hl], a
    ret

.load_step:
    ld a, c
    and $f0
    or $08
    ld [hl], a
    bit 0, c
    ld bc, $0001
    jr z, .read_script

    ld bc, $0003

.read_script:
    ld hl, $DF58
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, [hl+]
    ld b, [hl]
    ld hl, $DF68
    add hl, de
    ld [hl+], a
    ld [hl], b
    ret
