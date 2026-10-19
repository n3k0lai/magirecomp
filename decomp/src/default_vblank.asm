; Default VBlank body. HandleVBlank calls the pointer at wVBlankRoutine,
; and SetupDefaultState stores this address there (DefaultVBlank).
;
; Bit 0 of hVBlankFlags turns the LCD on with LCDC $E3, runs the OAM DMA
; stub at hOAMDMA, maps bank 7, and calls $4B1D. That bank 7 routine is
; still INCBIN. It starts by copying wCameraPixelX to SCX and
; wCameraPixelY to SCY.
;
; Bit 1 maps wCallbackBank and calls wCallback through JumpHL.
; SetupDefaultState installs IdleCallback there.
;
; Bank $30 and WRAM bank 1 are mapped either way. Bit 2 calls the pointer
; at wSoundCommand through JumpHL, the same pointer TimerOverflow uses.
; Bank $30 is mapped again, because that command may have switched banks,
; and UpdateSound runs. This does not restore the banks it changed.
; HandleVBlank restores both shadows after this returns.
;
; The LCDC store is the 3-byte form. The hVBlankFlags loads and the rSVBK
; store are ldh. hVBlankFlags is the name from draw_cgb_notice.asm.
; rLCDC and the $E3 value are the names from turn_off_lcd.asm and
; turn_on_lcd.asm. hOAMDMA is the name from copy_oam_dma_routine.asm.
; wCurrentROMBank, rROMB0, and BANK_INIT are the names from reset.asm.
; wCallback and wCallbackBank are the names from default_state.asm.
; wCameraPixelX and wCameraPixelY are the names from queue_sprite_list.asm.
; wCurrentWRAMBank, rSVBK, wSoundCommand, BANK_SOUND, WRAM_SOUND, and
; UpdateSound are the names from timer_overflow.asm. JumpHL is the
; trampoline at $0789.

RunDefaultVBlank::
    ldh a, [hVBlankFlags]
    bit 0, a
    jr z, .after_lcd
    ld a, LCDC_PLAY
    ld [rLCDC], a
    call hOAMDMA
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call FlushQueuedScroll
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
    ret
