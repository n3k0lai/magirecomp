; Run the envelope walker at $3C75, then map the saved bank.
;
; $3C75 is still INCBIN. It maps the bank at $DF75 and walks a sample
; pointer. On the way out this routine loads the bank saved at $DF00 and
; writes it to $2100. $2100 sits in the same MBC ROM-bank window as
; rROMB0 ($2000) from reset.asm. Unlike MapRomBank, this store does not
; also write the port at [$DF01].

RunEnvelopeThenMapSavedBank::
    call $3c75
    ld a, [$df00]
    ld [$2100], a
    ret
