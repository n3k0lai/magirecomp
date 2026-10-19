; Store index $0A in wUnknownCC47 and jump to the indexed setup at $61F1.
;
; The start-button hook calls this after positioning the window, then
; writes 0 back to wUnknownCC47 when the jump returns. $61F1, still
; INCBIN in this bank, doubles that index and follows a pointer table at
; $51D9. What entry $0A selects is still unknown.
;
; wUnknownCC47 is the name from handle_start_press.asm.

; Table index passed through wUnknownCC47.
DEF INDEXED_SETUP_0A EQU $0A

SelectIndexedSetup0A::
    ld a, INDEXED_SETUP_0A
    ld [wUnknownCC47], a
    jp IndexedSetup
