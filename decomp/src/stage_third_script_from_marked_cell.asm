; Bank 1 at $422E, the first byte after StepCell82OnEvenPass.
;
; wThirdScriptRecord + 2 is the pointer high byte. Nonzero means that
; record is still running, so this returns. WRAM bank 5 is stored at
; wCurrentWRAMBank and selected with rSVBK.
;
; C is [$C6D0] + [$C6D2] and B is [$C6D1] + [$C6D3]. Both zero returns.
; E is the exclusive index limit at $C6E1. HL is the little-endian word
; at hMapCellPointer, and D is the cell byte there. Unless the top two
; bits are both set, $FF is stored at $C6DE and this returns. The low
; six bits are an index. An index at or past E returns, and so does an
; index already stored at $C6DE.
;
; Otherwise HL is the little-endian word at $C6DF plus four times that
; index. ReadBank21Byte returns the first byte of that bank-$21 record.
; $01 stages only when B is negative, $02 only when B is positive, $03
; only when C is positive, and $04 only when C is negative. Zero for
; the chosen sum returns. Any other first byte stages. Staging stores
; the index at $C6DE, copies the next three bytes into the bank and
; pointer of wThirdScriptRecord, and points its handler at
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wThirdScriptRecord is the name from setup_command_4d.asm.
; ReadBank21Byte and ReadBank21ScriptHead are the routines at $0A09
; and $0A1D. INITIAL_SCRIPT_HANDLER is the name from reset.asm.
; $C6D0, $C6DE, $C6DF, and $C6E1 still have no names.

StageThirdScriptFromMarkedCell::
    ld a, [wThirdScriptRecord + 2]
    and a
    ret nz
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$c6d2]
    ld c, a
    ld a, [$c6d0]
    add c
    ld c, a
    ld a, [$c6d3]
    ld b, a
    ld a, [$c6d1]
    add b
    ld b, a
    or c
    ret z
    ld a, [$c6e1]
    ld e, a
    ld hl, hMapCellPointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, [hl]
    ld a, d
    and $c0
    cp $c0
    jr nz, .clear_index
    ld a, d
    and $3f
    ld d, a
    cp e
    ret nc
    ld a, [$c6de]
    cp d
    ret z
    ld a, [$c6e0]
    ld h, a
    ld a, [$c6df]
    ld l, a
    ld a, d
    add a
    add a
    add l
    ld l, a
    ld a, $00
    adc h
    ld h, a
    call ReadBank21Byte
    cp $01
    jr z, .sum_b_when_negative
    cp $02
    jr z, .sum_b_when_positive
    cp $03
    jr z, .sum_c_when_positive
    cp $04
    jr z, .sum_c_when_negative
    jr .stage

.sum_b_when_negative:
    ld a, b
    jr .keep_if_negative

.sum_b_when_positive:
    ld a, b
    jr .keep_if_positive

.sum_c_when_positive:
    ld a, c
    jr .keep_if_positive

.sum_c_when_negative:
    ld a, c
    jr .keep_if_negative

.keep_if_positive:
    and a
    ret z
    bit 7, a
    jr z, .stage
    ret

.keep_if_negative:
    and a
    ret z
    bit 7, a
    jr nz, .stage
    ret

.stage:
    ld a, d
    ld [$c6de], a
    call ReadBank21ScriptHead
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [wThirdScriptRecord + 3], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [wThirdScriptRecord + 4], a
    ret

.clear_index:
    ld a, $ff
    ld [$c6de], a
    ret
