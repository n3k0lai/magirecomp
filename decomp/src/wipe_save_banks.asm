; WipeSave. CheckSaveSignature jumps here when the SRAM stamp does not match.
; The name WipeSave is already an EQU in check_save_signature.asm.
;
; Enables SRAM, then fills all four 8 KiB SRAM banks with $00. Banks are
; selected as 3, 2, 1, then 0. Writes the save stamp into SRAM banks 0 and 2,
; records bank 2 in wSRAMBank, and disables SRAM.
;
; rRAMG is the name from reset.asm. rRAMB, SRAM_ENABLE, and wSRAMBank are the
; names from handle_start_press.asm. FillMemory is the name from reset.asm.
; WriteSaveStamp is still INCBIN in this bank.

; Still INCBIN. Copies the ROM stamp forward to $A002 and reversed to $BFF0.
DEF WriteSaveStamp EQU $4141

DEF SRAM_BANK_COUNT EQU $04
DEF SRAM_BANK_SIZE EQU $2000
DEF sSaveBase EQU $A000

WipeSaveBanks:
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld c, SRAM_BANK_COUNT

.clear_bank:
    push bc
    ld a, c
    dec a
    ld [rRAMB], a
    ld hl, sSaveBase
    ld bc, SRAM_BANK_SIZE
    ld a, $00
    ld e, a
    call FillMemory
    pop bc
    dec c
    jr nz, .clear_bank

    xor a
    ld [rRAMB], a
    call WriteSaveStamp
    ld a, $02
    ld [rRAMB], a
    call WriteSaveStamp
    ld a, $02
    ld [wSRAMBank], a
    xor a
    ld [rRAMG], a
    ret
