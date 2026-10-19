; Script helper at $1997. Saves BC at hScriptPtr (high byte first, the
; 3-byte form), then splits [BC].
;
; $19A7, still INCBIN, stores the low six bits of that byte at $FFA7 and
; leaves BC alone. $19AD, still INCBIN, turns the high two bits into a
; count of 1-4 at $FFA6 and advances BC. The dec bc puts BC back on the
; same byte. Both helpers return here, then this returns.
;
; hScriptPtr is the name from reset.asm. $FFA6 and $FFA7 have no names yet.

; Bank 0, still INCBIN. Low six bits of [BC] into $FFA7.
; Bank 0, still INCBIN. High two bits of [BC] plus one into $FFA6, then inc BC.

SaveScriptPtrAndSplitByte::
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    call StoreLowSixBitsIntoFFA7
    call ReloadHighBitsIntoFFA6
    dec bc
    ret
