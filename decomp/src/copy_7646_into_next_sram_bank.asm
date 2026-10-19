; FillSRAMAfterZeroScriptByte calls this in bank 2 after the zero script
; byte fills SRAM.
;
; SRAM bank wSRAMBank + 1 is selected and enabled. $1F bytes are copied
; from $7646 in this ROM bank to sEntryBase. SRAM bank wSRAMBank is then
; selected with `add a, $00`, which keeps that bank number. The ten bytes
; at sEntryIds are set to $FF, and SRAM is disabled.
;
; The $1F bytes at $7646 are still INCBIN. Its file address is $00B646.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. sEntryBase and sEntryIds are the
; names from indexed_tail_07.asm.

DEF ROM_7646 EQU $7646
DEF COPY_7646_LENGTH EQU $1F

Copy7646IntoNextSRAMBank::
    ld bc, ROM_7646
    ld hl, sEntryBase
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld d, COPY_7646_LENGTH
.copyByte:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyByte
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld hl, sEntryIds
    ld a, $ff
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [rRAMG], a
    ret
