; Bank 2 at $5C00.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; HL is set to the $D110 record and AdjustA000RecordOnce runs. That
; routine is already source. It maps bank 7 again, then unless bit 0 of
; $D389 is set it calls $3812 with BC = -100. It saves and may increment
; the byte at record+4, then calls $3821 and $596F.

AdjustD110InEntryBank::
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, $D110
    call AdjustA000RecordOnce
    ret
