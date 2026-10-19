; Bank 7 arg-table indexes 12 and 13. Both words in DefaultBank7ArgTable
; point here. DispatchBank7Arg enters with the $C9FD byte in E, D cleared,
; and bank 7 still mapped. This handler ignores that and returns.
;
; DefaultBank7ArgTable is the name from dispatch_bank7_arg.asm.

Bank7ArgReturn::
    ret
