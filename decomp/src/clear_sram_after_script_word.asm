; Bank 7 at $40E6. Called after StoreScriptWordAtA123 writes the next
; script word at SRAM $A123. Also reached by a jump still inside the
; INCBIN at $40B7, which increments that same word and then enters here.
;
; SRAM bank wSRAMBank is selected with `add a, $00` (the flags are unused)
; and enabled. A is cleared. $7F bytes at $A125 are written as $00, which
; starts two bytes after the stored word and ends at $A1A3. Then $7F bytes
; at $A224 are written as $00, ending at $A2A3. SRAM is disabled and this
; routine returns. The word at $A123 is left as the caller stored it.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.

DEF SRAM_RUN_A125 EQU $A125
DEF SRAM_RUN_A224 EQU $A224
DEF SRAM_RUN_LEN EQU $7F

ClearSramAfterScriptWord::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    ld d, SRAM_RUN_LEN
    ld hl, SRAM_RUN_A125

.zero_a125:
    ld [hl+], a
    dec d
    jr nz, .zero_a125

    ld d, SRAM_RUN_LEN
    ld hl, SRAM_RUN_A224

.zero_a224:
    ld [hl+], a
    dec d
    jr nz, .zero_a224

    xor a
    ld [rRAMG], a
    ret
