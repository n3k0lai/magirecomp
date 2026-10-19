; Enable SRAM in the bank recorded at wSRAMBank, call the jump at $1397,
; then disable SRAM.
;
; $1397 reads one byte at BC, doubles it, and jumps through the word table
; at $1234. That target returns here. DE is the word it left behind.
; `add a, $00` keeps the bank byte and its flags; nothing reads them.
;
; A zero DE continues at $1443, still INCBIN. Any other DE stores BC as
; hScriptPtr and $1465 as hScriptHandler, then returns. The stores are the
; three-byte form. $1465 reads a bank and a pointer from BC and jumps to
; DispatchScriptOpcode.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. hScriptPtr and hScriptHandler are
; the names from reset.asm.

; Still INCBIN. Reads BC as a table index and returns through the table.
DEF LookupWordAt1234 EQU $1397
; Still INCBIN. Taken when the lookup leaves DE at zero.
; Planted as hScriptHandler. Still INCBIN.
DEF ScriptHandler1465 EQU $1465

SRAMLookupInstallScript::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    call LookupWordAt1234
    xor a
    ld [rRAMG], a
    ld a, e
    or d
    jr z, LookupZeroInstallDispatcher
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(ScriptHandler1465)
    ld [hScriptHandler], a
    ld a, HIGH(ScriptHandler1465)
    ld [hScriptHandler + 1], a
    ret
