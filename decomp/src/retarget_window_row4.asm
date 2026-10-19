; Bank 1 at $49E2. RetargetWindowBlank plants this as hScriptHandler after
; it points wCallback at BlankWindowSpanRows02.
;
; This pass points wCallback at $4745 and plants $49F7 as the next
; hScriptHandler. Both addresses are still INCBIN. The bank byte is left
; alone. Every store is the 3-byte form.
;
; $4745 selects VRAM bank 0, calls WriteFifteenWindowTiles at $9C85
; (window-map row 4, columns 5-19), then stores IdleCallback in wCallback.
; $49F7 is the next script handler.
;
; wCallback and IdleCallback are the names from default_state.asm.
; hScriptHandler is the name from reset.asm. WriteFifteenWindowTiles is
; the name from write_fifteen_window_tiles.asm. BlankWindowSpanRows02 is
; the name from blank_window_span_rows_02.asm.

RetargetWindowRow4::
    ld a, LOW($4745)
    ld [wCallback], a
    ld a, HIGH($4745)
    ld [wCallback + 1], a
    ld a, LOW($49F7)
    ld [hScriptHandler], a
    ld a, HIGH($49F7)
    ld [hScriptHandler + 1], a
    ret
