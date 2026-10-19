; Bank 3 at $4F83. StageTilesArmSlot jumps here after it stores $FF in
; $CCA7, turns the LCD on, and refreshes one frame.
;
; Each pass sets $CCA7 to $FF, calls RefreshChoiceCursor in this bank,
; and runs RefreshFrame. While $CCA7 stays $FF the loop repeats.
;
; $FE jumps to $5238. $0B jumps to $4FBE. $0C jumps to $503E. $00, $01,
; and $02 jump to $5158. Any other value calls $521A, which copies a
; byte from the $CCCD table into $CCFC (or stores $FF at $CCFC and
; $CCFD when the value is $0D), then jumps to $7637.
;
; CallBankedHL, RefreshChoiceCursor, and RefreshFrame are already source.
; $4FBE, $503E, $5158, $521A, $5238, and $7637 are still INCBIN.

DEF Bank3_7637 EQU $7637
DEF CHOICE_STILL_WAITING EQU $FF
DEF CHOICE_FE EQU $FE
DEF CHOICE_0B EQU $0B
DEF CHOICE_0C EQU $0C
DEF CHOICE_00 EQU $00
DEF CHOICE_01 EQU $01
DEF CHOICE_02 EQU $02
DEF BANK3_CHOICE EQU $03

DispatchArmedChoice::
.wait
    ld a, CHOICE_STILL_WAITING
    ld [$cca7], a
    ld hl, RefreshChoiceCursor
    ld e, BANK3_CHOICE
    call CallBankedHL
    call RefreshFrame
    ld a, [$cca7]
    cp CHOICE_STILL_WAITING
    jr z, .wait

    cp CHOICE_FE
    jp z, StepFeChoiceByCce3

    cp CHOICE_0B
    jp z, StepChoice0BByCcc8

    cp CHOICE_0C
    jp z, StepChoice0CByCcc8

    cp CHOICE_01
    jp z, PrepareChoice012

    cp CHOICE_00
    jp z, PrepareChoice012

    cp CHOICE_02
    jp z, PrepareChoice012

    call CopyOtherChoiceByte
    jp Bank3_7637
