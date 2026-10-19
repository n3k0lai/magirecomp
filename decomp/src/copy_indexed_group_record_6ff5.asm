; Copy one $22-byte record from the table at $6FF5 in this bank.
;
; wGroupLowOffset is the record index. MulCByB returns that index times
; $22 in HL. Adding $6FF5 lands on the record. $22 bytes are copied to
; the word at wGroupListPtr. The table itself starts at the next byte
; and stays INCBIN. Choice $01 and IndexedSetup index $03 use this base
; with SRAM $A5A5; CopyIndexedGroupRecord is the same copy from $5DFF.
;
; wGroupLowOffset and wGroupListPtr are the names from scan_group_bytes.asm.
; GROUP_BYTE_COUNT is the name from copy_group_bytes.asm. MulCByB is
; already source.

CopyIndexedGroupRecord6FF5::
    ld a, [wGroupLowOffset]
    ld c, a
    ld b, GROUP_BYTE_COUNT
    call MulCByB
    ld bc, BlankGroupRecord6FF5
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
