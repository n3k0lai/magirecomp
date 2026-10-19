; Bank 2 at $6BBA. LoopWhileD0D5 calls here after $6A01, once [$D0D5] is zero.
;
; $D0B1 is set to 9. That index is the $37-byte record at $D336, which is
; $D147 + 9 * $37. Copy37ByteRecord copies it to $D0D9. [$D0F0] selects a
; word in the table at $6FD7. JumpHL calls that pointer. $D0FF is cleared,
; and the $D0D9 record is copied back to $D336.
;
; Copy37ByteRecord and JumpHL are already source. The $6FD7 table and the
; routines it points at are still INCBIN. JumpHL does not change the ROM
; bank, so those pointers stay in this bank.

DispatchSlot9ByD0F0::
    ld a, $09
    ld [$D0B1], a
    ld bc, $D336
    ld hl, $D0D9
    call Copy37ByteRecord
    ld a, [$D0F0]
    add a
    ld c, a
    ld b, $00
    ld hl, $6FD7
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    xor a
    ld [$D0FF], a
    ld hl, $D336
    ld bc, $D0D9
    call Copy37ByteRecord
    ret
