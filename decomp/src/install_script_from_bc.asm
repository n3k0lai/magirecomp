; Script path at $1504. The caller is still INCBIN.
;
; Three bytes at BC become the script record: bank, pointer low, pointer
; high. BC is left on the high byte. $C6F4 is set to 1. hScriptHandler
; becomes INITIAL_SCRIPT_HANDLER ($0A66). Those two handler stores are the
; 3-byte form. The routine then returns.
;
; $1514 is an entry that only plants the handler. What reaches it is still
; unknown.
;
; hScriptBank, hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are
; the names from reset.asm. wFlagC6F4 is the name from
; install_parked_script.asm.

InstallScriptFromBC::
    ld a, [bc]
    ldh [hScriptBank], a
    inc bc
    ld a, [bc]
    ldh [hScriptPtr], a
    inc bc
    ld a, [bc]
    ldh [hScriptPtr + 1], a
    ld a, $01
    ld [wFlagC6F4], a

PlantInitialHandler1514::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
