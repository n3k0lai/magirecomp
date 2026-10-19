; Bank 5 at $4967. Continuation of RunD0B1MapStrips after the eighth
; $9C00 map strip. paint_choice_strip is defined in
; run_d0b1_map_strips.asm and is already in scope.
;
; Three more strips, then ret. The first two still point their text
; at $D046 and $D060. The last points at $397E and starts from pass
; immediate $08 (stored as $09). JumpHL and FinishFrame are already
; source.

FinishD0B1MapStrips::
    paint_choice_strip $20, $8A, $85, $A2, $A9, $46, $D0, $07
    paint_choice_strip $90, $8B, $8F, $B9, $BC, $60, $D0, $03
    paint_choice_strip $60, $90, $A5, $06, $0E, $7E, $39, $08
    ret
