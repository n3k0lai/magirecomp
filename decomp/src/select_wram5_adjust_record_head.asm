; Bank 5 at $67A3. RunTwoScriptsFromRecord maps bank 5 and calls here
; through CallBankedHL, after $4AB6. WRAM bank 5 is stored in
; wCurrentWRAMBank and selected with rSVBK. $67B1 then adds [$C6D2]
; into the record-head byte at $FF8F. $67E7 adds [$C6D3] into $FF90.
; Both of those calls are still INCBIN. This routine does not write
; rROMB0.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

SelectWRAM5AdjustRecordHead::
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call $67B1
    call $67E7
    ret
