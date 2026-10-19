; Bank 2 at $7477. Opcode2C copies two script bytes to $D392 in WRAM
; bank 7, maps this bank, and jumps here.
;
; The first operand is stored at $CD51 and the second at $CD50. Bank 4
; at $5D19, still INCBIN, is called through CallBankedHL and this
; returns. That callee reads $CD51.
;
; CallBankedHL is already source. $5D19 is still INCBIN.

StoreScriptPairThenCall5D19::
    ld hl, $D392
    ld a, [hl+]
    ld [$CD51], a
    ld a, [hl]
    ld [$CD50], a
    ld hl, $5D19
    ld e, $04
    call CallBankedHL
    ret
