; Bank 5 at $5762. Called from ApplyHalfD06CThenMaybeScan after a
; divider nibble passes its limit. The return is stored at $C9FD and
; handed to CopyNameAndAddScanC. $FF skips that roll.
;
; Eight bytes at $D0B8 are filled with $FF at init. Later paths write an
; id into the first byte that does not already match it, so a leading run
; of ids ends at the first $FF. This routine counts that run.
;
; A count of zero returns $FF. Otherwise AddDividerStep's byte is reduced
; modulo the count by DivideCByB, and the byte at that index is returned.
; A full table of eight non-$FF bytes uses every slot. AddDividerStep and
; DivideCByB are already source.

; Id list. $FF marks the end of the occupied prefix, and an empty slot.
DEF wD0B8List EQU $D0B8

; Length of wD0B8List.
DEF D0B8_LIST_LEN EQU $08

; Empty-slot marker, and the return when the list has no ids.
DEF D0B8_EMPTY EQU $FF

PickD0B8EntryOrFF::
    ld hl, wD0B8List
    ld d, D0B8_LIST_LEN
    ld a, D0B8_EMPTY
.scan:
    cp [hl]
    jr z, .count
    dec d
    jr z, .count
    inc hl
    jr .scan

.count:
    ld a, D0B8_LIST_LEN
    sub d
    jr z, .empty
    ld b, a
    call AddDividerStep
    ld c, a
    call DivideCByB
    ld c, l
    ld b, $00
    ld hl, wD0B8List
    add hl, bc
    ld a, [hl]
    ret

.empty:
    ld a, D0B8_EMPTY
    ret
