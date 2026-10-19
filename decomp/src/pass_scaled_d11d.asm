; Bank 2 at $5420. FinishLowD103Refresh calls here when [$D107] is
; nonzero, with B = [$D11D] and C = [$D108]. A = 1 lets that caller
; compare the word at $D100 with $517D. A = 0 skips that compare.
;
; MaskDivByC with C = $FF returns a raw rDIV sample in A. sla b; add b
; adds twice the incoming B, so the sample is rDIV + 2 * [$D11D].
;
; Bit 4 of $D125 compares that sample with $4C and drops the saved BC.
; Below $4C returns 1. At or above $4C, StoreIndexedSlotRecord runs with
; A = [$D103], D = $41, and BC = $701C. Bank 5 at $5575 builds the name
; text, $C949 is stored at $C93D, and $C71B receives the five-byte script
; record $4C $48 $44 $66 $0A. Bank 5 at $5A1A waits until that record's
; pointer high byte is clear. StoreSlotPairs0214 then writes the $02 $14
; pairs for [$D103], and the routine returns 0.
;
; Bit 4 clear compares the sample with the incoming C, which is [$D108].
; Below that byte returns 1. At or above it returns 0 with no script.
;
; MaskDivByC, StoreIndexedSlotRecord, CallBankedHL, StoreSlotPairs0214,
; WriteIndexedNamesAndCount, and WaitUntilC71DClears are already source.

PassIfScaledD11DBelowLimit::
    push bc
    ld c, $FF
    call MaskDivByC
    sla b
    add b
    ld b, a
    ld a, [$D125]
    and $10
    jr z, .compareSavedC
    pop de
    ld a, b
    cp $4C
    jr c, .returnOne
    jr .maybeRunScript

.compareSavedC:
    ld a, b
    pop bc
    cp c
    jr nc, .maybeRunScript

.returnOne:
    ld a, $01
    ret

.maybeRunScript:
    ld a, [$D125]
    and $10
    jr z, .returnZero
    ld a, [$D103]
    ld d, $41
    ld bc, $701C
    call StoreIndexedSlotRecord
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $48
    ld [hl+], a
    ld a, $44
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ld a, [$D103]
    call StoreSlotPairs0214

.returnZero:
    xor a
    ret
