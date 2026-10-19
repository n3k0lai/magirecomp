; Bank 1 at $65A4, the first byte after ReloadRecordHead.
; rROMB0 is left alone except inside RunTwoScriptsFromRecord.
;
; RunTwoScriptsFromRecord copies the ten-byte head at BC and runs the
; two script records that follow. This returns while the third script
; pointer high byte (wThirdScriptRecord + 2) is nonzero, and again when
; wUnknownC6EE is not zero. That compare is the two-byte `cp $00`.
; Bit 1 of hLatchedFFAB must be set. What that bit marks is still
; unknown. hObjectCellX must equal wScriptBaseLo and hObjectCellY must
; equal wScriptBaseHi.
;
; The record pointer at $FF8A/$FF8B is read with the 3-byte form. HL
; steps past the first record byte, and the next two bytes become the
; little-endian address RunTailScriptThenPlantTwoScripts ($64D1).
;
; RunTwoScriptsFromRecord and RunTailScriptThenPlantTwoScripts are
; already source. wThirdScriptRecord is the name from
; setup_command_4d.asm. wUnknownC6EE is the name from setup_window.asm.
; hLatchedFFAB is the name from handle_start_press.asm. hObjectCellX and
; hObjectCellY are the names from queue_sprite_list.asm. wScriptBaseLo
; and wScriptBaseHi are the names from opcode_02.asm. hRecordPointer is
; the name from copy_record_to_scratch.asm.

PlantTailScriptHeadWhenCellMatches::
    call RunTwoScriptsFromRecord
    ld a, [wThirdScriptRecord + 2]
    and a
    ret nz
    ld a, [wUnknownC6EE]
    cp $00
    ret nz
    ldh a, [hLatchedFFAB]
    bit 1, a
    ret z
    ldh a, [hObjectCellX]
    ld e, a
    ld a, [wScriptBaseLo]
    cp e
    ret nz
    ldh a, [hObjectCellY]
    ld e, a
    ld a, [wScriptBaseHi]
    cp e
    ret nz
    ld a, [$ff8b]
    ld h, a
    ld a, [$ff8a]
    ld l, a
    inc hl
    ld a, LOW(RunTailScriptThenPlantTwoScripts)
    ld [hl+], a
    ld a, HIGH(RunTailScriptThenPlantTwoScripts)
    ld [hl+], a
    ret
