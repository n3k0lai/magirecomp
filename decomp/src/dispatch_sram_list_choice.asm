; Bank 3 at $6DA1. StageSramListArmSlot jumps here after the SRAM list
; slot is armed.
;
; Each pass stores $FF in $CCA7, calls RefreshChoiceCursor in this bank,
; and runs RefreshFrame. While $CCA7 stays $FF, the pass repeats when
; $CCC9 still equals the slot index in $CD81. When those two differ,
; control leaves through $6F39.
;
; $FE jumps to ReloadChoiceFrame. $0B jumps to $6DDC. $0C jumps to
; $6E56. Any other value stores $FF in $CCC9 and jumps to $729A.
;
; CallBankedHL, RefreshChoiceCursor, RefreshFrame, and ReloadChoiceFrame
; are already source. $6DDC, $6E56, $6F39, and $729A are still INCBIN.
; CHOICE_STILL_WAITING, CHOICE_FE, CHOICE_0B, CHOICE_0C, and
; BANK3_CHOICE are the names from dispatch_armed_choice.asm.

DispatchSramListChoice::
    ld a, CHOICE_STILL_WAITING
    ld [$CCA7], a
    ld hl, RefreshChoiceCursor
    ld e, BANK3_CHOICE
    call CallBankedHL
    call RefreshFrame
    ld a, [$CCA7]
    cp CHOICE_STILL_WAITING
    jr z, .stillWaiting

    cp CHOICE_FE
    jp z, ReloadChoiceFrame

    cp CHOICE_0B
    jp z, StepSramListChoice0B

    cp CHOICE_0C
    jp z, StepSramListChoice0C

    ld a, CHOICE_STILL_WAITING
    ld [$CCC9], a
    jp SpendSramListChoice

.stillWaiting:
    ld a, [$CD81]
    ld c, a
    ld a, [$CCC9]
    cp c
    jr z, DispatchSramListChoice

    jp SyncSramListSlotDigits
