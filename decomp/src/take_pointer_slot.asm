; Bank 1. Opcode $0B calls this with the script record in BC after it maps
; bank 1. Bit 6 of the record byte skips the call; this path runs only when
; that bit is clear.
;
; Bit 7 of the record byte must be set or this returns at once. $C132 is the
; free-pointer cursor InitPointerList leaves at $C134. Each take reads one
; slot word and advances the cursor by two. Low byte $54 is one past the
; sixteen words, so the list is empty and this returns with HL still on that
; cursor. Otherwise the record byte is replaced with $40 (bit 6 set, so a
; later opcode $0B skips this call) and BC is stored into the slot the cursor
; handed out.
;
; Opcode $0B then clears bit 7 of [hl]. On the taken path HL is the next
; free-list word, whose stored slot addresses do not have that bit set.

; Same two bytes ReturnPointerSlot names wFreePointerCursor.
DEF wPointerFreeCursor EQU $C132
; Low byte of $C154, the first byte after the free-pointer table.
DEF FREE_POINTER_LIST_END EQU $54
; Bit 6. Opcode $0B treats this bit as "already linked".
DEF RECORD_BYTE_LINKED EQU $40

TakePointerSlot::
    ld a, [bc]
    bit 7, a
    ret z
    ld a, [wPointerFreeCursor + 1]
    ld h, a
    ld a, [wPointerFreeCursor]
    ld l, a
    ld a, FREE_POINTER_LIST_END
    cp l
    ret z
    ld a, RECORD_BYTE_LINKED
    ld [bc], a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld a, h
    ld [wPointerFreeCursor + 1], a
    ld a, l
    ld [wPointerFreeCursor], a
    ret

TakePointerSlotEnd:
