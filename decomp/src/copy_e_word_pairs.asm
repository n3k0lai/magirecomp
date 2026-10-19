; Bank 0 at $2F0F. CopyWordPairs calls this after skipping E existing
; word pairs at HL and loading the pair count into E. Each pass copies
; one word from BC into HL and advances both pointers. E == 0 runs 256
; times, the same as dec e wrapping.

CopyEWordPairs::
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec e
    jr nz, CopyEWordPairs
    ret
