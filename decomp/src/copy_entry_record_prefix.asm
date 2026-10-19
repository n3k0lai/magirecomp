; Bank 4 at $40F0. AddSRAMEntryForOperand stores the operand's $415B
; record pointer at $CD8D, points $CD8F at $CD91, and calls here.
;
; Both pointers are little-endian words. This copies the first $1E bytes
; of that $2D-byte record into the destination and returns. $1E is the
; offset named ENTRY_RECORD_FIELD in record_ptr_from_id.asm. It does not
; switch banks. The following routine at $4106, still INCBIN, copies the
; whole $2D-byte record the same way.
;
; $CD8D and $CD8F are reused as scratch pointers; this file leaves them
; as addresses.

DEF ENTRY_RECORD_PREFIX EQU $1E

CopyEntryRecordPrefix::
    ld hl, $CD8D
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8F
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, ENTRY_RECORD_PREFIX
.copyByte:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyByte
    ret
