; Bank 2 at $4B7D. [$D071] is set to 2. Bank $4C and pointer $4EE1
; are staged through StagePointerUnlessD0B6Matches, which compares
; [$D0B6] with [$D103] and returns on a match.
;
; SubAFloorByteAtBc subtracts $0A from the byte at $D110 + $0F ($D11F)
; and stores $01 when the result would be zero or would underflow.
;
; [$D112] is the second name id. When it is at least $58 this returns.
; Otherwise the id is stored at [$D0C7] and $0A at [$D0C8], the marked
; name id and count that PlantMarkedNameAndCount later prints.
;
; The five-byte script at $C71B is $4C $DC $45 $66 $0A: bank $4C, pointer
; $45DC, handler $0A66. Run560EThenWaitC71D runs that record and returns
; once the stored high byte at $C71D is zero.
;
; StagePointerUnlessD0B6Matches, SubAFloorByteAtBc, and
; Run560EThenWaitC71D are already source. Bank $4C at $4EE1 is file
; $0130EE1. Bank $4C at $45DC is file $01305DC. Both are still INCBIN.

SetD071TwoStage4EE1FloorD11FScript45DC::
    ld a, $02
    ld [$D071], a
    ld a, $4C
    ld bc, $4EE1
    call StagePointerUnlessD0B6Matches
    ld hl, $D110
    ld bc, $000F
    ld a, $0A
    call SubAFloorByteAtBc
    ld a, [$D112]
    cp $58
    ret nc
    ld [$D0C7], a
    ld a, $0A
    ld [$D0C8], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $DC
    ld [hl+], a
    ld a, $45
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call Run560EThenWaitC71D
    ret

SetD071TwoStage4EE1FloorD11FScript45DCEnd:
