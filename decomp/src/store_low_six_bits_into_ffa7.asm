; Script helper at $19A7. Stores the low six bits of the byte at [BC]
; into $FFA7 and returns. BC stays on that byte.
;
; and $3F keeps bits 5-0. Callers that also want the high two bits as a
; count of 1-4 follow this with the helper at $19AD.
;
; $FFA7 has no name yet. Nothing here is still inside an INCBIN.

StoreLowSixBitsIntoFFA7::
    ld a, [bc]
    and $3F
    ldh [$FFA7], a
    ret
