; StoreClaimedRecordWord. Bank 2 at $5B71.
;
; ClaimFirstMeasureThreshold calls this with the record in HL and DE set to
; $0018, $001A, $001C, or $001E for the threshold slot it just claimed.
; The little-endian word at record+DE is copied to $CDD1. $CDD3 is then set
; to the pointer $C96A ($6A then $C9). HL is restored. DE is destroyed.
;
; What reads $CDD1 and $C96A afterward is still unknown.

StoreClaimedRecordWord::
    push hl
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld hl, $cdd1
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld a, $6a
    ld [$cdd3], a
    ld a, $c9
    ld [$cdd4], a
    pop hl
    ret
