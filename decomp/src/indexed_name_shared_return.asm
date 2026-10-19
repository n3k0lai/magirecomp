; Shared return at bank 7 $6BD5 (file $01EBD5).
;
; The first three indexed name records use this address as their first
; pointer, and the blank record also uses it as its second pointer. Their
; third pointers are the same ret. LoadSelectedRecordToD100 calls the first
; pointer, so those records return immediately. What selects the third
; pointer is still unknown.

IndexedNameSharedReturn::
    ret
