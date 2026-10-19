; Opcode $9D body. Bank 1 at $4972. The stub at $23D2 sets bit 7 of
; hScriptBank (that forces bank 1) and plants this address as
; hScriptHandler.
;
; Two at wUnknownC6EE jumps to $4A2E, which clears that bit and plants
; DispatchScriptOpcode ($0A66). A 1 returns, so the next pass checks
; again. Any other value stores 1, clears $FFA6, stores 7 at wWindowX,
; and sets rLYC to $8F. wCallbackBank becomes 1 and wCallback becomes
; $475A. hScriptHandler becomes $49B3. hSTATHandler becomes $2ABA.
; $4A2E, $475A, $49B3, and $2ABA are still INCBIN.
;
; wUnknownC6EE and wWindowX are the names from setup_window.asm.
; wCallback and wCallbackBank are the names from default_state.asm.
; hScriptHandler is the name from reset.asm. hSTATHandler is the name
; from lcd_stat.asm. Every store below except rLYC is the 3-byte form.
; rLYC is $FF45, written with ldh.

Opcode9DBody::
    ld a, [wUnknownC6EE]
    cp $02
    jp z, $4A2E

    cp $01
    ret z

    ld a, $01
    ld [wUnknownC6EE], a
    xor a
    ld [$ffa6], a
    ld a, $07
    ld [wWindowX], a
    ld a, $8f
    ldh [$ff45], a
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW($475A)
    ld [wCallback], a
    ld a, HIGH($475A)
    ld [wCallback + 1], a
    ld a, LOW($49B3)
    ld [hScriptHandler], a
    ld a, HIGH($49B3)
    ld [hScriptHandler + 1], a
    ld a, LOW($2ABA)
    ld [hSTATHandler], a
    ld a, HIGH($2ABA)
    ld [hSTATHandler + 1], a
    ret
