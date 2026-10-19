; Copy the seven HRAM script bytes at $FFA1-$FFA7 to the pointer at hScriptDest.
;
; The destination is little-endian. Both bytes are read with the 3-byte form,
; high byte first. The seven source bytes are ldh and are stored in order.
; hScriptDest is the name from finish_startup.asm. hScriptBank, hScriptPtr,
; and hScriptHandler are the names from reset.asm. $FFA6 and $FFA7 are the
; last two bytes of that record; their roles are still unknown.
;
; finish_startup.asm calls this through CopyScriptRecord. .high_in_a is $290D:
; callers jump there with the destination high byte already in A. .from_third
; is $2918: a caller enters with HL already at the third destination byte, so
; only $FFA3-$FFA7 are stored. Those callers are still INCBIN.

CopyScriptBytes::
    ld a, [hScriptDest + 1]
.high_in_a:
    ld h, a
    ld a, [hScriptDest]
    ld l, a
    ldh a, [hScriptBank]
    ld [hl+], a
    ldh a, [hScriptPtr]
    ld [hl+], a
.from_third:
    ldh a, [hScriptPtr + 1]
    ld [hl+], a
    ldh a, [hScriptHandler]
    ld [hl+], a
    ldh a, [hScriptHandler + 1]
    ld [hl+], a
    ldh a, [hScriptBank + 5]
    ld [hl+], a
    ldh a, [hScriptBank + 6]
    ld [hl+], a
    ret
