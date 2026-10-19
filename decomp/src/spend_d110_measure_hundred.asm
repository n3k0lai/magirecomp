; SpendD110MeasureHundred. Bank 2 at $5C0E.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; HL is set to the $D110 record and SpendMeasureHundred runs. That
; routine maps bank 7 again, spends 100 from the big-endian word at
; record+5, and raises the capped stat bytes on the record.
;
; wCurrentWRAMBank, rSVBK, and WRAM_BANK_ENTRY are already defined.

SpendD110MeasureHundred::
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, $D110
    call SpendMeasureHundred
    ret
