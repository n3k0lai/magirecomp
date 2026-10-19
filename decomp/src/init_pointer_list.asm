; Bank 1 entry that default-state setup calls after mapping this bank.
; default_state.asm names that call BuildPointerList.
;
; $C154 is sixteen words. $407D, still INCBIN, walks those words and stops
; when the address reaches $C174. This clears every word, then stores a
; pointer to each one in the sixteen-word table at $C134. $C132 is left
; pointing at $C134. $4062, still INCBIN, pushes a pointer back through
; $C132, and the walk at $407D reads one from there.
;
; The tail visits $31 bytes from $C189, stepping $1B each time, and sets
; bit 7 and clears bit 6. $401E copies $1B bytes to $C1A4, one step past
; $C189, so these are the first bytes of that many records. $407D tests
; bit 7 of a record byte and clears bit 6 before returning a slot. What
; the two bits mean beyond that is still unknown.

DEF wPointerCursor EQU $C132
DEF wPointerTable EQU $C134
DEF wPointerSlots EQU $C154
DEF wRecordFlags EQU $C189
DEF POINTER_SLOT_COUNT EQU $10
DEF RECORD_STRIDE EQU $001B
DEF RECORD_FLAG_COUNT EQU $31

InitPointerList::
    ld b, POINTER_SLOT_COUNT
    xor a
    ld hl, wPointerSlots
.clear_slot:
    ld [hl+], a
    ld [hl+], a
    dec b
    jr nz, .clear_slot
    ld b, POINTER_SLOT_COUNT
    ld de, wPointerSlots
    ld hl, wPointerTable
.store_pointer:
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl+], a
    inc de
    inc de
    dec b
    jr nz, .store_pointer
    ld a, LOW(wPointerTable)
    ld [wPointerCursor], a
    ld a, HIGH(wPointerTable)
    ld [wPointerCursor + 1], a
    ld hl, wRecordFlags
    ld de, RECORD_STRIDE
    ld c, RECORD_FLAG_COUNT
.mark_record:
    set 7, [hl]
    res 6, [hl]
    add hl, de
    dec c
    jr nz, .mark_record
    ret
