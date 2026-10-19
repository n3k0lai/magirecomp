; Script handler planted by StageHandler1126. Copies three script bytes
; at [BC] into $C9EA, $C9E7, and $C9E8, advancing BC after each one.
; ROM bank 4 is stored to wCurrentROMBank and rROMB0, then $711C in
; that bank is called. BC is left just past the three bytes.
;
; .from_advance is $1134. It skips the three stores and only advances
; BC before the bank switch. Nothing in this slice jumps there.
; What the three WRAM bytes mean, and what $711C does, is still unknown.
; wCurrentROMBank and rROMB0 are the names from reset.asm.

; ROM bank mapped for the call at $711C.
DEF HANDLER_1126_BANK EQU $04

ScriptHandler1126::
    ld a, [bc]
    ld [$C9EA], a
    inc bc
    ld a, [bc]
    ld [$C9E7], a
    inc bc
    ld a, [bc]
    ld [$C9E8], a
.from_advance::
    inc bc
    ld a, HANDLER_1126_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $711C
    ret
