; Reads a little-endian pointer from the script at [BC] into HL and advances
; BC by two. ROM bank 1 is stored to wCurrentROMBank and rROMB0 and left
; mapped. AddDividerStep mixes rDIV into hDividerAccum and returns that
; byte. The low nibble indexes the bank-1 table, and that byte becomes the
; count at $FFA6.
;
; BC is stored at hScriptPtr (high at $FFA3, low at $FFA2) with the 3-byte
; form, and .resume is planted as hScriptHandler, also with the 3-byte form.
; Execution falls into .resume.
;
; .resume returns until (hMainLoopCounter & 3) == 3. A zero count then jumps
; to DispatchScriptOpcode. A nonzero count is decremented back into $FFA6
; and the routine returns, so the next pass through hScriptHandler enters
; .resume again.
;
; What the table byte counts is still unknown. $FFA6 has no name yet.
; wCurrentROMBank, rROMB0, hScriptPtr, and hScriptHandler are the names from
; reset.asm. AddDividerStep and hDividerAccum are the names from
; add_divider_step.asm. hMainLoopCounter is the name from main_loop.asm.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

Bank1NibblePhaseCountdown::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call AddDividerStep
    and $0f
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ldh [$FFA6], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(.resume)
    ld [hScriptHandler], a
    ld a, HIGH(.resume)
    ld [hScriptHandler + 1], a
.resume::
    ldh a, [hMainLoopCounter]
    and $03
    cp $03
    ret nz
    ldh a, [$FFA6]
    and a
    jp z, DispatchScriptOpcode
    dec a
    ldh [$FFA6], a
    ret
