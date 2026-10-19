; Bank 1 at $4B61. DispatchCellBelowOnButtonA jumps here when the cell
; one row below has bit 5 or bit 6 set and bit 7 clear. E is that cell
; byte. BC and HL are whatever the caller of that dispatch left.
;
; C then B are stored at $C99C, the little-endian word StoreEThroughWord
; later reloads as DE. L then H are stored at $C99E, the word that path
; reloads as HL. E is stored at $C9A0, the list index
; StageThirdScriptFromListIndex reads. Those three addresses have no
; names yet.
;
; StageThirdScriptFromListIndex may plant wThirdScriptRecord from the
; bank-21 list. CommitScriptRecord then copies the HRAM script bytes and
; writes the record head.

SaveCellBelowAndStageThirdScript::
    ld a, c
    ld [$c99c], a
    ld a, b
    ld [$c99d], a
    ld a, h
    ld [$c99f], a
    ld a, l
    ld [$c99e], a
    ld a, e
    ld [$c9a0], a
    call StageThirdScriptFromListIndex
    jp CommitScriptRecord
