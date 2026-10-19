; Bank 7 at $6791. The first uncovered byte after
; FloorRemainderSramAndCopyEight.
;
; [$CD93] is the addend 2. [$CD94] runs from 1 through 5. Each pass
; calls $65AF, still INCBIN. When [$D103] is below $05 that call adds
; [$CD93] into the SRAM byte at the $D36E word for [$D103], plus
; [$CD94], plus 8, and caps the sum at $63. AddCd93IntoNextSramByte is
; the tail of that call.
;
; The five-byte script at $C71B then takes its bank and pointer from
; [$CDAA], [$CDAB], and [$CDAC], and its handler is
; DispatchScriptOpcode ($0A66). This returns.
;
; DispatchScriptOpcode is already source. The script bank and pointer
; are the bytes at $CDAA, so this routine does not name a fixed script
; address.

AddTwoToFiveNextSramThenPlantCdaa::
    ld bc, $0102
    ld hl, $CD93
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $65AF
    ld bc, $0202
    ld hl, $CD93
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $65AF
    ld bc, $0302
    ld hl, $CD93
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $65AF
    ld bc, $0402
    ld hl, $CD93
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $65AF
    ld bc, $0502
    ld hl, $CD93
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $65AF
    ld hl, $C71B
    ld a, [$CDAA]
    ld [hl+], a
    ld a, [$CDAB]
    ld [hl+], a
    ld a, [$CDAC]
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ret
