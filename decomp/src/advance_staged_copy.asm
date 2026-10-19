; Bank 1 continuation of CopyStagedByteIntoBanks5And3. That entry pushed
; the destination, then the source, and jumps here when the cell edge is
; not still reloading (or when wLCDC is zero and the edge test is skipped).
;
; $FFA6 counts cells left in the row, including the one just copied.
; A count above one stores the decremented count, advances both pointers
; by one, and increments the column at $C703. wLCDC nonzero returns so
; the next cell waits for another call. wLCDC zero jumps through
; hScriptHandler, which is this routine while the copy is running, so
; the row fills without waiting.
;
; A count of one reloads $FFA6 from $FFA7 (the row width), rewinds the
; column by width-1, and adds $C847-(width-1) to both pointers. That
; pitch leaves each pointer one row ahead. $C702, the row, increments,
; and $C704 counts rows still to copy. A remaining row returns. The last
; row clears bit 7 of hScriptBank and plants DispatchScriptOpcode
; ($0A66) with the 3-byte stores.
;
; wLCDC is the name from turn_off_lcd.asm. hScriptBank, hScriptHandler,
; and DispatchScriptOpcode are the names from reset.asm and the opcode
; dispatcher. $FFA6, $FFA7, $C6FE, $C700, $C702, $C703, $C704, and $C847
; have no names yet. This step does not call or jump to a fixed INCBIN
; address.

AdvanceStagedCopy::
    pop bc
    pop de
    ldh a, [$ffa6]
    dec a
    jr z, .nextRow

    ldh [$ffa6], a
    inc bc
    ld a, b
    ld [$c6ff], a
    ld a, c
    ld [$c6fe], a
    inc de
    ld a, d
    ld [$c701], a
    ld a, e
    ld [$c700], a
    ld hl, $c703
    inc [hl]
    ld a, [wLCDC]
    and a
    ret nz

    ldh a, [hScriptHandler + 1]
    ld h, a
    ldh a, [hScriptHandler]
    ld l, a
    jp hl

.nextRow:
    ldh a, [$ffa7]
    ldh [$ffa6], a
    dec a
    ld l, a
    ld a, [$c703]
    sub l
    ld [$c703], a
    ld a, [$c847]
    sub l
    ld l, a
    ld h, $00
    push hl
    add hl, bc
    ld a, h
    ld [$c6ff], a
    ld a, l
    ld [$c6fe], a
    pop hl
    add hl, de
    ld a, h
    ld [$c701], a
    ld a, l
    ld [$c700], a
    ld hl, $c702
    inc [hl]
    ld a, [$c704]
    dec a
    jr z, .done

    ld [$c704], a
    ret

.done:
    ld hl, hScriptBank
    res 7, [hl]
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret

AdvanceStagedCopyEnd:
