; Bank 5 at $5BFE. D103WordTable enters here through JumpHL when
; [$D103] is $0A, $0B, $12, $13, $17, or $19 through $1E. This bank
; stays mapped.
;
; Stores 1 at $D0AF.

SetD0AFForD1030A::
    ld a, $01
    ld [$D0AF], a
    ret
