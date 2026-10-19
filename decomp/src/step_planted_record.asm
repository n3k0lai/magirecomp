; Bank 4 at $709E. ApplyC9BCScrollThenFrame calls this after the two
; $73AA stores, with DE saved around the call. Bank 4 is already mapped.
; This routine does not write rROMB0 and does not call out.
;
; $C9EB is an index into the word at $C9F0. $C9EC is the index limit:
; when they match, this returns. $C9EE counts up toward the wait in
; $C9EF. Until they match, $C9EE increments and this returns.
;
; When the wait elapses, $C9EE is cleared and three bytes are read at
; record + $C9EB. Byte 0 is added to $C9C4. Byte 1 is added to $C9C3
; and clamped at $71. Byte 2 replaces $C9EF. The index then advances
; by 3.
;
; When those three bytes are all zero, the next two are a restart index
; and a repeat count stored at $C9ED. A zero $C9ED stores both and
; returns. A nonzero $C9ED decrements. While it stays nonzero, the
; index becomes that restart byte. When the decrement hits zero, the
; index skips the five-byte control instead.
;
; What the record, $C9C3, $C9C4, and $C9ED mean is still unknown.
; $C9EB, $C9EC, $C9EE, $C9EF, and $C9F0 are the bytes planted by
; resume_script_dispatch.asm and plant_record_30.asm.

; Upper bound stored into $C9C3 after adding the record's second byte.
DEF RECORD_C9C3_CLAMP EQU $71

StepPlantedRecord::
    ld a, [$C9EC]
    ld c, a
    ld a, [$C9EB]
    cp c
    ret z

    ld a, [$C9EF]
    ld c, a
    ld a, [$C9EE]
    cp c
    jr z, .wait_elapsed

    inc a
    ld [$C9EE], a
    ret

.wait_elapsed:
    xor a
    ld [$C9EE], a
    ld hl, $C9F0
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld b, $00
    ld a, [$C9EB]
    ld c, a
    add hl, bc
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld [$C9EF], a
    and a
    jr nz, .apply_deltas

    cp e
    jr nz, .apply_deltas

    cp d
    jr nz, .apply_deltas

    ld a, [$C9ED]
    and a
    jr nz, .repeat_active

    ld a, [hl+]
    ld [$C9EB], a
    ld a, [hl+]
    ld [$C9ED], a
    ret

.repeat_active:
    ld a, [$C9ED]
    dec a
    ld [$C9ED], a
    and a
    jr z, .skip_control

    ld a, [hl+]
    ld [$C9EB], a
    ret

.skip_control:
    ld a, [$C9EB]
    add $05
    ld [$C9EB], a
    ret

.apply_deltas:
    ld a, [$C9C4]
    add d
    ld [$C9C4], a
    ld a, [$C9C3]
    add e
    cp RECORD_C9C3_CLAMP
    jr c, .store_c9c3

    ld a, RECORD_C9C3_CLAMP

.store_c9c3:
    ld [$C9C3], a
    ld a, [$C9EB]
    add $03
    ld [$C9EB], a
    ret
