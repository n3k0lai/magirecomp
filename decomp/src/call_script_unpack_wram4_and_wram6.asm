; Script step at $18A9. BC is the script pointer. Two records follow.
; Each record is a little-endian pointer and then a ROM bank.
;
; The first bank is stored in wCurrentROMBank and mapped through rROMB0.
; The previous bank is saved and restored around the call. $2FAC, still
; INCBIN, is called with BC set to that pointer while its bank is mapped.
; It selects WRAM bank 4, skips seven source bytes, and unpacks the stream
; to $D000.
;
; The second record is read the same way. $2E04, still INCBIN, is called
; with BC set to the second pointer. It selects WRAM bank 6, skips the
; first source byte, and joins the unpack tail, which skips two more
; bytes before writing the stream to $D000. Control then jumps to
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; $18AF enters with HL already the first pointer and BC still on its
; bank byte. What either callee does with bytes past the skip is still
; unknown.
;
; wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. The bank stores are the 3-byte form.

; Bank 0, still INCBIN. Selects WRAM bank 4, skips seven bytes, unpacks to $D000.
; Bank 0, still INCBIN. Selects WRAM bank 6, skips one byte, joins the unpack tail.
DEF UnpackSkip1ThenTailIntoWRAMBank6 EQU $2E04

CallScriptUnpackIntoWRAM4And6::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc

CallScriptUnpackIntoWRAM4InHL::
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call UnpackSkip5ThenTailIntoWRAMBank4
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
    call UnpackSkip1ThenTailIntoWRAMBank6
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
