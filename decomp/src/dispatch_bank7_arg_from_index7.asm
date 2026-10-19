; Bank 7 entry at $7465. Hand the argument dispatcher a later table base.
;
; CopyThreeBytesCall7465 stores three script bytes at $C9FC and calls here
; with bank 7 mapped. $5D8D is seven words into DefaultBank7ArgTable, so the
; index at $C9FC selects that table from entry 7 onward. DispatchBank7ArgIndex
; doubles the index, loads the handler, and jumps to it with the $C9FD byte
; in E. $C9FE is left for the handler.
;
; DefaultBank7ArgTable and DispatchBank7ArgIndex are the names from
; dispatch_bank7_arg.asm.

; Word 7 of the default table. Still INCBIN.
DEF Bank7ArgTableFromIndex7 EQU DefaultBank7ArgTable + 7 * 2

DispatchBank7ArgFromIndex7::
    ld hl, Bank7ArgTableFromIndex7
    jp DispatchBank7ArgIndex
