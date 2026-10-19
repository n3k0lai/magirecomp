; Bank 2 at $75FC. A is a record index. MulCByB returns HL = A * $37.
; Adding $D147 points at that record. StoreD0D9AfterLowD103 and the
; caller at $762B use the pointer to copy the $37-byte record at $D0D9.

IndexTimes37PlusD147::
    ld b, a
    ld c, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ret
