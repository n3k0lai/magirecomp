; Bank 1 at $49B3. Opcode9DBody plants this as hScriptHandler after it
; stores 1 at wCallbackBank and $475A at wCallback.
;
; This pass stores 1 at wCallbackBank again and points wCallback at
; BlankTwoWindowSpans ($470F). hScriptHandler becomes $49CD, still
; INCBIN. Every store is the 3-byte form.
;
; wCallback and wCallbackBank are the names from default_state.asm.
; hScriptHandler is the name from reset.asm. BlankTwoWindowSpans is
; the name from blank_two_window_spans.asm.

Opcode9DBlankSpans::
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW(BlankTwoWindowSpans)
    ld [wCallback], a
    ld a, HIGH(BlankTwoWindowSpans)
    ld [wCallback + 1], a
    ld a, LOW($49CD)
    ld [hScriptHandler], a
    ld a, HIGH($49CD)
    ld [hScriptHandler + 1], a
    ret
