; Bank 3 at $521A. DispatchArmedChoice calls this for any $CCA7
; value other than $FF, $FE, $0B, $0C, $00, $01, and $02, then jumps
; to $7637.
;
; $0D stores $FF at $CCFC and $CCFD. Any other value subtracts $03 and
; uses that as an index into the $CCCD choice table. The byte at that
; index is stored at $CCFC. Both paths return.
;
; CHOICE_BYTES is the name from fill_choice_table_from_records.asm.

DEF CHOICE_OTHER_BLANK EQU $0D
DEF CHOICE_TABLE_BASE EQU $03
DEF CHOICE_PAIR_BLANK EQU $FF

CopyOtherChoiceByte::
    ld a, [$CCA7]
    cp CHOICE_OTHER_BLANK
    jr z, .blankPair

    sub CHOICE_TABLE_BASE
    ld c, a
    ld b, $00
    ld hl, CHOICE_BYTES
    add hl, bc
    ld a, [hl]
    ld [$CCFC], a
    ret

.blankPair
    ld a, CHOICE_PAIR_BLANK
    ld [$CCFC], a
    ld [$CCFD], a
    ret

CopyOtherChoiceByteEnd:
