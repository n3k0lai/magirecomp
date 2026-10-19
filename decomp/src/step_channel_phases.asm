; UpdateSound calls this at $551E while ROM bank $30 stays mapped.
;
; Channel flags are the four bytes at $DF0D. The walk starts at $DF10
; with E = 4 and steps HL down, so the last pass is $DF0D with E = 1.
; Bits 0, 1, and 3 of the flag select a phase update. Any other value
; is skipped. E is then the channel index 3-0, doubled into a word index.
;
; Each channel keeps a script pointer at $DF58 (a word), a 16-bit phase
; at $DF60, a 16-bit step at $DF68, and the level last written to $DF70.
; Bit 5 of the flag is set when that level changes. The three updates:
;
; Bit 0, phase high still below $0F: add the step into the phase and
; store the new high byte at $DF70.
; Bit 0, phase high at least $0F: clamp the phase to $0F00 and $DF70 to
; $0F. If flag bit 4 is set, clear it and leave the script alone.
; Otherwise force the low nibble to 2, copy the next script word into
; the step, advance the pointer by 2, and fall into the bit 1 test.
; Bit 1: the byte at the script pointer is a target. If the phase high
; byte is below that target and bit 7 of the phase high is clear, keep
; adding the step (the bit 0 path). Otherwise snap the phase to
; target*$100, copy the following script word into the step, store the
; target at $DF70, and force the low nibble to 4.
; Bit 3: add the step. A result whose high byte has bit 7 set, or a
; zero result, clears $DF70 and the flag's low nibble. Otherwise the
; high byte is stored at $DF70.

DEF wChannelFlags EQU $DF0D
DEF wPhaseScript EQU $DF58
DEF wPhaseValue EQU $DF60
DEF wPhaseStep EQU $DF68
DEF wPhaseLevel EQU $DF70

StepChannelPhases:
    ld de, $0004
    ld hl, wChannelFlags + 3

.next_flag:
    ld a, [hl]
    and $0b
    jr nz, .active

.advance:
    dec hl
    dec e
    jr nz, .next_flag
    ret

.active:
    push hl
    push de
    dec e
    sla e
    bit 1, a
    jr nz, .read_target

    bit 3, a
    jp nz, .slide

    ld hl, wPhaseValue + 1
    add hl, de
    ld a, [hl]
    cp $0f
    jr nc, .at_cap

.integrate:
    ld hl, wPhaseStep
    add hl, de
    ld a, [hl+]
    ld b, [hl]
    ld hl, wPhaseValue
    add hl, de
    add [hl]
    ld [hl+], a
    ld a, [hl]
    adc b
    ld [hl], a
    srl e
    ld hl, wPhaseLevel
    add hl, de
    ld c, [hl]
    ld [hl], a
    cp c
    jr z, .pop_advance

    pop de
    pop hl
    set 5, [hl]
    jr .advance

.pop_advance:
    pop de
    pop hl
    jr .advance

.at_cap:
    ld a, $0f
    ld [hl-], a
    ld [hl], $00
    srl e
    ld hl, wPhaseLevel
    add hl, de
    ld a, [hl]
    ld [hl], $0f
    ld hl, wChannelFlags
    add hl, de
    cp $0f
    jr z, .cap_flags

    set 5, [hl]

.cap_flags:
    ld a, [hl]
    and $f0
    bit 4, a
    jr z, .load_segment

    res 4, a
    ld [hl], a
    pop de
    pop hl
    jr .advance

.load_segment:
    or $02
    ld [hl], a
    sla e
    ld hl, wPhaseScript
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    ld b, [hl]
    ld hl, wPhaseStep
    add hl, de
    ld [hl+], a
    ld [hl], b
    ld hl, wPhaseScript
    add hl, de
    ld a, [hl]
    add $02
    ld [hl+], a
    ld a, [hl]
    adc $00
    ld [hl], a

.read_target:
    ld hl, wPhaseScript
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl]
    ld hl, wPhaseValue + 1
    add hl, de
    ld b, [hl]
    bit 7, b
    jr nz, .snap_target

    cp b
    jr c, .integrate

.snap_target:
    ld [hl-], a
    ld [hl], $00
    ld c, a
    ld hl, wPhaseScript
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [hl+]
    ld b, [hl]
    ld hl, wPhaseStep
    add hl, de
    ld [hl+], a
    ld [hl], b
    srl e
    ld hl, wPhaseLevel
    add hl, de
    ld a, [hl]
    ld [hl], c
    ld hl, wChannelFlags
    add hl, de
    cp c
    jr z, .mark_segment

    set 5, [hl]

.mark_segment:
    ld a, [hl]
    and $f0
    or $04
    ld [hl], a

.pop_and_advance:
    pop de
    pop hl
    jp .advance

.slide:
    ld hl, wPhaseStep
    add hl, de
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, wPhaseValue
    add hl, de
    ld a, [hl]
    add c
    ld [hl+], a
    ld c, a
    ld a, [hl]
    adc b
    ld [hl], a
    ld b, a
    srl e
    ld hl, wPhaseLevel
    add hl, de
    bit 7, a
    jr nz, .clear_level

    or c
    jr z, .clear_level

    ld a, [hl]
    ld [hl], b
    cp b
    jr z, .pop_and_advance

    pop de
    pop hl
    set 5, [hl]
    jp .advance

.clear_level:
    ld c, [hl]
    ld [hl], $00
    pop de
    pop hl
    ld a, [hl]
    and $f0
    ld [hl], a
    ld a, c
    and a
    jp z, .advance

    set 5, [hl]
    jp .advance
