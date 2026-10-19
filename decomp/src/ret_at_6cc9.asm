; Lone `ret` at $6CC9, between WriteSlot24ScriptRecord and DrawIndexedSlots.
; Both paths of the slot $24 writer already return. The bank 6 notes do not
; call this address. What leaves the byte here is still unknown.

RetAt6CC9::
    ret
