; Copy one $22-byte record from the table at $5DFF in this bank.
;
; wGroupLowOffset is the record index. MulCByB returns that index times
; $22 in HL. Adding $5DFF lands on the record. $22 bytes are copied to
; the word at wGroupListPtr. The table itself is still INCBIN. The twin
; at $5DE1 uses base $6FF5 and is still INCBIN.
;
; wGroupLowOffset and wGroupListPtr are the names from scan_group_bytes.asm.
; GROUP_BYTE_COUNT is the name from copy_group_bytes.asm. MulCByB is
; already source.

CopyIndexedGroupRecord::
    ld a, [wGroupLowOffset]
    ld c, a
    ld b, GROUP_BYTE_COUNT
    call MulCByB
    ld bc, $5DFF
    add hl, bc
    ld a, [wGroupListPtr + 1]
    ld b, a
    ld a, [wGroupListPtr]
    ld c, a
    ld d, GROUP_BYTE_COUNT
.copy:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy

    ret

CopyIndexedGroupRecordEnd:
