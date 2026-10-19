; Bank 1 at $41D8, the first byte after StageThirdScriptFromC6DB.
;
; HL is the little-endian word at hMapCellPointer ($FF93). WRAM bank 5 is
; stored at wCurrentWRAMBank and selected with rSVBK, then the byte at HL
; must be $82. The pointer high byte of wThirdScriptRecord must be zero.
; Otherwise this returns. Both early returns are conditional.
;
; $C6D7 is the byte opcode $32 sets to $FF. Zero jumps to $41AB, the last
; byte of Unknown_418D's `jp $FAE1`, so the next opcode is `ld a, [$C716]`.
; $FF calls AddDividerStep, keeps the low nibble, and replaces $C6D7 with
; the byte at that offset from the little-endian word at $C6D9. Any other
; value is decremented and stored back.
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wThirdScriptRecord is the name from setup_command_4d.asm.
; AddDividerStep is the name from add_divider_step.asm. $C6D7 and $C6D9
; still have no names. What reads the jump into $41AB is still unknown.

AdvanceCell82Countdown::
    ldh a, [hMapCellPointer + 1]
    ld h, a
    ldh a, [hMapCellPointer]
    ld l, a
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl]
    cp $82
    ret nz
    ld a, [wThirdScriptRecord + 2]
    and a
    ret nz
    ld a, [$c6d7]
    and a
    jp z, $41ab
    cp $ff
    jr z, .reload
    dec a
    ld [$c6d7], a
    ret

.reload
    ld hl, $c6d9
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call AddDividerStep
    and $0f
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [$c6d7], a
    ret

AdvanceCell82CountdownEnd:
