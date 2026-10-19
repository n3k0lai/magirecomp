; Script opcode $99. DispatchScriptOpcode jumps here from the bank 1 table.
;
; [$C6EE] other than 2 leaves through DispatchScriptOpcode ($0A66). When
; it is already 2, wCallbackBank becomes 1 and wCallback becomes
; BlankTwoWindowSpans. hScriptHandler becomes FinishWindowYSlide plus
; five bytes, past the store that would write 2 to [$C6EE] again. This
; then returns to MapScriptBankAndCall.
;
; wCallback and wCallbackBank are the names from default_state.asm.
; hScriptHandler and DispatchScriptOpcode are already source.
; wUnknownC6EE is the name from setup_window.asm. Every store below is
; the 3-byte form.

; FinishWindowYSlide + 5 skips `ld a, $02` / `ld [wUnknownC6EE], a`.

Opcode99::
    ld a, [wUnknownC6EE]
    cp $02
    jp nz, DispatchScriptOpcode

    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW(BlankTwoWindowSpans)
    ld [wCallback], a
    ld a, HIGH(BlankTwoWindowSpans)
    ld [wCallback + 1], a
    ld a, LOW(FinishWindowYSlide + 5)
    ld [hScriptHandler], a
    ld a, HIGH(FinishWindowYSlide + 5)
    ld [hScriptHandler + 1], a
    ret
