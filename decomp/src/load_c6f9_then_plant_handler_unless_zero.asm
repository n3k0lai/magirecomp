; Entry at $177C. Load [$C6F9] into A and jump to
; PlantInitialScriptHandlerUnlessZero. That routine returns when A is
; zero and otherwise plants INITIAL_SCRIPT_HANDLER ($0A66).
;
; $C6F9 is wUnknownC6F5 + 4. AddAndShift copies $C6F8 one byte forward
; into it. What a nonzero value means is still unknown.
; wUnknownC6F5 is the name from write_quad_records.asm.
; PlantInitialScriptHandlerUnlessZero is already source.
;
; Nothing this entry jumps to is still inside an INCBIN.

LoadC6F9ThenPlantHandlerUnlessZero::
    ld a, [wUnknownC6F5 + 4]
    jp PlantInitialScriptHandlerUnlessZero
