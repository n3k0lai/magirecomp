; Opcode $9A body. Bank 1 at $48DF. The stub at $2297 sets bit 7 of
; hScriptBank (that forces bank 1) and plants this address as
; hScriptHandler.
;
; Zero at wUnknownC6EE jumps to $4962, which clears that bit and plants
; DispatchScriptOpcode ($0A66). A 1 returns, so the next pass checks
; again. Any other value stores 1, stores 9 at $FFA6, and points
; wCallback at $470F with wCallbackBank 1. hScriptHandler becomes
; $490E. That continuation, $4962, and $470F are still INCBIN.
;
; wUnknownC6EE is the name from setup_window.asm. wCallback and
; wCallbackBank are the names from default_state.asm. hScriptHandler
; is the name from reset.asm. Every store below is the 3-byte form.

Opcode9ABody::
    ld a, [wUnknownC6EE]
    cp $00
    jp z, $4962

    cp $01
    ret z

    ld a, $01
    ld [wUnknownC6EE], a
    ld a, $09
    ld [$ffa6], a
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW($470F)
    ld [wCallback], a
    ld a, HIGH($470F)
    ld [wCallback + 1], a
    ld a, LOW($490E)
    ld [hScriptHandler], a
    ld a, HIGH($490E)
    ld [hScriptHandler + 1], a
    ret
