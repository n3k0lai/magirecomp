; Word-table handler at $42F2 (table entry 6 at $42A9).
;
; Returns immediately. The masked-action dispatcher at $41E3 reaches this
; through the far call at $0789. Neighboring entries write $CCA7 or $CD80,
; or blank the LCD; this entry changes neither.

ReturnSlotAction::
    ret
