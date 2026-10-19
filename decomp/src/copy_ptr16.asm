; Bank 5 at $5E4D. LoadSelectedRecordToD100 stores a record pointer at
; $CD8D, points $CD8F at $D100, and calls here in bank 5. The same pair
; of words is how other bank-5 callers hand this routine a source and a
; destination.
;
; Both pointers are little-endian words. This copies $10 bytes from the
; first to the second and returns. It does not switch banks.
;
; $CD8D and $CD8F are reused as scratch pointers; the names differ by
; caller, so this file leaves them as addresses.

DEF PTR16_LEN EQU $10

CopyPtr16Bytes::
    ld hl, $CD8D
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8F
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, PTR16_LEN

.copyByte:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyByte

    ret
