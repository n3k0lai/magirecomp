; Script helper at $19AD. Reloads the high two bits of the byte at [BC]
; into $FFA6 as a count of 1-4, then advances BC.
;
; and $C0 keeps bits 7-6. swap a moves them into bits 3-2, and the two
; rra instructions shift them into bits 1-0 (0-3). inc a makes the count
; 1-4. Callers that still want BC on the same byte follow this with dec bc.
;
; $FFA6 has no name yet. Nothing here is still inside an INCBIN.

ReloadHighBitsIntoFFA6::
    ld a, [bc]
    and $C0
    swap a
    rra
    rra
    inc a
    ldh [$FFA6], a
    inc bc
    ret
