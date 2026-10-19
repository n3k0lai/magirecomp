; MirrorAcceptedSave. CheckSaveSignature jumps here when the stamp matches.
;
; $A000 in SRAM bank 0 must be 0 or 2. Any other value jumps to WipeSave.
; 0 copies SRAM banks 0 and 1 onto banks 2 and 3. 2 writes that flag into
; bank 2, then copies banks 2 and 3 onto banks 0 and 1. The routine at $4048
; copies one bank onto its pair through WRAM bank 6. It is called twice, and
; each call advances the source and destination bank numbers in D and E.
; $C727 receives the first destination bank (2 when the flag is 0, else 0).
; SRAM is disabled before the return.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the
; names from handle_start_press.asm. wCurrentWRAMBank and rSVBK are the names
; from timer_overflow.asm. WipeSave is the name from check_save_signature.asm.

; Still INCBIN. Copies SRAM bank D onto SRAM bank E through WRAM bank 6.
DEF CopySaveBankPair EQU $4048

; First byte of SRAM. 0 and 2 are the only values that keep the save.
DEF sSaveBankFlag EQU $A000
DEF SAVE_FLAG_BACKUP EQU $02

; WRAM bank used as the 4 KiB copy buffer at $D000.
DEF SAVE_COPY_WRAM_BANK EQU $06

MirrorAcceptedSave:
    xor a
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [sSaveBankFlag]
    ld b, a
    and a
    jr z, .haveFlag

    cp SAVE_FLAG_BACKUP
    jp nz, WipeSave

.haveFlag:
    ld a, SAVE_FLAG_BACKUP
    ld [rRAMB], a
    ld a, b
    ld [sSaveBankFlag], a
    ld d, a
    ld a, b
    xor SAVE_FLAG_BACKUP
    ld e, a
    ld [wSRAMBank], a
    ld a, SAVE_COPY_WRAM_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call CopySaveBankPair
    call CopySaveBankPair
    xor a
    ld [rRAMG], a
    ret
