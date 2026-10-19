; CopySramBlockToHL. Called from InitWram7BeforeReset with the source in
; BC and the destination in HL. The first call reads SRAM at $A000 into
; $D147. The second reads $CD91 into $D336.
;
; WRAM bank 7 is mapped and mirrored in wCurrentWRAMBank. SRAM bank
; wSRAMBank + 1 is selected and enabled. Two $00 bytes are stored, then
; $1E bytes are copied from BC. SRAM is disabled. Four $FF bytes, three
; $00 bytes, and $10 more $00 bytes follow. HL is left past that buffer.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm.

CopySramBlockToHL::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld d, $1E
.copyByte:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyByte
    xor a
    ld [rRAMG], a
    ld a, $FF
    ld d, $04
.fillFF:
    ld [hl+], a
    dec d
    jr nz, .fillFF
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld d, $10
    xor a
.fillZero:
    ld [hl+], a
    dec d
    jr nz, .fillZero
    ret
