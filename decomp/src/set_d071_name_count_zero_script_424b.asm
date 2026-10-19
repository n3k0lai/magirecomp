; Bank 2 at $5191. Stage4C5225UnlessD0FFOrD073Zero jumps here when
; [$D0FF] is nonzero.
;
; [$D071] and [$D076] (wNameCountFlag) are set to 1, and [$D077]
; (wNameCountAlt) is cleared, so WriteIndexedNamesAndCount prints a
; count of zero. That call is bank 5 through CallBankedHL. $49 $C9 is
; then stored at $C93D, pointing that word at wListTailDest ($C949),
; the text just built.
;
; The five-byte script at $C71B is $4C $4B $42 $66 $0A: bank $4C,
; pointer $424B, handler DispatchScriptOpcode.
;
; CallBankedHL, WriteIndexedNamesAndCount, and DispatchScriptOpcode
; are already source. Bank $4C at $424B is still INCBIN (file $013024B).

SetD071NameCountZeroScript424B::
    ld a, $01
    ld [$D071], a
    ld [$D076], a
    xor a
    ld [$D077], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $4B
    ld [hl+], a
    ld a, $42
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ret
