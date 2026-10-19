; VBlank body at $37AA. Sibling of RunC9C0WindowVBlank. The caller is
; still unknown.
;
; Bit 0 of hVBlankFlags turns the LCD on with LCDC $E3 and runs the OAM
; DMA stub at hOAMDMA. rWX is set to $A7 so the window starts at pixel
; 160 and sits off the right edge. rSCX is cleared, rSCY is set to $48,
; and rLYC is set to $47.
;
; Bit 1 maps wCallbackBank through rROMB0 only. wCurrentROMBank is left
; alone. The pointer at wCallback is called through JumpHL.
; SetupDefaultState installs IdleCallback there.
;
; Bank $30 and WRAM bank 1 are mapped either way. Bit 2 calls the pointer
; at wSoundCommand through JumpHL, the same pointer TimerOverflow uses.
; Bank $30 is mapped again, because that command may have switched banks,
; and UpdateSound runs. hSTATHandler is then set to
; StatAddC9BEIntoC9C0 ($3776). This does not restore the banks it changed.
;
; The LCDC store is the 3-byte form. The hVBlankFlags loads, the rSVBK
; store, and the hSTATHandler stores are ldh. hVBlankFlags is the name
; from draw_cgb_notice.asm. rLCDC and LCDC_PLAY are the names from
; turn_off_lcd.asm and turn_on_lcd.asm. hOAMDMA is the name from
; copy_oam_dma_routine.asm. STAT_WX_OFF_RIGHT is the name from
; stat_hide_window_scroll_c9c1.asm. rWX is the name from setup_window.asm.
; rSCX and rSCY are the names from lcd_off_setup.asm. rLYC is the name
; from copy_window_position.asm. wCurrentROMBank and rROMB0 are the names
; from reset.asm. wCallback and wCallbackBank are the names from
; default_state.asm. wCurrentWRAMBank, rSVBK, wSoundCommand, BANK_SOUND,
; WRAM_SOUND, and UpdateSound are the names from timer_overflow.asm.
; hSTATHandler is the name from lcd_stat.asm. JumpHL is the trampoline
; at $0789. UpdateSound is still INCBIN; its file address is $0C0356 and
; is already listed.

; Fixed background Y scroll for the bit-0 path.
DEF VBLANK_SCY_48 EQU $48

; Line compare value stored in rLYC on the bit-0 path.
DEF VBLANK_LYC_LINE_47 EQU $47

RunFixedScrollWindowVBlank::
    ldh a, [hVBlankFlags]
    bit 0, a
    jr z, .after_lcd
    ld a, LCDC_PLAY
    ld [rLCDC], a
    call hOAMDMA
    ld a, STAT_WX_OFF_RIGHT
    ldh [rWX], a
    xor a
    ldh [rSCX], a
    ld a, VBLANK_SCY_48
    ldh [rSCY], a
    ld a, VBLANK_LYC_LINE_47
    ldh [rLYC], a
.after_lcd:
    ldh a, [hVBlankFlags]
    bit 1, a
    jr z, .after_callback
    ld a, [wCallbackBank]
    ld [rROMB0], a
    ld a, [wCallback + 1]
    ld h, a
    ld a, [wCallback]
    ld l, a
    call JumpHL
.after_callback:
    ld a, BANK_SOUND
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, WRAM_SOUND
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ldh a, [hVBlankFlags]
    bit 2, a
    jr z, .after_sound_command
    ld a, [wSoundCommand + 1]
    ld h, a
    ld a, [wSoundCommand]
    ld l, a
    call JumpHL
.after_sound_command:
    ld a, BANK_SOUND
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call UpdateSound
    ld a, LOW(StatAddC9BEIntoC9C0)
    ldh [hSTATHandler], a
    ld a, HIGH(StatAddC9BEIntoC9C0)
    ldh [hSTATHandler + 1], a
    ret
