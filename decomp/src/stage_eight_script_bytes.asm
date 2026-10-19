; Script step at $1E9F. BC is the script pointer. hScriptHandler is
; planted as $44A6 with the 3-byte form, then control falls into the
; shared copy below. $1EDA, still INCBIN, plants $4552 and jumps to
; that copy, so the handler is chosen by the entry, not by the copy.
;
; The next eight script bytes are staged and BC moves past them:
;   two bytes, little-endian, at $C6FE
;   one byte written to both $FFA6 and $FFA7
;   one byte at $C704
;   four bytes at $C700
; BC, now past those eight bytes, is stored at hScriptPtr (high byte
; first, 3-byte form). Bit 7 of hScriptBank is set, which forces the
; planted handler to run from bank 1, and this returns.
;
; $44A6 is the file address of the bank 1 entry this step plants. It is
; still INCBIN. $C6FE, $C700, $C704, $FFA6, and $FFA7 have no names yet.
; hScriptBank, hScriptPtr, and hScriptHandler are the names from
; reset.asm. This step does not call or jump into an INCBIN.

DEF Bank1Handler44A6 EQU $44A6

StageEightScriptBytes::
    ld a, LOW(Bank1Handler44A6)
    ld [hScriptHandler], a
    ld a, HIGH(Bank1Handler44A6)
    ld [hScriptHandler + 1], a

StageEightScriptBytesCopy::
    ld hl, $c6fe
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    inc bc
    ldh [$ffa6], a
    ldh [$ffa7], a
    ld a, [bc]
    inc bc
    ld [$c704], a
    ld hl, $c700
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld hl, hScriptBank
    set 7, [hl]
    ret
