; Entry at $17D7. BC is the script pointer. The next three script bytes are
; a pointer (low, then high) and a ROM bank. That bank is stored in
; wCurrentROMBank and mapped through rROMB0. $2D14 is called with BC set
; to the pointer, while the saved script pointer and the previous bank
; stay on the stack. Both are restored, and control jumps to
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; $17DA is the same path with L already holding the pointer low byte.
; Nothing in bank 0 jumps there. What $2D14 does with BC is still unknown.
; wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. The bank and pointer stores are the 3-byte form.

; Bank 0, still INCBIN. Called while the script bank is mapped. $2D14 is
; in ROM0, so the mapped bank does not change this call's code.

CallBankedWordThenResume::
    ld a, [bc]
    ld l, a
    inc bc

CallBankedWordThenResumeHigh::
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
    call UnpackScriptMapsAt9800
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
