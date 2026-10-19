; Bank 2 at $48A5. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4DC6 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; AddDividerStep updates [$FFA9] and returns that byte. This returns
; when that byte is at least $C0.
;
; SubAFloorByteAtBc subtracts $14 from the byte at $D110 + $0C ($D11C)
; and stores $01 when the result would be zero or would underflow.
;
; [$D112] is the second name id. When it is at least $58 this returns.
; Otherwise the id is stored at [$D0C7] and $14 at [$D0C8], the marked
; name id and count that PlantMarkedNameAndCount later prints.
;
; The five-byte script at $C71B is $4C $F5 $45 $66 $0A: bank $4C, pointer
; $45F5, handler $0A66. Run560EThenWaitC71D runs that record and returns
; once the stored high byte at $C71D is zero.
;
; StagePointerUnlessD0B6Matches, AddDividerStep, SubAFloorByteAtBc, and
; Run560EThenWaitC71D are already source. Bank $4C at $4DC6 is file
; $0130DC6. Bank $4C at $45F5 is file $01305F5. Both are still INCBIN.

Stage4DC6FloorD11CScript45F5At48A5::
    ret z
    ld a, $4C
    ld bc, $4DC6
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $C0
    ret nc
    ld hl, $D110
    ld bc, $000C
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
    ld a, $F5
    ld [hl+], a
    ld a, $45
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call Run560EThenWaitC71D
    ret
