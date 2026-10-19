; Bank 1 at $5E65. StageIdleScriptUnlessUpOrDown calls this before
; the bank-5 idle script.
;
; HL is the little-endian word at hMapCellPointer ($FF93). Both loads
; are the 3-byte form, high byte first. The cell byte there is tested
; from $A0 through $A7. D is the X step and E is the Y step:
;
;   $A0  D=$00 E=$FD   up 3
;   $A1  D=$02 E=$FE   up-right 2
;   $A2  D=$03 E=$00   right 3
;   $A3  D=$02 E=$02   down-right 2
;   $A4  D=$00 E=$03   down 3
;   $A5  D=$FE E=$02   down-left 2
;   $A6  D=$FD E=$00   left 3
;   $A7  D=$FE E=$FE   up-left 2
;
; Any other cell uses D=$00 E=$00. D is added into the X step at
; wClearedOnRecordLoad ($C6D2) and E into the Y step at the next byte
; ($C6D3). This returns. It does not write rROMB0 and does not call out.
;
; hMapCellPointer is the name from pick_map_cell_from_div.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; Positive Y is down.

AddCellDirectionStep::
    ld a, [hMapCellPointer + 1]
    ld h, a
    ld a, [hMapCellPointer]
    ld l, a
    ld b, $a0
    ld a, [hl]
    cp b
    jr nz, .notUp

    ld e, $fd
    ld d, $00
    jr .apply

.notUp:
    inc b
    cp b
    jr nz, .notUpRight

    ld e, $fe
    ld d, $02
    jr .apply

.notUpRight:
    inc b
    cp b
    jr nz, .notRight

    ld e, $00
    ld d, $03
    jr .apply

.notRight:
    inc b
    cp b
    jr nz, .notDownRight

    ld e, $02
    ld d, $02
    jr .apply

.notDownRight:
    inc b
    cp b
    jr nz, .notDown

    ld e, $03
    ld d, $00
    jr .apply

.notDown:
    inc b
    cp b
    jr nz, .notDownLeft

    ld e, $02
    ld d, $fe
    jr .apply

.notDownLeft:
    inc b
    cp b
    jr nz, .notLeft

    ld e, $00
    ld d, $fd
    jr .apply

.notLeft:
    inc b
    cp b
    jr nz, .zero

    ld e, $fe
    ld d, $fe
    jr .apply

.zero:
    ld e, $00
    ld d, $00

.apply:
    ld a, [wClearedOnRecordLoad]
    add d
    ld [wClearedOnRecordLoad], a
    ld a, [wClearedOnRecordLoad + 1]
    add e
    ld [wClearedOnRecordLoad + 1], a
    ret
