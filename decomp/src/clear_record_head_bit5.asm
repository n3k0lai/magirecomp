; Bank 1 at $4AB6. WRAM bank 5 is stored at wCurrentWRAMBank and
; selected with rSVBK. Bit 5 of hRecordHead ($FF8C) is tested. When
; that bit is set, $00 is written through the little-endian word at
; hMapCellPointer ($FF93). The bit is then cleared in hRecordHead.
; The early skip is a conditional jump. wCurrentWRAMBank and rSVBK
; are the names from timer_overflow.asm. hRecordHead is the name from
; write_record_head.asm. hMapCellPointer is the name from
; pick_map_cell_from_div.asm.

ClearRecordHeadBit5::
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ldh a, [hRecordHead]
    ld e, a
    bit 5, e
    jr z, .clearBit
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld a, $00
    ld [hl], a

.clearBit
    ld a, e
    res 5, a
    ldh [hRecordHead], a
    ret
