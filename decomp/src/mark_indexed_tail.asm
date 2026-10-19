; MarkIndexedTail. Bank 2 at $57DE.
;
; RunFlaggedMeasureScript calls this after clearing bit 7 of $D389.
; $01 is stored at wIndexedCallFlag so FillIndexedSlot appends the extra
; bytes after its seven-byte copy. CallBankedHL then runs that routine in
; bank 5. LIST_TAIL_MARK ($FC) is stored at $C971, eight bytes after the
; record+15 tail at $C969. What earlier code left in the indexed pointer
; is still unknown.
;
; wIndexedCallFlag is the name from indexed_tail_08.asm. LIST_TAIL_MARK is
; the name from setup_command_4d.asm. FillIndexedSlot and CallBankedHL are
; already source.

DEF INDEXED_LIST_TAIL EQU $C971

MarkIndexedTail::
    ld a, $01
    ld [wIndexedCallFlag], a
    ld hl, FillIndexedSlot
    ld e, FAR_BANK_5E62
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [INDEXED_LIST_TAIL], a
    ret
