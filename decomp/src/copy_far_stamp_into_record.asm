; Bank 1 at $5ED2, the first byte after AddCellDirectionStep.
;
; RunTwoScriptsFromRecord loads the record at hRecordPointer, runs its
; two script records, and writes the head back. Bit 3 of hLatchedFFAB
; ($FFAB) is the latch FinishFrame copies from $FFAA. StampTwoStepCells
; sets that bit after it saves the near-cell address at $C9A7 and the
; far position and address at $C9A9. Those four WRAM bytes have no names
; yet.
;
; When the bit is clear, or when hMapCellPointer is not that near cell,
; this returns. Otherwise it copies those four far-stamp bytes onto the
; record at offset 5, which is the sixth head byte. It does not write
; rROMB0. The only call is RunTwoScriptsFromRecord, already source.
;
; hRecordPointer is the name from copy_record_to_scratch.asm.
; hLatchedFFAB is the name from handle_start_press.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; RunTwoScriptsFromRecord is the name from run_two_scripts_from_record.asm.

CopyFarStampIntoRecord::
    call RunTwoScriptsFromRecord
    ldh a, [hLatchedFFAB]
    bit 3, a
    ret z

    ldh a, [hMapCellPointer + 1]
    ld d, a
    ldh a, [hMapCellPointer]
    ld e, a
    ld a, [$c9a7]
    cp e
    ret nz

    ld a, [$c9a8]
    cp d
    ret nz

    ldh a, [hRecordPointer + 1]
    ld h, a
    ldh a, [hRecordPointer]
    ld l, a
    ld bc, $0005
    add hl, bc
    ld bc, $c9a9
    ld a, [bc]
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    inc bc
    ret
