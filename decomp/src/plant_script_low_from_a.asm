; Bank 1 at $5655. DispatchCellRightOnButtonA plants this address as
; hScriptPtr when the cell one column right is $0B and $C9A6 is at
; least 2, then jumps to StampMapCellInWramBanks. The bytes just
; before this entry, still INCBIN at $5647, fall through after
; `ld a, $B3`.
;
; A is stored as the low byte of hScriptPtr. The high byte becomes
; $4F, so the pointer is $4Fxx. The little-endian word $5666 is
; written at hRecordHead + 1. That word is the next byte after the
; jump below and is still INCBIN. Control then leaves through
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hRecordHead is the name from
; write_record_head.asm. What the script engine leaves in A on the
; $5655 entry is still unknown.

; High byte paired with the incoming low byte at hScriptPtr.
DEF SCRIPT_HIGH_4F EQU $4F

; Next bytes in this bank. Still INCBIN. Planted in the record head.
DEF HeadWord5666 EQU $5666

PlantScriptLowFromA::
    ldh [hScriptPtr], a
    ld a, SCRIPT_HIGH_4F
    ldh [hScriptPtr + 1], a
    ld a, LOW(HeadWord5666)
    ldh [hRecordHead + 1], a
    ld a, HIGH(HeadWord5666)
    ldh [hRecordHead + 2], a
    jp CommitScriptRecord
