; Bank 2 at $7607. CopyD393RecordThenDispatch calls here when [$D0AF]
; is nonzero after the bank 5 dispatch, then returns.
;
; [$D103] below $14 treats [$D395] as a byte offset from $6FDF, index 4
; of D0F0JumpWords. JumpHL calls that word and returns here. [$D103] at
; or above $14 skips the call.
;
; [$D392] is the record index. $75FC, still INCBIN, returns
; HL = $D147 + index * $37. Copy37ByteRecord then copies the $37 bytes
; at $D0D9 onto that record. JumpHL and Copy37ByteRecord are already
; source.

StoreD0D9AfterLowD103::
    ld a, [$D103]
    cp $14
    jr nc, .copyRecord

    ld a, [$D395]
    ld c, a
    ld b, $00
    ld hl, D0F0JumpWords + 8
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL

.copyRecord:
    ld a, [$D392]
    call $75FC
    ld bc, $D0D9
    call Copy37ByteRecord
    ret
