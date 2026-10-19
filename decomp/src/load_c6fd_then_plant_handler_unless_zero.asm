; Entry at $1788. Load [$C6FD] into A and jump to
; PlantInitialScriptHandlerUnlessZero. That routine returns when A is
; zero and otherwise plants INITIAL_SCRIPT_HANDLER ($0A66).
;
; $C6FD is wUnknownC6F5 + 8. AddAndShift copies $C6FC one byte forward
; into it. What a nonzero value means is still unknown.
; wUnknownC6F5 is the name from write_quad_records.asm.
; PlantInitialScriptHandlerUnlessZero is already source.
;
; Nothing this entry jumps to is still inside an INCBIN.

LoadC6FDThenPlantHandlerUnlessZero::
    ld a, [wUnknownC6F5 + 8]
    jp PlantInitialScriptHandlerUnlessZero
