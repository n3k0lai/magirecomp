; Bank 2 at $5331. The next uncovered byte after LoadD107EntryThenScript4AE0.
;
; WRAM bank 7 is stored at wCurrentWRAMBank and selected with rSVBK.
; MarkD075BitAndD091 in bank 5 runs, then FillD110FromIndexedEntry in this
; bank. [$D112] is stored at $C9D8 and [$D103] minus one at $C9D9.
; CountdownPanelCallbacks in bank 4 runs from those two bytes. [$D071] is
; set to 1. WriteIndexedNamesAndCount builds the name text. $49 $C9 is
; stored at $C93D so that word points at $C949.
;
; A nonzero [$D09A] plants $4C $F5 $4A $66 $0A at $C71B: bank $4C, pointer
; $4AF5, handler DispatchScriptOpcode. Zero, the closed mark, plants
; $4C $0A $4B $66 $0A: the same bank and handler with pointer $4B0A.
; Either plant returns.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; MarkD075BitAndD091, FillD110FromIndexedEntry, CountdownPanelCallbacks,
; CallBankedHL, WriteIndexedNamesAndCount, and DispatchScriptOpcode are
; already source. Bank $4C at $4AF5 and $4B0A are still INCBIN. Their
; file addresses are $0130AF5 and $0130B0A.

FillD110ThenScript4AF5Or4B0A::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, MarkD075BitAndD091
    ld e, $05
    call CallBankedHL
    call FillD110FromIndexedEntry
    ld a, [$D103]
    dec a
    ld b, a
    ld a, [$D112]
    ld [$C9D8], a
    ld a, b
    ld [$C9D9], a
    ld hl, CountdownPanelCallbacks
    ld e, $04
    call CallBankedHL
    ld a, $01
    ld [$D071], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld a, [$D09A]
    and a
    jr z, .closed
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, LOW($4AF5)
    ld [hl+], a
    ld a, HIGH($4AF5)
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ret

.closed:
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, LOW($4B0A)
    ld [hl+], a
    ld a, HIGH($4B0A)
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ret
