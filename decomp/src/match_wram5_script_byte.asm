; Compares the word at $C190 with the word at $FF93, then maybe one script byte.
;
; DE is the little-endian word at $C190. HL is the little-endian word at
; $FF93, the field opcode $0F copies. When those words are equal, control
; jumps to $0CD4, still INCBIN. That tail stores Opcode11 ($0C7E) in
; hScriptHandler and returns.
;
; When the words differ, WRAM bank 5 is stored in wCurrentWRAMBank and mapped
; through rSVBK. The byte at HL in that bank is compared with the next script
; byte at BC. A mismatch takes the same jump to $0CD4. A match saves BC in
; hScriptPtr with the 3-byte form, sets hScriptHandler to
; DispatchScriptOpcode, stores $4A6B at $FF8D, and returns. What $C190 and
; $4A6B are used for is still unknown. Who calls $0C9A is still unknown.
;
; hScriptPtr and hScriptHandler are the names from reset.asm. wCurrentWRAMBank
; and rSVBK are the names from timer_overflow.asm.

MatchWRAM5ScriptByte::
    ld hl, $c190
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ldh a, [$ff94]
    ld h, a
    ldh a, [$ff93]
    ld l, a
    ld a, l
    cp e
    jr nz, .bank5
    ld a, h
    cp d
    jr z, $0CD4
.bank5:
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld e, [hl]
    ld a, [bc]
    inc bc
    cp e
    jr nz, $0CD4
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ldh [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ldh [hScriptHandler + 1], a
    ld a, $6b
    ldh [$ff8d], a
    ld a, $4a
    ldh [$ff8e], a
    ret
