; Bank 0 at $3667. PlaceEntryMapByDE calls this after the E step
; and adds the BC it returns to HL.
;
; B comes back as 0. If D is $0A, C is 0 and HL is left alone.
; Otherwise C is the byte at $3769 + D. That table is still INCBIN.

; D value that returns a zero offset.
DEF ENTRY_D_SKIP EQU $0A

LookupEntryDByte::
    ld bc, $0000
    ld a, d
    cp ENTRY_D_SKIP
    ret z
    push hl
    ld c, d
    ld hl, EntryDByteTable
    add hl, bc
    ld c, [hl]
    pop hl
    ret

LookupEntryDByteEnd:
