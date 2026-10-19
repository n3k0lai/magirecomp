; Bank 1 at $4AD5. Called from RunTwoScriptsThenTouchCell before
; WriteRecordHead. Returns at once unless bit 1 of hLatchedFFAB ($FFAB)
; is set. HL is the little-endian word at hMapCellPointer ($FF93).
; When the byte there is $00, this writes $08 and sets bit 5 of
; hRecordHead ($FF8C). The pointer loads are the 3-byte form.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; hRecordHead is the name from write_record_head.asm.
; hLatchedFFAB is defined later, in handle_start_press.asm, so this
; reads $FFAB with a literal.

MarkZeroMapCell::
    ldh a, [$FFAB]
    bit 1, a
    ret z

    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld a, [hl]
    cp $00
    ret nz

    ld a, $08
    ld [hl], a
    ldh a, [hRecordHead]
    set 5, a
    ldh [hRecordHead], a
    ret
