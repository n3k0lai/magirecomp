; Bank 1 at $49CD. Opcode9DBlankSpans plants this as hScriptHandler after
; it points wCallback at BlankTwoWindowSpans.
;
; This pass points wCallback at $472A and plants $49E2 as the next
; hScriptHandler. Both addresses are still INCBIN. The bank byte is left
; alone. Every store is the 3-byte form.
;
; wCallback is the name from default_state.asm. hScriptHandler is the
; name from reset.asm. BlankTwoWindowSpans is the name from
; blank_two_window_spans.asm.

RetargetWindowBlank::
    ld a, LOW($472A)
    ld [wCallback], a
    ld a, HIGH($472A)
    ld [wCallback + 1], a
    ld a, LOW($49E2)
    ld [hScriptHandler], a
    ld a, HIGH($49E2)
    ld [hScriptHandler + 1], a
    ret
