; Bank 2 at $4FE5. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $5320. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; SubAFloorByteAtBc subtracts $14 from the byte at $D110 + $0D ($D11D)
; and stores $01 when the result would be zero or would underflow.
;
; [$D112] is the second name id. When it is at least $58 this returns.
; Otherwise the id is stored at [$D0C7] and $14 at [$D0C8], the marked
; name id and count that PlantMarkedNameAndCount later prints.
;
; The five-byte script at $C71B is $4C $0D $46 $66 $0A: bank $4C, pointer
; $460D, handler $0A66. Run560EThenWaitC71D runs that record and returns
; once the stored high byte at $C71D is zero.
;
; AddDividerStep then adds a divider-derived step to [$FFA9] and returns
; the new byte in A. A value of $80 or more returns here. Below that,
; TrySetBitPairAtPlus14 tests the two bytes at $D110 + $14 ($D124 and
; $D125) against mask $40. If either already has that bit, A is 0 and
; this returns. Otherwise the mask is stored in the second byte.
;
; A is then $40 for StageNameTextAndScript41C1, which builds the name
; text and plants the $4C $C1 $41 $66 $0A script at $C71B.
;
; StagePointerUnlessD0B6Matches, SubAFloorByteAtBc, Run560EThenWaitC71D,
; AddDividerStep, TrySetBitPairAtPlus14, StageNameTextAndScript41C1,
; and SpeedIsDownScript460D are already source. Bank $4C at $5320 is
; file $0131320 and is still INCBIN, already listed from the plant at
; $48ED. Bank $4C at $460D is file $013060D, already listed from there.

Stage5320FloorD11DScript460DBit40::
    ret z
    ld a, $4C
    ld bc, $5320
    call StagePointerUnlessD0B6Matches
    ld hl, $D110
    ld bc, $000D
    ld a, $14
    call SubAFloorByteAtBc
    ld a, [$D112]
    cp $58
    ret nc
    ld [$D0C7], a
    ld a, $14
    ld [$D0C8], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $0D
    ld [hl+], a
    ld a, $46
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call Run560EThenWaitC71D
    call AddDividerStep
    cp $80
    ret nc
    ld a, $40
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $40
    call StageNameTextAndScript41C1
    ret
