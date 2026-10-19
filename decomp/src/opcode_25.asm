; Script opcode $25. The bank 1 pointer table at $4303 maps opcode $25
; here. DispatchScriptOpcode jumps here with BC pointing at the operands.
; Six operand bytes are consumed.
;
; $C18E and $C18F are copied to $C9A1 and $C9A2. Their roles are still
; unknown. WRAM bank 7 is stored in wCurrentWRAMBank and selected with
; rSVBK, so the $D000 stores below land in that bank. The first operand
; is stored at $C9E4. The second is stored at $D391; $D0D3 becomes 1 when
; that byte is $6C and 0 otherwise. The third operand is stored at $D36D.
; The next three operands are copied to the bank and pointer of
; wScriptRecord, and the handler half of that record is set to
; INITIAL_SCRIPT_HANDLER ($0A66). $D0D7 is cleared.
;
; BC, now past those six bytes, is stored at hScriptPtr. hScriptHandler
; is set to $0F59, which is also where opcode $2B's code starts.
; hScriptDest is set to $C714, and CopyScriptRecord copies the seven HRAM
; script bytes there. hScriptBank and the two trailing record bytes are
; left as they were. ROM bank 4 is mapped and control jumps to $6416.
;
; Other code enters at $0ECB (the $C18F copy), $0EF7 (the first record
; store), $0EFF (the clear of $D0D7), $0F00 (the store of that clear),
; $0F03 (the handler immediate), $0F13 and $0F17 (the two handler bytes),
; and $0F1F (the destination high byte).
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wScriptRecord, hScriptDest, and CopyScriptRecord are the names from
; finish_startup.asm. hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER,
; wCurrentROMBank, and rROMB0 are the names from reset.asm.

Opcode25::
    ld a, [$C18E]
    ld [$C9A1], a
    ld a, [$C18F]
    ld [$C9A2], a
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [bc]
    inc bc
    ld [$C9E4], a
    ld a, [bc]
    inc bc
    ld [$D391], a
    cp $6c
    jr z, .flag_set
    xor a
    jr .store_flag

.flag_set:
    ld a, $01

.store_flag:
    ld [$D0D3], a
    ld a, [bc]
    inc bc
    ld [$D36D], a
    ld hl, wScriptRecord
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    xor a
    ld [$D0D7], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [wScriptRecord + 3], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [wScriptRecord + 4], a
    ld a, b
    ldh [hScriptPtr + 1], a
    ld a, c
    ldh [hScriptPtr], a
    ld a, LOW($0F59)
    ldh [hScriptHandler], a
    ld a, HIGH($0F59)
    ldh [hScriptHandler + 1], a
    ld a, LOW($C714)
    ldh [hScriptDest], a
    ld a, HIGH($C714)
    ldh [hScriptDest + 1], a
    call CopyScriptRecord
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp $6416
