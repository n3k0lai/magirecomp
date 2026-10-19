; Script handler planted by opcode $9B. BC is the script pointer.
;
; The first byte's high nibble is stored at $C6E7 and its low nibble at
; wCallbackBank. The next byte is stored at $C6E8. HL, now past those two
; bytes, is saved as hScriptPtr (high byte first, 3-byte form).
;
; wUnknownC6EC selects a little-endian word from PointedByteWords at $2252.
; Index 0 is $8A40 and index 1 is $8BD0. That word is stored at $C6E9.
; Which bank those addresses belong to is still unknown.
;
; $FFA6 becomes $1A and $C6EB becomes 1, both with the 3-byte form.
; hScriptHandler becomes $230A, also the 3-byte form. That continuation,
; still INCBIN, decrements $FFA6 and returns while the count stays above
; zero.
;
; wCallbackBank is the name from default_state.asm. wUnknownC6EC is the
; name from setup_window.asm. hScriptPtr and hScriptHandler are the names
; from reset.asm. PointedByteWords is the name from
; format_pointed_sram_byte.asm. $C6E7, $C6E8, $C6E9, $C6EB, and $FFA6 have
; no names for this path.

; Next script handler. Decrements $FFA6. Still INCBIN.
DEF Opcode9BCountdown EQU $230A

Opcode9BHandler::
    ld h, b
    ld l, c
    ld a, [hli]
    ld e, a
    and $f0
    ld [$c6e7], a
    ld a, [hli]
    ld [$c6e8], a
    ld a, h
    ld [hScriptPtr + 1], a
    ld a, l
    ld [hScriptPtr], a
    ld a, e
    and $0f
    ld [wCallbackBank], a
    ld hl, PointedByteWords + 2
    ld a, [wUnknownC6EC]
    add a, a
    ld c, a
    xor a
    ld b, a
    add hl, bc
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, h
    ld [$c6ea], a
    ld a, l
    ld [$c6e9], a
    ld a, $1a
    ld [$ffa6], a
    ld a, $01
    ld [$c6eb], a
    ld a, LOW(Opcode9BCountdown)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode9BCountdown)
    ld [hScriptHandler + 1], a
    ret
