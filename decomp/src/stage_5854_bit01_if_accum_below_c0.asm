; Bank 2 at $4E86. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5854 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; AddDividerStep adds a divider-derived step to [$FFA9] and returns the
; new byte in A. A value of $C0 or more returns here. Below that,
; TrySetBitPairAtPlus14 tests the two bytes at $D110 + $14 ($D124 and
; $D125) against mask $01. If either already has that bit, A is 0 and
; this returns. Otherwise the mask is stored in the second byte.
;
; A is then $01 for StageNameTextAndScript41C1, which builds the name
; text and plants the $4C $C1 $41 $66 $0A script at $C71B.
;
; StagePointerUnlessD0B6Matches, AddDividerStep, TrySetBitPairAtPlus14,
; and StageNameTextAndScript41C1 are already source. hDividerAccum is
; the name from add_divider_step.asm. Bank $4C at $5854 is file
; $0131854, already listed from the $4B27 planter.

Stage5854Bit01IfAccumBelowC0::
    ret z
    ld a, $4C
    ld bc, $5854
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $C0
    ret nc
    ld a, $01
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $01
    call StageNameTextAndScript41C1
    ret
