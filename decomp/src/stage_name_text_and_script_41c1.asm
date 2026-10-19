; Bank 2 at $46F4.
;
; A is saved. CallBankedHL runs bank 5 WriteIndexedNamesAndCount, which
; builds text at $C949. $49 $C9 is stored at $C93D so that word points at
; that text. The saved A is written to $CD93.
;
; CallBankedHL then runs bank 7 at $68B4, still INCBIN. That routine reads
; [$CD93].
;
; The five-byte script at $C71B is $4C $C1 $41 $66 $0A: bank $4C, pointer
; $41C1, handler $0A66. CallBankedHL runs bank 5 WaitUntilC71DClears, which
; returns once the stored high byte at $C71D is zero.
;
; WriteIndexedNamesAndCount, WaitUntilC71DClears, and CallBankedHL are
; already source.

StageNameTextAndScript41C1::
    push af
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    pop af
    ld [$CD93], a
    ld hl, $68B4
    ld e, $07
    call CallBankedHL
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $C1
    ld [hl+], a
    ld a, $41
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ret
