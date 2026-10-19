; Bank 3 at $52BC. StageCopiedBlockArmSlot jumps here after it arms the
; choice block with $CD81 = 3 and stores $FF in $CCA7.
;
; Each pass sets $CCA7 to $FF, calls RefreshChoiceCursor in this bank,
; and runs RefreshFrame. While $CCA7 stays $FF the loop repeats.
;
; $FE and $0D jump to $7637. $0B jumps to $52ED. $0C jumps to $536D.
; Any other value calls $55E3, then the loop starts again.
;
; CallBankedHL, RefreshChoiceCursor, and RefreshFrame are already source.
; $52ED, $536D, $55E3, and $7637 are still INCBIN. CHOICE_STILL_WAITING,
; CHOICE_FE, CHOICE_0B, CHOICE_0C, BANK3_CHOICE, and Bank3_7637 are the
; names from dispatch_armed_choice.asm.

DEF CHOICE_0D EQU $0D

DispatchCopiedBlockChoice::
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
    jp z, Bank3_7637

    cp CHOICE_0B
    jp z, StepCopiedBlockChoice0B

    cp CHOICE_0C
    jp z, StepCopiedBlockChoice0C

    cp CHOICE_0D
    jp z, Bank3_7637

    call CommitCopiedBlockChoice
    jp DispatchCopiedBlockChoice
