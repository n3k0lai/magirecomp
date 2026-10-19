; Bank 1 at $412F. BC points at a record. That pointer is stored at
; $FF8A (low) and $FF8B (high), then the next ten bytes are copied into
; $FF8C–$FF95. Those are the same pointer and head WriteRecordHead
; writes back. hRecordPointer and hRecordHead are defined earlier in
; this bank.
;
; The word at $C6D2 is cleared. What that word tracks is still unknown.

DEF wClearedOnRecordLoad EQU $C6D2

LoadRecordHead::
    ld h, b
    ld l, c
    ld a, l
    ldh [hRecordPointer], a
    ld a, h
    ldh [hRecordPointer + 1], a
    ld a, [hl+]
    ldh [hRecordHead], a
    ld a, [hl+]
    ldh [hRecordHead + 1], a
    ld a, [hl+]
    ldh [hRecordHead + 2], a
    ld a, [hl+]
    ldh [hRecordHead + 3], a
    ld a, [hl+]
    ldh [hRecordHead + 4], a
    ld a, [hl+]
    ldh [hRecordHead + 5], a
    ld a, [hl+]
    ldh [hRecordHead + 6], a
    ld a, [hl+]
    ldh [hRecordHead + 7], a
    ld a, [hl+]
    ldh [hRecordHead + 8], a
    ld a, [hl+]
    ldh [hRecordHead + 9], a
    xor a
    ld [wClearedOnRecordLoad], a
    ld [wClearedOnRecordLoad + 1], a
    ret

LoadRecordHeadEnd:
