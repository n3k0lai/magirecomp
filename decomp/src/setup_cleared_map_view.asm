; Bank 4 at $6439. The routine at $632E, still INCBIN, calls this and then
; waits until $C9AE is nonzero.
;
; ClearMapScrollBytes zeros the scroll latches and fills the eight panel
; slots with $F0. The LCD is turned off and SetTimerModulo arms the timer.
; LoadMapPanels copies the eight panel sources. IdleCallback is stored at
; wCallback again, low byte first. CallBankedHL maps bank 1 and runs
; InitPointerList. The shadow-OAM cursors are cleared with the immediate
; form, every sprite is parked, and WriteQuadRecords runs. The LCD is
; turned on if it is off.
;
; wScrollX and wScrollY, just cleared, are copied to the camera and to
; rSCX and rSCY. IdleCallback is stored at wCallback a second time.
; EmptyStatHandler is stored at hSTATHandler with the 3-byte form.
;
; ClearMapScrollBytes is in this bank. TurnOffLCD, SetTimerModulo,
; LoadMapPanels, ParkSprites, WriteQuadRecords, and TurnOnLCDIfOff are
; bank 0. CallBankedHL is the name from call_hl_in_bank.asm.
; InitPointerList is bank 1 at $40D3. wShadowOAMCursor and
; wShadowOAMPrevEnd are the names from hide_leftover_sprites.asm.
; wScrollX, wScrollY, wCameraPixelX, wCameraPixelY, rSCX, and rSCY are
; the names from lcd_off_setup.asm and queue_sprite_list.asm. wCallback,
; IdleCallback, and EmptyStatHandler are the names from default_state.asm.
; hSTATHandler is the name from lcd_stat.asm.

SetupClearedMapView::
    call ClearMapScrollBytes
    call TurnOffLCD
    call SetTimerModulo
    call LoadMapPanels
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ld hl, InitPointerList
    ld e, $01
    call CallBankedHL
    ld a, $00
    ld [wShadowOAMCursor], a
    ld [wShadowOAMPrevEnd], a
    call ParkSprites
    call WriteQuadRecords
    call TurnOnLCDIfOff
    ld a, [wScrollX]
    ld [wCameraPixelX], a
    ldh [rSCX], a
    ld a, [wScrollY]
    ld [wCameraPixelY], a
    ldh [rSCY], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ld a, LOW(EmptyStatHandler)
    ld [hSTATHandler], a
    ld a, HIGH(EmptyStatHandler)
    ld [hSTATHandler + 1], a
    ret
