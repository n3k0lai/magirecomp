; Opcode $9A countdown. Bank 1 at $490E. Opcode9ABody stores 9 at $FFA6
; and plants this address as hScriptHandler.
;
; A nonzero count is the index into the ten window-Y bytes at $48D5, then
; the count is stored one lower. That byte is written to wWindowY.
; wCallbackBank becomes 1 and wCallback becomes $48BE, which copies
; wWindowX and wWindowY onto rWX, rWY, and rLYC. The first pass reads
; index 9 ($68). Later passes walk the table back toward $8F.
;
; Zero skips the table, stores WINDOW_Y ($90, the off-screen line from
; SetupWindowTilemap) at wWindowY, and points the same callback at $48BE.
; hSTATHandler becomes EmptyStatHandler. hScriptHandler becomes $495D,
; which clears wUnknownC6EE and resumes script dispatch. $48D5, $48BE,
; and $495D are still INCBIN.
;
; wWindowY is the name from setup_window.asm. wCallback and wCallbackBank
; are the names from default_state.asm. hSTATHandler is the name from
; lcd_stat.asm. EmptyStatHandler is the name from default_state.asm.
; hScriptHandler is the name from reset.asm. Every store below is the
; 3-byte form. $FFA6 has no name yet.

Opcode9ACountdown::
    ld a, [$ffa6]
    and a
    jp z, .finished

    ld c, a
    dec a
    ld b, $00
    ld [$ffa6], a
    ld hl, $48d5
    add hl, bc
    ld a, [hl]
    ld [wWindowY], a
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW($48BE)
    ld [wCallback], a
    ld a, HIGH($48BE)
    ld [wCallback + 1], a
    ret

.finished:
    ld a, WINDOW_Y
    ld [wWindowY], a
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW($48BE)
    ld [wCallback], a
    ld a, HIGH($48BE)
    ld [wCallback + 1], a
    ld a, LOW(EmptyStatHandler)
    ld [hSTATHandler], a
    ld a, HIGH(EmptyStatHandler)
    ld [hSTATHandler + 1], a
    ld a, LOW($495D)
    ld [hScriptHandler], a
    ld a, HIGH($495D)
    ld [hScriptHandler + 1], a
    ret
