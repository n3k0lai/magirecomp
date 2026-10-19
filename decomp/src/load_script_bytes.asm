; Point hScriptDest at HL and copy the seven-byte script record into HRAM.
;
; The destination pointer is stored with the 3-byte form, high byte at $FFA0
; then low byte at $FF9F. The seven bytes land in $FFA1-$FFA7 with ldh.
; BC receives the script pointer: C is the second byte, B the third.
; hScriptDest is the name from finish_startup.asm. hScriptBank, hScriptPtr,
; and hScriptHandler are the names from reset.asm. $FFA6 and $FFA7 are the
; last two bytes of that record; their roles are still unknown.
;
; .byte_in_a is $2931. Bank $5B jumps here when the bank byte is already in A
; and HL points at the second byte. LoadScriptLastByte is $2944: banks $25
; and $54 call it to read one more byte from HL into $FFA7. StoreScriptLastByte
; is $2945: bank $7C jumps here to store A at $FFA7. The name LoadScriptRecord
; in run_script_record.asm is the same entry as LoadScriptBytes.

LoadScriptBytes::
    ld a, h
    ld [hScriptDest + 1], a
    ld a, l
    ld [hScriptDest], a
    ld a, [hl+]
.byte_in_a:
    ldh [hScriptBank], a
    ld a, [hl+]
    ldh [hScriptPtr], a
    ld c, a
    ld a, [hl+]
    ldh [hScriptPtr + 1], a
    ld b, a
    ld a, [hl+]
    ldh [hScriptHandler], a
    ld a, [hl+]
    ldh [hScriptHandler + 1], a
    ld a, [hl+]
    ldh [hScriptBank + 5], a
LoadScriptLastByte::
    ld a, [hl+]
StoreScriptLastByte::
    ldh [hScriptBank + 6], a
    ret

; $2948 returns immediately. The notes do not call it.
ImmediateRet::
    ret
