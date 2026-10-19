; Bank 2 at $505C. SetD071TwoIfD017AndD09AClosed jumps here when
; [$D017] is zero or [$D09A] is nonzero.
;
; [$D0B6] of 9 skips the random byte. Any other value stores
; (rDIV & 7) + 1 at [$D073] and 1 at [$D070]. A zero [$D017] then
; takes the indexed-id path. A set [$D017], and the [$D0B6] == 9
; path, share the count-flag path.
;
; The count-flag path reads the word at $D117. A zero word stores 1
; at [$D077]; any other word stores 0. [$D076] and [$D070] are set
; to 1, so WriteIndexedNamesAndCount prints [$D077]. The five-byte
; script at $C71B is $4C $76 $43 $66 $0A: bank $4C, pointer $4376,
; handler DispatchScriptOpcode.
;
; The indexed-id path stores $58 at [$D0C2], $05 at [$D0C0], and $0B
; at [$D0C1], then calls ApplyIndexedIdRecord in bank 5. The script
; at $C71B is $4C $86 $43 $66 $0A: bank $4C, pointer $4386, same
; handler. [$D076] is left alone, so the name count is [$D073].
;
; Both paths store 1 at [$D071], call WriteIndexedNamesAndCount, and
; plant $49 $C9 at $C93D so that word points at the text built there.
;
; MaskDivByC, CallBankedHL, ApplyIndexedIdRecord, and
; WriteIndexedNamesAndCount are already source. DispatchScriptOpcode
; is the name from dispatch_script_opcode.asm. Bank $4C at $4376 and
; $4386 is still INCBIN. Their file addresses are $130376 and $130386.

StageNameCountWhenD017ClearOrD09AOpen::
    ld a, [$D0B6]
    cp $09
    jr z, .countFlag
    ld c, $07
    call MaskDivByC
    inc a
    ld [$D073], a
    ld a, $01
    ld [$D070], a
    ld a, [$D017]
    and a
    jr z, .indexedId
.countFlag:
    ld hl, $D117
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr nz, .clearAlt
    ld a, $01
    jr .storeAlt
.clearAlt:
    xor a
.storeAlt:
    ld [$D077], a
    ld a, $01
    ld [$D076], a
    ld [$D070], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $76
    ld [hl+], a
    ld a, $43
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .names
.indexedId:
    ld a, $58
    ld [$D0C2], a
    ld a, $05
    ld [$D0C0], a
    ld a, $0B
    ld [$D0C1], a
    ld hl, ApplyIndexedIdRecord
    ld e, $05
    call CallBankedHL
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $86
    ld [hl+], a
    ld a, $43
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.names:
    ld a, $01
    ld [$D071], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ret
