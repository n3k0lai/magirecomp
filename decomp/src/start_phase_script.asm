; Start a phase script for slot C. HL points at a record: a step word, then
; the script. The script pointer goes to the slot's wPhaseScript word and the
; step to its wPhaseStep word. The wPhaseValue word at slot 0's position
; ($DF60) is cleared (not indexed), the slot's wPhaseLevel is cleared, and
; its wTagChannelFlags byte gets low nibble 1 with bit 5 set.

StartPhaseScript::
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    push de
    ld e, l
    ld d, h
    ld b, $00
    sla c
    ld hl, wPhaseScript
    add hl, bc
    ld a, e
    ld [hl+], a
    ld [hl], d
    pop de
    ld hl, wPhaseStep
    add hl, bc
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld hl, wPhaseValue
    xor a
    ld [hl+], a
    ld [hl], a
    srl c
    ld hl, wPhaseLevel
    add hl, bc
    ld [hl], a
    ld hl, wTagChannelFlags
    add hl, bc
    ld a, [hl]
    and $F0
    or $21
    ld [hl], a
    ret
