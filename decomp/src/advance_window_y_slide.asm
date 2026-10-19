; Window-Y slide. Bank 1 at $49F7. RetargetWindowRow4 plants this as
; hScriptHandler after it points wCallback at the window row-4 blank.
;
; $FFA6 is the index into the ten window-Y bytes at $48D5. A value below
; $0A is that index. The byte is written to wWindowY, then the index is
; stored one higher. wCallbackBank becomes 1 and wCallback becomes
; CopyWindowPosition ($48BE), which copies wWindowX and wWindowY onto
; rWX, rWY, and rLYC. The first pass reads index 0 ($8F). Later passes
; walk the table toward index 9 ($68).
;
; $0A skips the table. Bit 7 of hScriptBank is cleared (that bit had
; forced bank 1) and hScriptHandler becomes $2507. Both handler stores
; are the 3-byte form. $48D5 and $2507 are still INCBIN.
;
; wWindowY is the name from setup_window.asm. wCallback and wCallbackBank
; are the names from default_state.asm. CopyWindowPosition is the name
; from copy_window_position.asm. hScriptBank and hScriptHandler are the
; names from reset.asm. $FFA6 has no name yet.

AdvanceWindowYSlide::
    ld a, [$ffa6]
    cp $0a
    jp z, .indexDone

    ld e, a
    inc a
    ld d, $00
    ld [$ffa6], a
    ld hl, $48d5
    add hl, de
    ld a, [hl]
    ld [wWindowY], a
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW(CopyWindowPosition)
    ld [wCallback], a
    ld a, HIGH(CopyWindowPosition)
    ld [wCallback + 1], a
    ret

.indexDone:
    ld hl, hScriptBank
    res 7, [hl]
    ld a, LOW($2507)
    ld [hScriptHandler], a
    ld a, HIGH($2507)
    ld [hScriptHandler + 1], a
    ret
