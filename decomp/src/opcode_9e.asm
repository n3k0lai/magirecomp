; Script opcode $9E. DispatchScriptOpcode jumps here.
;
; The SRAM bank at $C727 is written to $4000. `add a, $00` keeps that
; bank byte and sets flags nobody reads. SRAM is enabled, then the next
; two script bytes become HL. $2C57 reads the little-endian word at HL
; and writes three ASCII digits at $C949. BC is the script pointer, so
; it is saved across that call. SRAM is disabled, and control returns
; to DispatchScriptOpcode with BC on the next opcode.
;
; rRAMG is the name from reset.asm. $C727, $4000, and the enable value
; $0A are named wSRAMBank, rRAMB, and SRAM_ENABLE in
; handle_start_press.asm, which is included later, so this file uses
; those addresses. $2C57 is still INCBIN.

; SRAM bank byte. Named wSRAMBank later.
DEF wSRAMBankC727 EQU $C727

; SRAM bank register. Named rRAMB later.
DEF rRAMB4000 EQU $4000

; Value written to rRAMG to enable SRAM. Named SRAM_ENABLE later.
DEF SRAM_ENABLE_0A EQU $0A

Opcode9E::
    ld a, [wSRAMBankC727]
    add a, $00
    ld [rRAMB4000], a
    ld a, SRAM_ENABLE_0A
    ld [rRAMG], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    push bc
    call FormatHLWordThreeDigits
    pop bc
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode
