; Bank 0 at $26CC. Shared tail of the record paths at $2684, $2689, and
; $26B7. Those callers leave E as the byte to store and HL on a little-endian
; word. That word is an address.
;
; WRAM bank 3 is written to $C937 and selected. $C937 is wCurrentWRAMBank and
; the select register is rSVBK; both names are defined later, in
; timer_overflow.asm, so this file uses the addresses. E is stored at the
; address the word names. wLCDC is only tested for zero. The turn-off path
; clears it, so a dark screen returns here. wLCDC is the name from
; turn_off_lcd.asm.
;
; When the LCD is on, DE is the word at $C99C and HL is the word at $C99E.
; C is the byte at that HL. Bank 7 is mapped through wCurrentROMBank and
; rROMB0, then $4C53 in that bank is called. That routine is still INCBIN.
; After it returns, D, E, H, and L are saved in the same slots Opcode03 uses:
; D at $C8C8, E at $C8C7, H at $C8C6, L at $C8C5. Those four are
; wScriptCellPos and wScriptCellAddr in opcode_03_continue.asm, which is
; included later.
;
; $26F9, $2700, and $2701 are entries into that save. $26F9 stores A as the
; column byte; the fall-through reaches it with A = D. $2700 reloads A from
; H and falls into $2701, which stores A as the address high byte and L as
; the low byte. $2708 only plants the callback: wCallback becomes $4CA1 and
; wCallbackBank becomes 7. That body is still INCBIN. wCurrentROMBank and
; rROMB0 are the names from reset.asm. wCallback and wCallbackBank are the
; names from default_state.asm.

; Callback planted at wCallback. Bank 7, still INCBIN.
DEF WORD_STORE_CALLBACK EQU $4CA1
DEF WORD_STORE_CALLBACK_BANK EQU $07

; WRAM bank selected for the store of E.
DEF WORD_STORE_WRAM_BANK EQU $03

StoreEThroughWordInWram3::
    ld a, WORD_STORE_WRAM_BANK
    ld [$c937], a
    ldh [$ff70], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld [hl], e
    ld a, [wLCDC]
    and a
    ret z

    ld a, [$c99c]
    ld e, a
    ld a, [$c99d]
    ld d, a
    ld a, [$c99f]
    ld h, a
    ld a, [$c99e]
    ld l, a
    ld c, [hl]
    ld a, WORD_STORE_CALLBACK_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call BuildMetatilePointers
    ld a, d

StoreCellColumnFromA::
    ld [$c8c8], a
    ld a, e
    ld [$c8c7], a

StoreCellAddrFromHL::
    ld a, h

StoreCellAddrHighFromA::
    ld [$c8c6], a
    ld a, l
    ld [$c8c5], a

PlantWordStoreCallback::
    ld a, WORD_STORE_CALLBACK_BANK
    ld [wCallbackBank], a
    ld a, LOW(WORD_STORE_CALLBACK)
    ld [wCallback], a
    ld a, HIGH(WORD_STORE_CALLBACK)
    ld [wCallback + 1], a
    ret
