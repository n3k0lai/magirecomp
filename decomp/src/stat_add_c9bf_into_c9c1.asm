; STAT handler at $3796.
;
; LCDStat pushes AF and HL, then jumps through hSTATHandler.
; StatAddC9BEIntoC9C0 plants this address after adding $C9BE into $C9C0.
; This adds $C9BF into $C9C1 and copies the sum to rSCX. rSCY is set to
; $B8. HL and AF are popped and the interrupt returns. hSTATHandler is
; left alone, so the next STAT runs this handler again.
;
; rSCX and rSCY are the names from lcd_off_setup.asm. hSTATHandler is the
; name from lcd_stat.asm. CopyEntryRecordField writes $C9BF.
; ScaleEByDIntoC9C0 writes $C9C1 when A is not zero. This routine does
; not call out and does not write rROMB0.

; Fixed background Y scroll for this handler.
DEF STAT_SCY_ADD_C9BF EQU $B8

StatAddC9BFIntoC9C1::
    ld a, [$C9BF]
    ld e, a
    ld a, [$C9C1]
    add e
    ld [$C9C1], a
    ldh [rSCX], a
    ld a, STAT_SCY_ADD_C9BF
    ldh [rSCY], a
    pop hl
    pop af
    reti
