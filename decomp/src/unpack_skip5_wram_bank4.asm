; Bank 0 at $2FAC. CallScriptUnpackIntoWRAM4And6 calls this with BC
; pointing at a packed stream in the ROM bank the caller mapped.
;
; The WRAM bank in wCurrentWRAMBank is saved. Bank 4 is stored there and
; selected with `ldh [rSVBK], a`. HL takes the source from BC, then advances
; five bytes. The jump to SkipTwoThenUnpackAtD000 ($2DF4) skips two more
; bytes, so seven source bytes are unused, and UnpackBytes writes the packed
; stream to $D000 in WRAM bank 4. That tail restores the saved WRAM bank.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; SkipTwoThenUnpackAtD000 is the name from unpack_block_wram5.asm.

DEF WRAM_BANK4 EQU $04
DEF UNPACK_HEADER_SKIP EQU $0005

UnpackSkip5ThenTailIntoWRAMBank4::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, WRAM_BANK4
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld h, b
    ld l, c
    ld de, UNPACK_HEADER_SKIP
    add hl, de
    jp SkipTwoThenUnpackAtD000
