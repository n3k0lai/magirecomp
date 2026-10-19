; Bank 4's $7016. Called from $314F after bank $04 is mapped.
; $6FAB (still INCBIN) returns HL as the word in the $6F2B table selected
; by [$C9E4], and also stores that word at $C9DE. This adds $11, loads the
; word at that address, and stores it at $C9E5 (low) and $C9E6 (high).

; Bytes past the pointer from $6FAB.
DEF INDEXED_PTR_FIELD EQU $0011

; Little-endian copy of the word at that field. Role is still unknown.
DEF wIndexedPtrField EQU $C9E5

StoreIndexedPtrPlus11::
    call $6fab
    ld de, INDEXED_PTR_FIELD
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    ld [wIndexedPtrField + 1], a
    ld a, l
    ld [wIndexedPtrField], a
    ret
