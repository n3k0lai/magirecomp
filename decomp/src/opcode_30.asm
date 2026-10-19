; Script opcode $30. The bank 1 pointer table at $4303 maps opcode $30
; (table index $10, opcodes counted from $20) here. Dispatch leaves BC at
; the operands. This opcode takes three of them.
;
; The first two operands are stored at $C840 and $C841. What those bytes
; are used for is still unknown. The current wSoundIndex is saved at
; $C923 before the third operand is read. $FF leaves that index alone.
; Any other value is compared with wSoundIndex. DE is preserved around
; the compare. The `ld a, a` leaves the operand in A so it can be copied
; to E. When the index differs, the operand is stored as the new index
; and wSoundActive is set to 1. Either way, wSoundSelect is cleared and
; $C92C is set to $0F.
;
; Both paths then pop BC into hScriptPtr, set hScriptHandler to
; INITIAL_SCRIPT_HANDLER ($0A66), and map ROM bank 7 through
; wCurrentROMBank and rROMB0. Control jumps to $584A in that bank
; (file address $1D84A). The pointer and handler stores are ldh.
;
; wSoundIndex, wSoundActive, and wSoundSelect are the names from
; select_sound_command.asm. wUnknownC923 is the name from
; dispatch_nonzero_d016.asm. wUnknownC92C is the name from
; handle_start_press.asm. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names
; from reset.asm. $584A is still INCBIN.

; ROM bank mapped before the jump to $584A.
DEF OPCODE30_ROM_BANK EQU $07

Opcode30::
    ld a, [bc]
    ld [$C840], a
    inc bc
    ld a, [bc]
    ld [$C841], a
    inc bc
    ld a, [wSoundIndex]
    ld [wUnknownC923], a
    ld a, [bc]
    inc bc
    push bc
    cp $FF
    jr z, .keepIndex

    push de
    ld a, a
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .indexUnchanged

    ld a, e
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a

.indexUnchanged:
    xor a
    ld [wSoundSelect], a
    ld a, $0F
    ld [wUnknownC92C], a
    pop de

.keepIndex:
    pop bc
    ld a, b
    ldh [hScriptPtr + 1], a
    ld a, c
    ldh [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, OPCODE30_ROM_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp $584A
