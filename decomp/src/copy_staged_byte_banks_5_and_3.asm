; Bank 1 handler planted by StageEightScriptBytes at hScriptHandler.
;
; The word at $C6FE is a source pointer in DE. The word at $C700 is a
; destination in HL. That one source byte is stored at HL while WRAM
; bank 5 is selected, then stored there again while bank 3 is selected.
; $C937 mirrors rSVBK.
;
; HL and DE are saved. wLCDC is only tested for zero. A dark screen skips
; the edge test and continues at $44E1, still INCBIN. Otherwise the word
; at $C702 is the map position Opcode03Continue expects (column in D, row
; in E). A nonzero return means the cell is on an edge that is still
; reloading, so the saved pointers are discarded and this returns. A zero
; return also continues at $44E1.
;
; wLCDC is the name from turn_off_lcd.asm. wCurrentWRAMBank and rSVBK are
; the names from timer_overflow.asm. Opcode03Continue is the name from
; opcode_03.asm. StageEightScriptBytes is the name from
; stage_eight_script_bytes.asm. $C6FE, $C700, and $C702 have no names yet.

CopyStagedByteIntoBanks5And3::
    ld a, [$c6ff]
    ld d, a
    ld a, [$c6fe]
    ld e, a
    ld a, [$c701]
    ld h, a
    ld a, [$c700]
    ld l, a
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [de]
    ld [hl], a
    ld a, $03
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [de]
    ld [hl], a

StagedByteEdgeCheck::
    push hl
    push de
    ld a, [wLCDC]
    and a
    jr z, AdvanceStagedCopy

    ld a, [$c703]
    ld d, a
    ld a, [$c702]
    ld e, a
    call Opcode03Continue
    and a
    jr z, AdvanceStagedCopy

    pop bc
    pop bc
    ret
