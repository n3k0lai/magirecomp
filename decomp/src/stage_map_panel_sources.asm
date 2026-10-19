; Bank 0 at $311F. LoadMapPanels calls this before $314F and the bank $42
; panel copies.
;
; The `ld a, a` after `ld a, $04` leaves A holding $04. That bank is stored
; in wCurrentROMBank and rROMB0. $C831 is cleared. $2EB6, still INCBIN, is
; called with BC = $4000, HL = $C72B, E = $00, and A = $18. $C9D8 is set to
; $05. Bank $07 is stored the same way, then $481E in that bank runs.
; $C831 is set to $01 before the return.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. $C9D8 is
; wUnknownC9D8 from indexed_tail_07.asm. $C831 and $C72B are still unnamed.
; What $2EB6 does with those four arguments is still unknown.

DEF Call_2EB6 EQU $2EB6

; CPU address in bank $07. The call above has just mapped that bank.
DEF Call_Bank7_481E EQU $481E

StageMapPanelSources::
    ld a, $04
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    xor a
    ld [$C831], a
    ld bc, $4000
    ld hl, $C72B
    ld e, $00
    ld a, $18
    call Call_2EB6
    ld a, $05
    ld [wUnknownC9D8], a
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank7_481E
    ld a, $01
    ld [$C831], a
    ret
