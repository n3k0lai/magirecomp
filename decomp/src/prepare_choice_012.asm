; Bank 3 at $5158. DispatchArmedChoice jumps here when $CCA7 is
; $00, $01, or $02.
;
; $CCD5 is cleared and $CCA7 is copied to $CCCB. The three choices
; plant a different record:
;   $00 stores $00 at $CCFD, $0C at $CCE9, $22 at $CCE8, $5DFF at
;       $CCE6, and $A3A7 at $CCE4.
;   $01 stores $03 at $CCFD, $0C at $CCE9, $22 at $CCE8, $6FF5 at
;       $CCE6, and $A5A5 at $CCE4.
;   $02 stores $02 at $CCFD, $06 at $CCE9, $13 at $CCE8, $6916 at
;       $CCE6, and $A019 at $CCE4.
; Each record stores $0D at $CCEA. $74EF then runs with C = $F0 and
; HL at the $CCE4 pointer, $7550 follows, and TurnOffLCD, $7596, and
; TurnOnLCDIfOff run. RefreshFrameWindowPair runs next.
;
; $CCE1 and $CCE2 are cleared. $CCC8 becomes $08. When [$CCCC] is
; above that, $CCE2 becomes 1 and RefreshFrameMarkPair runs. Otherwise
; $779D runs. $CCA7 is copied to $CD81, $CCE3 is cleared, and control
; leaves through StepFeChoiceByCce3.
;
; $74EF, $7550, $7596, and $779D are still INCBIN. TurnOffLCD,
; TurnOnLCDIfOff, RefreshFrameWindowPair, RefreshFrameMarkPair, and
; StepFeChoiceByCce3 are already source.

DEF CHOICE_012_00 EQU $00
DEF CHOICE_012_01 EQU $01
DEF CHOICE_012_02 EQU $02
DEF CCFD_FOR_00 EQU $00
DEF CCFD_FOR_01 EQU $03
DEF CCFD_FOR_02 EQU $02
DEF CCE9_WIDE EQU $0C
DEF CCE9_NARROW EQU $06
DEF CCE8_WIDE EQU $22
DEF CCE8_NARROW EQU $13
DEF CCEA_MARK EQU $0D
DEF PTR_5DFF EQU $5DFF
DEF PTR_6FF5 EQU $6FF5
DEF PTR_6916 EQU $6916
DEF PTR_A3A7 EQU $A3A7
DEF PTR_A5A5 EQU $A5A5
DEF PTR_A019 EQU $A019
DEF COUNT_WINDOW EQU $F0
DEF LEN_LIMIT EQU $08
DEF CCE2_LONG EQU $01

PrepareChoice012::
    xor a
    ld [$CCD5], a
    ld a, [$CCA7]
    ld [$CCCB], a
    cp CHOICE_012_00
    jr z, .choice00

    cp CHOICE_012_01
    jr z, .choice01

    ld a, CCFD_FOR_02
    ld [$CCFD], a
    ld a, CCE9_NARROW
    ld [$CCE9], a
    ld a, CCE8_NARROW
    ld [$CCE8], a
    ld hl, PTR_6916
    ld a, h
    ld [$CCE7], a
    ld a, l
    ld [$CCE6], a
    ld a, CCEA_MARK
    ld [$CCEA], a
    ld hl, PTR_A019
    jr .countRecords

.choice00
    ld a, CCFD_FOR_00
    ld [$CCFD], a
    ld a, CCE9_WIDE
    ld [$CCE9], a
    ld a, CCE8_WIDE
    ld [$CCE8], a
    ld hl, PTR_5DFF
    ld a, h
    ld [$CCE7], a
    ld a, l
    ld [$CCE6], a
    ld a, CCEA_MARK
    ld [$CCEA], a
    ld hl, PTR_A3A7
    jr .countRecords

.choice01
    ld a, CCFD_FOR_01
    ld [$CCFD], a
    ld a, CCE9_WIDE
    ld [$CCE9], a
    ld a, CCE8_WIDE
    ld [$CCE8], a
    ld hl, PTR_6FF5
    ld a, h
    ld [$CCE7], a
    ld a, l
    ld [$CCE6], a
    ld a, CCEA_MARK
    ld [$CCEA], a
    ld hl, PTR_A5A5

.countRecords
    ld a, h
    ld [$CCE5], a
    ld a, l
    ld [$CCE4], a
    ld c, COUNT_WINDOW
    call CountNonzeroChoiceBytes
    call CollectChoiceIndicesForward
    call TurnOffLCD
    call StageIndexedChoiceTiles
    call TurnOnLCDIfOff
    call RefreshFrameWindowPair
    xor a
    ld hl, $CCE1
    ld [hl+], a
    ld [hl], a
    ld a, [$CCCC]
    ld c, a
    ld a, LEN_LIMIT
    ld [$CCC8], a
    cp c
    jr nc, .withinLimit

    ld a, CCE2_LONG
    ld [hl], a
    call RefreshFrameMarkPair
    jr .enterFeStep

.withinLimit
    call RefreshFrameBlankMarkPair

.enterFeStep
    ld a, [$CCA7]
    ld [$CD81], a
    xor a
    ld [$CCE3], a
    jp StepFeChoiceByCce3

PrepareChoice012End:
