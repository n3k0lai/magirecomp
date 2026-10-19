; SoundSlotA calls this at $4F44 with A from $C921, B = $0F, and C = $01.
; ROM bank $30 stays mapped. Other callers may pass a different BC.
;
; A indexes a 4-byte record. The limit byte is at $5A7D. An index at or
; above that limit returns A = 0 and Z. Otherwise the little-endian word
; at $5A7B is added to the shared base at $5A79, then the index times 4
; selects the record.
;
; Byte 0 is the tag and byte 1 is the priority passed to
; OpenChannelForTag with C = 0 and D = 1. A Z return from that call
; drops the saved BC and returns A = 0.
;
; On NZ, C is the channel it opened. Bit 1 and bit 5 of [$DF09 + C] are
; set, and bit 5 of [$DF0D + C] is set. Byte 2 is stored as the high
; byte of the period word at [$DF15 + C * 2]; the low byte is cleared.
;
; The envelope nibble is the caller's B, unless bit 7 of that B is set,
; in which case it is record byte 3. LookupChannelNibble combines that
; nibble with the high nibble of $DFF8, and the result is stored at
; [$DFF4 + C]. The channel is written to $DF9C. When the caller's C is
; not $FF, $4690 runs with that byte in A.
;
; $DFA5 holds the last companion id. The next id skips 0 and any value
; already stored in the four bytes at $DFA1. That id is saved at $DFA5
; and at [$DFA1 + C], and A returns it. The compare that accepted it
; leaves Z clear.

DEF SlotEntryLimit EQU $5A7D
DEF SlotEntryOffset EQU $5A7B
DEF wSlotMix EQU $DFF8
DEF wSlotStreamIndex EQU $DF9C
DEF wCompanionSerial EQU $DFA5

OpenSlotChannel:
    ld hl, SlotEntryLimit
    cp [hl]
    jp nc, .reject

    ld e, a
    ld d, $00
    sla e
    rl d
    sla e
    rl d
    ld hl, SlotEntryOffset
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld de, SoundDataHeader
    add hl, de
    push bc
    ld a, [hl+]
    ld b, [hl]
    inc hl
    ld c, $00
    ld d, $01
    push hl
    call OpenChannelForTag
    pop hl
    jr z, .pop_reject

    ld a, [hl+]
    ld d, a
    ld e, [hl]
    ld hl, wTagSlideFlags
    add hl, bc
    set 1, [hl]
    set 5, [hl]
    ld hl, wTagChannelFlags
    add hl, bc
    set 5, [hl]
    ld hl, wTagPeriodBaseHigh
    sla c
    add hl, bc
    ld a, d
    ld [hl-], a
    ld [hl], $00
    srl c
    ld a, e
    pop de
    bit 7, d
    jr nz, .use_nibble

    ld a, d

.use_nibble:
    and $0f
    push de
    ld e, a
    ld a, [wSlotMix]
    swap a
    and $0f
    call LookupChannelNibble
    pop de
    ld hl, wTagEnvelopeParam
    add hl, bc
    ld [hl], a
    push bc
    ld a, c
    ld [wSlotStreamIndex], a
    ld a, e
    cp $ff
    call nz, $4690
    ld a, [wCompanionSerial]

.next_id:
    inc a
    jr z, .next_id

    ld hl, wStreamCompanion
    cp [hl]
    jr z, .next_id

    inc hl
    cp [hl]
    jr z, .next_id

    inc hl
    cp [hl]
    jr z, .next_id

    inc hl
    cp [hl]
    jr z, .next_id

    ld [wCompanionSerial], a
    ld hl, wStreamCompanion
    pop bc
    add hl, bc
    ld [hl], a
    ret

.pop_reject:
    pop bc

.reject:
    xor a
    ret

OpenSlotChannelEnd:
