; Script step at $1866. BC is the script pointer. Two records follow.
; Each record is a little-endian pointer and then a ROM bank.
;
; The first bank is stored in wCurrentROMBank and mapped through rROMB0.
; The previous bank is saved and restored around the call. $2F37, still
; INCBIN, is called with BC set to that pointer while its bank is mapped.
; It unpacks a header while WRAM bank 3 is mapped.
;
; The second record is read the same way. UnpackBlockIntoWRAMBank5
; ($2DDC) is called with BC set to the second pointer. It unpacks that
; block to $D000 in WRAM bank 5. Control then jumps to
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; $186C enters with HL already the first pointer and BC still on its
; bank byte. What $2F37 does with the pointer beyond the WRAM bank 3
; unpack is still unknown.
;
; wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. UnpackHeaderWRAMBank3 is the name from
; load_five_banked_map_sources.asm. The bank stores are the 3-byte form.

CallScriptUnpackHeaderAndBlock::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc

CallScriptUnpackHeaderInHL::
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call UnpackHeaderWRAMBank3
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call UnpackBlockIntoWRAMBank5
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
