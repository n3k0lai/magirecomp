; Save the script pair and a three-byte script record into SRAM, then
; return to the script handler.
;
; SRAM bank wSRAMBank is selected with `add a, $00`, which keeps that
; bank byte and its flags. Nothing reads them. SRAM is enabled. The word
; at wScriptBaseLo is copied to sSavedScriptPair ($A015, then $A016).
;
; Three script bytes at BC are stored next. The first is the script bank
; at sSavedScriptBank ($A012). SaveScriptPtrToSRAM is the entry after
; that store: the next two bytes are the little-endian pointer at
; sSavedScriptPtr ($A013, then $A014). BC advances past each byte it
; consumes. SRAM is disabled, then control jumps to
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. wScriptBaseLo and wScriptBaseHi are the names from
; opcode_02.asm. sSavedScriptBank, sSavedScriptPtr, and sSavedScriptPair
; are the names from load_sram_script_dispatch.asm.

SaveScriptTripleToSRAM::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wScriptBaseLo]
    ld [sSavedScriptPair], a
    ld a, [wScriptBaseHi]
    ld [sSavedScriptPair + 1], a
    ld a, [bc]
    inc bc
    ld [sSavedScriptBank], a

SaveScriptPtrToSRAM::
    ld a, [bc]
    inc bc
    ld [sSavedScriptPtr], a
    ld a, [bc]
    inc bc
    ld [sSavedScriptPtr + 1], a
    xor a
    ld [rRAMG], a
    jp INITIAL_SCRIPT_HANDLER
