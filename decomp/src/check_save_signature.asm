; LoadSave. Reset calls $4087 after the default state is stored.
;
; SRAM bank 0 is selected and SRAM is enabled. The sixteen bytes at $A002
; must match the sixteen bytes at $4000 in this ROM bank. The sixteen bytes
; at $BFF0 must match those same bytes in reverse, from $400F down to $4000.
; $4000 is both the RAM-bank register and the stamp when this bank is mapped.
; A mismatch jumps to $410B. A match jumps to $4010. Neither path returns here.
;
; rRAMG is the name from reset.asm. rRAMB and SRAM_ENABLE are the names from
; handle_start_press.asm. The label cannot be LoadSave: reset.asm already
; defines that address.

; Still INCBIN in this bank. Wipes the save when the stamp does not match.
DEF WipeSave EQU $410B

; Forward stamp, then the reversed stamp at the end of the 8 KiB SRAM.
DEF sSaveStamp EQU $A002
DEF sSaveStampTail EQU $BFF0
DEF SAVE_STAMP_LEN EQU $10

; First byte of the stamp in this ROM bank.
DEF ROM_STAMP EQU $4000

CheckSaveSignature:
    xor a
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld d, SAVE_STAMP_LEN
    ld bc, sSaveStamp
    ld hl, ROM_STAMP

.forward:
    ld a, [hl+]
    ld e, a
    ld a, [bc]
    cp e
    jp nz, WipeSave
    inc bc
    dec d
    jr nz, .forward

    ld d, SAVE_STAMP_LEN
    ld bc, sSaveStampTail
    dec hl

.reverse:
    ld a, [hl-]
    ld e, a
    ld a, [bc]
    cp e
    jp nz, WipeSave
    inc bc
    dec d
    jr nz, .reverse

    jp MirrorAcceptedSave
