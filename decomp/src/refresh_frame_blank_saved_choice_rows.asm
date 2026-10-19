; Bank 3 at $565B. Called before the saved choice re-arms the slot.
;
; wCallbackBank becomes 3. wCallback becomes $653A for one RefreshFrame,
; then $6575 for a second RefreshFrame. Both bodies are still INCBIN.
; Each one clears rVBK with the 3-byte form, writes tile $80, and stores
; IdleCallback back at wCallback before it returns.
;
; $653A writes 18 cells at $9DA1 and 18 at $9DC1. Those are window-map
; rows 13 and 14, column 1. $6575 writes 17 cells at $9E02 and 18 at
; $9DE1: row 16 from column 2, then row 15 from column 1.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. RefreshFrame is already source. This routine does
; not write rROMB0.

DEF CALLBACK_BANK_3 EQU $03

; Blanks $9DA1 and $9DC1 with tile $80, then restores IdleCallback.
DEF BlankSavedChoiceRowsA EQU $653A

; Blanks $9E02 and $9DE1 with tile $80, then restores IdleCallback.
DEF BlankSavedChoiceRowsB EQU $6575

RefreshFrameBlankSavedChoiceRows::
    ld a, CALLBACK_BANK_3
    ld [wCallbackBank], a
    ld a, LOW(BlankSavedChoiceRowsA)
    ld [wCallback], a
    ld a, HIGH(BlankSavedChoiceRowsA)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(BlankSavedChoiceRowsB)
    ld [wCallback], a
    ld a, HIGH(BlankSavedChoiceRowsB)
    ld [wCallback + 1], a
    call RefreshFrame
    ret
