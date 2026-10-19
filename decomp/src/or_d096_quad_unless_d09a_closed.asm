; Bank 2 at $6FB2. Callers reach here when the word at $D07B equals
; $D336, and again when $D09A is already zero.
;
; The four bytes at $D096 are ORed together. `dec d` leaves Z set, so
; `and a` retests that OR. A nonzero result returns in A.
;
; Otherwise A is 0 and is copied to B. A zero byte at $D09A returns 0.
; A nonzero byte there ORs the four bytes at $D082 with the two bytes at
; $D33D and returns that value. Both callers test A: zero stores 2 at
; $D016.

OrD096QuadUnlessD09AClosed::
    ld hl, $D096
    xor a
    ld d, $04
.orD096:
    or [hl]
    inc hl
    dec d
    jr nz, .orD096
    and a
    ret nz
    ld b, a
    ld a, [$D09A]
    and a
    ret z
    ld hl, $D082
    ld d, $04
    xor a
.orD082:
    or [hl]
    inc hl
    dec d
    jr nz, .orD082
    ld hl, $D33D
    or [hl]
    inc hl
    or [hl]
    ret
