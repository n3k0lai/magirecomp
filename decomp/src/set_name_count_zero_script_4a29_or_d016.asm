; Bank 2 at $51D2.
;
; [$D076] (wNameCountFlag) is set to 1 and [$D077] (wNameCountAlt) is
; cleared, so WriteIndexedNamesAndCount prints a count of zero.
;
; AddDividerStep returns the new byte at $FFA9. The low two bits are
; compared with 3. When they match, [$D071] is set to 1 and the five-byte
; script at $C71B is $4C $29 $4A $66 $0A: bank $4C, pointer $4A29,
; handler DispatchScriptOpcode.
;
; Any other remainder sets [$D016] to 1 and [$D071] to 2.
;
; wNameCountFlag and wNameCountAlt are the names from
; write_indexed_names_and_count.asm. AddDividerStep and
; DispatchScriptOpcode are already source. Bank $4C at $4A29 is still
; INCBIN (file $0130A29).

SetNameCountZeroScript4A29OrD016::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    call AddDividerStep
    and $03
    cp $03
    jr nz, .enterD016
    ld a, $01
    ld [$D071], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $29
    ld [hl+], a
    ld a, $4A
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ret

.enterD016
    ld a, $01
    ld [$D016], a
    ld a, $02
    ld [$D071], a
    ret
