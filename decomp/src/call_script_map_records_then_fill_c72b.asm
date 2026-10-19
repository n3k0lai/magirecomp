; Script step at $1903. BC is the script pointer. Two records follow.
; Each record is a little-endian pointer and then a ROM bank.
;
; The first bank is stored in wCurrentROMBank and mapped through rROMB0.
; The previous bank is saved and restored around the call. CopyMapRecords
; ($2FC0) is called with BC set to that pointer while its bank is mapped.
; It copies counted map records into both VRAM banks.
;
; The second record is read the same way. FillC72BFromBCThenBank7 ($2EC3)
; is called with BC set to the second pointer. It copies $20 word pairs
; into $C72B, then runs the bank 7 panel path and copies BG palettes.
; Control then jumps to INITIAL_SCRIPT_HANDLER ($0A66).
;
; wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. CopyMapRecords and FillC72BFromBCThenBank7 are already source.
; The bank stores are the 3-byte form.

CallScriptMapRecordsThenFillC72B::
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
    call CopyMapRecords
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
    call FillC72BFromBCThenBank7
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
