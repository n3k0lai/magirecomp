; Map the ROM bank in A.
;
; [$DF01] is the low byte of an $FF00-page port. The bank number is stored
; there with ldh [c], a, then written to $2100. $2100 sits in the same MBC
; ROM-bank window as rROMB0 ($2000) from reset.asm. What [$DF01] holds is
; unknown.
;
; LoadWaveform calls this with the bank at $DF75, then again with the bank
; saved at $DF00. AdvanceCountdownRecord and StepIndexedCountdown leave
; through this routine with A = [$DF00].

MapRomBank::
    push af
    ld a, [$df01]
    ld c, a
    pop af
    ldh [c], a
    ld [$2100], a
    ret
