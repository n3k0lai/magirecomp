; Bank 5 at $5553. Word 3 of D104WordTable. JumpHL enters here for
; [$D104] = 3 and does not return. The last instruction leaves for $4B70.
;
; WRAM bank 7 is stored at wCurrentWRAMBank and selected with rSVBK.
; $A5A5 is stored little-endian at $CC82. $6FF5 is stored little-endian
; at $CC84. $22 is stored at $CC88. A is cleared, then the jump enters
; the shared tail. That tail adds $0D and stores the sum at wUnknownCD81.
; Word 2 at $4B51 writes a different pair and falls into the same tail.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; WRAM_BANK_ENTRY is the name from indexed_tail_07.asm. wUnknownCD81 is
; the name from handle_start_press.asm. $4B70 is still INCBIN.

DEF wWordAtCC82 EQU $CC82
DEF wWordAtCC84 EQU $CC84
DEF wByteAtCC88 EQU $CC88
DEF CC88_MARK EQU $22
DEF D104SharedTail EQU $4B70

SetupD104Word3Bases::
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $a5a5
    ld hl, wWordAtCC82
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $6ff5
    ld hl, wWordAtCC84
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, CC88_MARK
    ld [wByteAtCC88], a
    xor a
    jp D104SharedTail
