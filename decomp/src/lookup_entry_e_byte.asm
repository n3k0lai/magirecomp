; Bank 0 at $3657. PlaceEntryMapByDE calls this when E is below $10.
; B comes back as 0. If E is $10 or more, C is 0 and HL is left
; alone. Otherwise C is the byte at $3758 + E. That table is still
; INCBIN. The caller turns the byte into ($10 - E - C).

; Indexed by E. Each byte is subtracted from ($10 - E) by the caller.
DEF ENTRY_E_BYTE_TABLE EQU $3758

LookupEntryEByte::
    ld bc, $0000
    ld a, e
    cp ENTRY_MAP_E_EDGE
    ret nc
    push hl
    ld c, e
    ld hl, ENTRY_E_BYTE_TABLE
    add hl, bc
    ld c, [hl]
    pop hl
    ret

LookupEntryEByteEnd:
