; Bank 0 at $3759. $3758, the E = 0 byte of LookupEntryEByte's table,
; stays in the preceding INCBIN. These bytes run through the first
; reti, at $3795.
;
; $3759-$3767 are E = 1..15. LookupEntryEByte returns the byte in C.
; The caller adds ($10 - E - C) to the map address. $3768 is the unused
; byte between that table and the D table.
;
; $3769-$3775 are D = 0..$0C. LookupEntryDByte returns the byte in C
; unless D is $0A, in which case it returns 0 without reading. The
; caller adds BC to the map address. Whether a caller passes $0B or
; $0C is still unknown. The D = $0A slot is present and unread.
;
; $3776 is a STAT handler. LCDStat pushes AF and HL, then jumps through
; hSTATHandler. This adds $C9BE into $C9C0 and copies the sum to rSCX.
; rSCY is set to $B8 and rLYC to $68. The next handler, $3796, is stored
; little-endian at hSTATHandler. That body is still INCBIN. It is the
; twin that adds $C9BF into $C9C1. HL and AF are popped and the interrupt
; returns. This routine does not call out and does not write rROMB0.
;
; rSCX and rSCY are the names from lcd_off_setup.asm. rLYC is the name
; from copy_window_position.asm. hSTATHandler is the name from
; lcd_stat.asm. CopyEntryRecordField writes $C9BE. ScaleEByDIntoC9C0
; writes $C9C0 when A is zero.

; Fixed background Y scroll for this handler.
DEF STAT_SCY_B8 EQU $B8

; Line compare value stored in rLYC.
DEF STAT_LYC_LINE_68 EQU $68

; Next STAT handler. Still INCBIN.
DEF NEXT_STAT_ADD_C9BF EQU $3796

EntryEByteTableTail::
    INCBIN "roms/magination.gbc", $3759, $10

EntryDByteTable::
    INCBIN "roms/magination.gbc", $3769, $D

StatAddC9BEIntoC9C0::
    ld a, [$C9BE]
    ld e, a
    ld a, [$C9C0]
    add e
    ld [$C9C0], a
    ldh [rSCX], a
    ld a, STAT_SCY_B8
    ldh [rSCY], a
    ld a, STAT_LYC_LINE_68
    ldh [rLYC], a
    ld a, LOW(NEXT_STAT_ADD_C9BF)
    ldh [hSTATHandler], a
    ld a, HIGH(NEXT_STAT_ADD_C9BF)
    ldh [hSTATHandler + 1], a
    pop hl
    pop af
    reti

StatAddC9BEIntoC9C0End:
