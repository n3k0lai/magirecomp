; Bank 0 at $2E04. CallScriptUnpackIntoWRAM4And6 calls this with BC
; pointing at a packed stream in the ROM bank the caller mapped.
;
; The WRAM bank in wCurrentWRAMBank is saved. Bank 6 is stored there and
; selected with `ldh [rSVBK], a`. HL takes the source from BC, then advances
; one byte. The jump to SkipTwoThenUnpackAtD000 ($2DF4) skips two more
; bytes, so three source bytes are unused, and UnpackBytes writes the packed
; stream to $D000 in WRAM bank 6. That tail restores the saved WRAM bank.
;
; $2E0A is the store of the bank already in A. A caller that has pushed the
; previous bank and loaded A can enter there. The only note of that address
; is a word inside bank $1A data, still INCBIN.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; SkipTwoThenUnpackAtD000 is the name from unpack_block_wram5.asm.

; The caller names this address UnpackSkip1ThenTailIntoWRAMBank6.
SelectWRAM6Skip1ThenUnpack::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, $06

StorePushedBankSkip1ThenUnpackAtD000::
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld h, b
    ld l, c
    inc hl
    jp SkipTwoThenUnpackAtD000
