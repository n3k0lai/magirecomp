; Default state setup. Reset calls here through InitDefaultState, after the
; WRAM clear.
;
; The reset path maps ROM bank 5 and calls $6C08. That copy writes
; 00 FF FF 00 FF FF FF FF at $C12A. Three pointers are installed next:
; $29A4 at $C6E4, $2A49 at $C6E2, and $2AB7 at hSTATHandler ($FF99).
; $29A4 stores this same address and returns. The VBlank handler at $2A10
; calls the pointer at $C6E2. The body at $2A49 is still INCBIN: bit 0 of
; $FF9E turns the LCD on and runs OAM DMA, and bit 1 calls $C6E4 in the ROM
; bank held at $C6E6. $2AB7 is pop hl / pop af / reti.
;
; Every sprite is then parked off screen, $2203 runs with ROM bank 0 mapped,
; and bank 1's $40D3 fills the pointer table at $C134. The tail clears the
; remaining startup bytes and sets $FFAA and $FFAB to 3.
;
; $0832, $083D, $0841, $084B, $0867, $0884, $0887, $0889, $088C, $088E, and
; $08A4 are entries, and each one falls through to this ret. $0884 stores A
; unchanged; the fall-through reaches it with A clear. $0887 and $088C reload
; 0 with the immediate form. $08A4 stores A into four bytes, and that A is 0
; on the fall-through.
;
; The STAT stores are the 3-byte form. hSTATHandler is defined later, in
; lcd_stat.asm, so the address is written here. wCurrentROMBank and rROMB0
; are the names from reset.asm.

; Bank 5's $6C08 writes the eight bytes at $C12A. The entry at $0832 maps
; the bank in A first, so another caller can reach a different bank's $6C08.
DEF BANK_PATTERN EQU $05
DEF WriteC12APattern EQU $6C08

; Idle callback, still INCBIN. Stores this address at $C6E4 and returns.
DEF IdleCallback EQU $29A4

; Default pointer called by the VBlank handler. Still INCBIN.
DEF DefaultVBlank EQU $2A49

; Empty STAT handler. lcd_stat.asm describes the pop / pop / reti body.
DEF EmptyStatHandler EQU $2AB7

; Little-endian VBlank pointer, the callback it may call, and that callback's bank.
DEF wVBlankRoutine EQU $C6E2
DEF wCallback EQU $C6E4
DEF wCallbackBank EQU $C6E6

; Bank 0, still INCBIN. Writes $FF to the Y byte of all 40 sprites in the
; $C000 buffer and in OAM, parking them below the screen.
DEF HideSprites EQU $0565

; Bank 0, still INCBIN. Maps the ROM bank in E, calls HL, then maps the
; previous ROM bank again.
DEF CallHLInBank EQU $0773

; Bank 0, still INCBIN. Called with E = 0. Sets WX to 7 and WY to $90, copies
; $60 bytes from bank 6 to $8800, and fills $A0 bytes of the $9C00 map in
; both VRAM banks.
DEF SetupWindow EQU $2203

; Bank 1, still INCBIN. CPU address while that bank is mapped. Zeros the
; 16 words at $C154 and writes a pointer to each at $C134.
DEF BANK_POINTERS EQU $01
DEF BuildPointerList EQU $40D3

SetupDefaultState::
    ld a, BANK_PATTERN
    ld [wCurrentROMBank], a
; $0832. A is the ROM bank to map.
.use_bank:
    ld [rROMB0], a
    call WriteC12APattern
; Role of this $FF is still unknown.
    ld a, $ff
    ld [$c6de], a
; $083D
.clear_callback_bank:
    xor a
    ld [wCallbackBank], a
; $0841. Same bytes the idle callback uses to reinstall itself.
.install_callback:
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
; $084B
.install_handlers:
    ld a, LOW(DefaultVBlank)
    ld [wVBlankRoutine], a
    ld a, HIGH(DefaultVBlank)
    ld [wVBlankRoutine + 1], a
    ld a, LOW(EmptyStatHandler)
    ld [$ff99], a
    ld a, HIGH(EmptyStatHandler)
    ld [$ff9a], a
; Clears the word at $C728. Its role is still unknown.
    ld a, $00
    ld [$c728], a
    ld [$c729], a
; $0867
.hide_sprites:
    call HideSprites
    ld hl, SetupWindow
    ld e, $00
    call CallHLInBank
    ld a, BANK_POINTERS
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call BuildPointerList
; $C931-$C933 are copied as a group later. Their role is still unknown.
    xor a
    ld [$c931], a
    ld [$c932], a
; $0884. Stores A. Fall-through arrives with A clear.
.store_c933:
    ld [$c933], a
; $0887
.zero_c9c5:
    ld a, $00
; $0889. Role of this byte is still unknown.
.store_c9c5:
    ld [$c9c5], a
; $088C
.zero_c9c6:
    ld a, $00
; $088E. Role of this byte is still unknown.
.store_c9c6:
    ld [$c9c6], a
; Three bytes $22, $06, $40. Their meaning is still unknown.
    ld hl, $c9ff
    ld a, $22
    ld [hl+], a
    ld a, $06
    ld [hl+], a
    ld a, $40
    ld [hl+], a
; WRAM-bank shadow ($C937, wCurrentWRAMBank) and the ROM-bank shadow.
; rROMB0 still holds bank 1. This routine does not write rSVBK.
    xor a
    ld [$c937], a
    ld [wCurrentROMBank], a
; $08A4. Stores A into four bytes whose roles are still unknown.
.clear_tail:
    ld [$c188], a
    ld [$c6d8], a
    ld [$cca6], a
    ld [$c6f3], a
    ld a, $03
    ld [$c6ef], a
    ld hl, $ffaa
    ld [hl+], a
    ld [hl+], a
    ret
