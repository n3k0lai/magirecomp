; Bank 2 at $4A94. [$D071] is set to 2. SubAFloorByteAtBc subtracts
; $14 from the byte at $D110 + $0D ($D11D) and stores $01 when the
; result would be zero or would underflow.
;
; [$D112] is the second name id. When it is at least $58 this returns.
; Otherwise the id is stored at [$D0C7] and $14 at [$D0C8], the marked
; name id and count that PlantMarkedNameAndCount later prints.
;
; The five-byte script at $C71B is $4C $0D $46 $66 $0A: bank $4C, pointer
; $460D, handler $0A66. Run560EThenWaitC71D runs that record and returns
; once the stored high byte at $C71D is zero.
;
; SubAFloorByteAtBc and Run560EThenWaitC71D are already source. Bank $4C
; at $460D is still INCBIN. Its file address is $013060D, already listed
; from the plant at $48ED.

SetD071TwoFloorD11DScript460D::
    ld a, $02
    ld [$D071], a
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
    ret
