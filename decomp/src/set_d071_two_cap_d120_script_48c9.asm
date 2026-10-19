; Bank 2 at $4A4A. [$D071] is set to 2. AddACapByteAtBc adds $32 to
; the byte at $D110 + $10 ($D120) and caps that byte at $63.
;
; [$D112] is the second name id. When it is at least $58 this returns.
; Otherwise the id is stored at [$D0C7] and $32 at [$D0C8], the marked
; name id and count that PlantMarkedNameAndCount later prints.
;
; The five-byte script at $C71B is $4C $C9 $48 $66 $0A: bank $4C, pointer
; $48C9, handler $0A66. Run560EThenWaitC71D runs that record and returns
; once the stored high byte at $C71D is zero.
;
; AddACapByteAtBc and Run560EThenWaitC71D are already source. Bank $4C
; at $48C9 is still INCBIN. Its file address is $01308C9.

SetD071TwoCapD120ThenScript48C9::
    ld a, $02
    ld [$D071], a
    ld hl, $D110
    ld bc, $0010
    ld e, $63
    ld a, $32
    call AddACapByteAtBc
    ld a, [$D112]
    cp $58
    ret nc
    ld [$D0C7], a
    ld a, $32
    ld [$D0C8], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $C9
    ld [hl+], a
    ld a, $48
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call Run560EThenWaitC71D
    ret
