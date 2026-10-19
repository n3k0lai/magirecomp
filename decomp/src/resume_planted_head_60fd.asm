; Bank 1 at $60FD. PlantHeadWord60FD writes this address as the
; record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs the script already in the record
; and points HL at the map cell. A then becomes the $c9a3 copy of
; wButtonsHeld that FinishFrame writes. Bit 4 is right, bit 5 is left,
; bit 6 is up, and bit 7 is down.
;
; Right jumps to $6027. Left jumps to $5FC4. Up jumps to $608A. Down
; jumps to PlantDownRecordHead5F85. Those three planters are still
; INCBIN.
;
; No direction calls NudgeCameraPastFollowEdge, then reads the low two
; bits of hRecordHead. Those bits are the facing value the plant
; routines store: $00 up, $01 left, $02 right, and $03 down. Each value
; jumps to a still-INCBIN tail: $60DE, $601E, $6081, and $5FBB. A value
; outside 0–3 cannot occur after `and $03`; that path falls into the
; up jump.
;
; wButtonsHeld and the direction bits are the names from
; read_joypad.asm. $c9a3 has no name. hRecordHead is the name from
; write_record_head.asm. PlantHeadWord60FD is the label in
; plant_head_word_60fd.asm. PlantDownRecordHead5F85 is the label in
; plant_down_record_head_5f85.asm.

ResumePlantedHead60FD::
    call ReloadRecordRunScriptPointCell
    ld a, [$c9a3]
    bit 4, a
    jp nz, $6027
    bit 5, a
    jp nz, $5fc4
    bit 6, a
    jp nz, $608a
    bit 7, a
    jp nz, PlantDownRecordHead5F85
    call NudgeCameraPastFollowEdge
    ldh a, [hRecordHead]
    and $03
    cp $00
    jr z, .facingUp
    cp $03
    jr z, .facingDown
    cp $01
    jr z, .facingLeft
    cp $02
    jr z, .facingRight
.facingUp
    jp $60de
.facingDown
    jp $5fbb
.facingLeft
    jp $601e
.facingRight
    jp $6081

ResumePlantedHead60FDEnd:
