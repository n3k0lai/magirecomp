; Entry at $178E. Load [$C6F9] into A and jump to
; MatchScriptByteThenPlantHandler. That routine returns when [BC]
; differs from A. On a match it consumes the byte, saves BC as
; hScriptPtr, and plants INITIAL_SCRIPT_HANDLER ($0A66).
;
; $C6F9 is wUnknownC6F5 + 4. AddAndShift copies $C6F8 one byte forward
; into it. What a match means is still unknown.
; wUnknownC6F5 is the name from write_quad_records.asm.
; MatchScriptByteThenPlantHandler is already source.
;
; Nothing this entry jumps to is still inside an INCBIN.

LoadC6F9ThenMatchScriptByte::
    ld a, [wUnknownC6F5 + 4]
    jp MatchScriptByteThenPlantHandler
