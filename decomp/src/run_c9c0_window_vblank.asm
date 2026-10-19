; VBlank body at $36F9. Sibling of RunDefaultVBlank. The caller is still
; unknown. Nothing in this bank calls the fall-through at $3733.
;
; Bit 0 of hVBlankFlags turns the LCD on with LCDC $E3, runs the OAM DMA
; stub at hOAMDMA, and calls ApplyC9C0WindowThenCallStepFour. That routine
; is already source. It leaves bank 4 mapped.
;
; Bit 1 maps wCallbackBank and calls wCallback through JumpHL.
; SetupDefaultState installs IdleCallback there.
;
; Bank $30 and WRAM bank 1 are mapped either way. Bit 2 calls the pointer
; at wSoundCommand through JumpHL, the same pointer TimerOverflow uses.
; Bank $30 is mapped again, because that command may have switched banks,
; and UpdateSound runs. hSTATHandler is then set to
; StatWindowScrollThenBank4 ($3677). This does not restore the banks it
; changed.
;
; The LCDC store is the 3-byte form. The hVBlankFlags loads, the rSVBK
; store, and the hSTATHandler stores are ldh. hVBlankFlags is the name
; from draw_cgb_notice.asm. rLCDC and LCDC_PLAY are the names from
; turn_off_lcd.asm and turn_on_lcd.asm. hOAMDMA is the name from
; copy_oam_dma_routine.asm. wCurrentROMBank and rROMB0 are the names from
; reset.asm. wCallback and wCallbackBank are the names from
; default_state.asm. wCurrentWRAMBank, rSVBK, wSoundCommand, BANK_SOUND,
; WRAM_SOUND, and UpdateSound are the names from timer_overflow.asm.
; hSTATHandler is the name from lcd_stat.asm. JumpHL is the trampoline
; at $0789. UpdateSound is still INCBIN; its file address is $0C0356 and
; is already listed.

RunC9C0WindowVBlank::
    ldh a, [hVBlankFlags]
    bit 0, a
    jr z, .after_lcd
    ld a, LCDC_PLAY
    ld [rLCDC], a
    call hOAMDMA
    call ApplyC9C0WindowThenCallStepFour
.after_lcd:
    ldh a, [hVBlankFlags]
    bit 1, a
    jr z, .after_callback
    ld a, [wCallbackBank]
    ld [wCurrentROMBank], a
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
    ld a, LOW(StatWindowScrollThenBank4)
    ldh [hSTATHandler], a
    ld a, HIGH(StatWindowScrollThenBank4)
    ldh [hSTATHandler + 1], a
    ret
