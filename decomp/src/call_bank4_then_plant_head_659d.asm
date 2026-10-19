; Bank 1 at $6586, the first byte after FillFirstRecordScriptSlots.
; rROMB0 is left alone except inside CallBankedHL.
;
; LoadRecordHead copies the ten-byte head. Bank 4 is mapped and $73FE
; runs through CallBankedHL. What that routine does is still unknown.
; The head word at hRecordHead + 1 becomes $659D, the next byte in this
; bank, still INCBIN. WriteRecordHead stores the ten head bytes back.
;
; LoadRecordHead, WriteRecordHead, and CallBankedHL are already source.
; hRecordHead is the name from write_record_head.asm.

; Bank 4 at $73FE while that bank is mapped. File address $133FE.
DEF Bank4At73FE EQU $73FE

; Planted at hRecordHead + 1. Still INCBIN in this bank.
DEF HeadWord659D EQU $659D

CallBank4ThenPlantHead659D::
    call LoadRecordHead
    ld hl, Bank4At73FE
    ld e, $04
    call CallBankedHL
    ld a, LOW(HeadWord659D)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord659D)
    ldh [hRecordHead + 2], a
    call WriteRecordHead
    ret
