; Script tail at $27C0.
;
; Calls $40B7 in the ROM bank DispatchScriptOpcode restored from
; hScriptBank. This tail does not write rROMB0. Control then jumps to
; DispatchScriptOpcode ($0A66). What $40B7 does depends on that bank.

DEF ScriptBankRoutine40B7 EQU $40B7

CallScriptBank40B7::
    call ScriptBankRoutine40B7
    jp DispatchScriptOpcode

CallScriptBank40B7End:
