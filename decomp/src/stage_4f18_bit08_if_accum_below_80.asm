; Bank 2 at $4B01. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4F18 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; AddDividerStep adds a divider-derived step to [$FFA9] and returns the
; new byte in A. A value of $80 or more returns here. Below that,
; TrySetBitPairAtPlus14 tests the two bytes at $D110 + $14 ($D124 and
; $D125) against mask $08. If either already has that bit, A is 0 and
; this returns. Otherwise the mask is stored in the second byte.
;
; $30 is then ORed into [$D0DA]. A is $08 for
; StageNameTextAndScript41C1, which builds the name text and plants the
; $4C $C1 $41 $66 $0A script at $C71B.
;
; StagePointerUnlessD0B6Matches, AddDividerStep, TrySetBitPairAtPlus14,
; and StageNameTextAndScript41C1 are already source. hDividerAccum is
; the name from add_divider_step.asm. Bank $4C at $4F18 is file
; $0130F18 and is still INCBIN.

Stage4F18Bit08IfAccumBelow80::
    ret z
    ld a, $4C
    ld bc, $4F18
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $80
    ret nc
    ld a, $08
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $30
    ld hl, $D0DA
    or [hl]
    ld [hl], a
    ld a, $08
    call StageNameTextAndScript41C1
    ret

Stage4F18Bit08IfAccumBelow80End:
