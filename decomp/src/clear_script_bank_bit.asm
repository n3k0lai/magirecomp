; Clear script-bank bit 7 and restore DispatchScriptOpcode. Bank 1 at
; $4962. Opcode9ABody jumps here when wUnknownC6EE is 0. The handler at
; $495D also falls through after it stores 0 there.
;
; Bit 7 of hScriptBank forces bank 1. Clearing it lets the next pass use
; the bank byte again. hScriptHandler becomes DispatchScriptOpcode
; ($0A66). Both stores are the 3-byte form.
;
; hScriptBank and hScriptHandler are the names from reset.asm.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

ClearScriptBankBit::
    ld hl, hScriptBank
    res 7, [hl]
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
