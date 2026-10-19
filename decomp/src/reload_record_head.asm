; Bank 1 at $659D, the first byte after CallBank4ThenPlantHead659D.
; rROMB0 is left alone.
;
; BC points at a record. LoadRecordHead copies that pointer and the
; next ten head bytes into HRAM and clears the word at $C6D2.
; WriteRecordHead stores those ten bytes back through the pointer.
; The record bytes themselves are unchanged.

ReloadRecordHead::
    call LoadRecordHead
    call WriteRecordHead
    ret
