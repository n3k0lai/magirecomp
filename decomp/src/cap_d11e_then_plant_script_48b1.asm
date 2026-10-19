; Bank 2 at $4C0A. [$D071] is set to 2. AddACapByteAtBc adds $0A to
; the byte at $D110+$000E, which is [$D11E], and caps that sum at $63.
;
; [$D112] is compared with $58. A value of $58 or more returns here.
; Otherwise that id is stored at [$D0C7] and $0A is stored at [$D0C8].
;
; The five-byte script at $C71B is $4C $B1 $48 $66 $0A: bank $4C, pointer
; $48B1, then the usual $66 $0A tail. Run560EThenWaitC71D runs that record.
;
; AddACapByteAtBc and Run560EThenWaitC71D are already source.

CapD11EThenPlantScript48B1::
    ld a, $02
    ld [$D071], a
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $0A
    call AddACapByteAtBc
    ld a, [$D112]
    cp $58
    ret nc
    ld [$D0C7], a
    ld a, $0A
    ld [$D0C8], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $B1
    ld [hl+], a
    ld a, $48
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call Run560EThenWaitC71D
    ret
