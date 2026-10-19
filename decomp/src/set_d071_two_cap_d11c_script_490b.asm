; Bank 2 at $4802. [$D071] is set to 2. AddACapByteAtBc adds $14 to
; the byte at $D110 + $0C ($D11C) and caps that byte at $63.
;
; [$D112] is the second name id. When it is at least $58 this returns.
; Otherwise the id is stored at [$D0C7] and $14 at [$D0C8], the marked
; name id and count that PlantMarkedNameAndCount later prints.
;
; The five-byte script at $C71B is $4C $0B $49 $66 $0A: bank $4C, pointer
; $490B, handler $0A66. Run560EThenWaitC71D runs that record and returns
; once the stored high byte at $C71D is zero.
;
; AddACapByteAtBc and Run560EThenWaitC71D are already source. Bank $4C
; at $490B is still INCBIN. Its file address is $13090B.

SetD071TwoCapD11CThenScript490B::
    ld a, $02
    ld [$D071], a
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $14
    call AddACapByteAtBc
    ld a, [$D112]
    cp $58
    ret nc
    ld [$D0C7], a
    ld a, $14
    ld [$D0C8], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $0B
    ld [hl+], a
    ld a, $49
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call Run560EThenWaitC71D
    ret
