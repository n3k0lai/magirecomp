; Bank 2 at $5207. The word at $D107 is stored at $CD8D, and $CD8F
; is pointed at $CD91. CopyGroupBytes in bank 7 copies $22 bytes from
; that word onto $CD91. $CD8D and $CD8F are wGroupScaled and
; wGroupListPtr in scan_group_bytes.asm, which is included later.
;
; Bank 5 at $55E0, still INCBIN, builds the text that follows. $49 $C9
; is stored at $C93D so that word points at $C949. The five-byte script
; at $C71B is $4C $40 $4A $66 $0A: bank $4C, pointer $4A40, handler
; DispatchScriptOpcode. WaitUntilC71DClears runs that script.
;
; The last three bytes of the copy are a bank at $CDB0 and a pointer at
; $CDB1. Those are passed to StagePointerUnlessD0B6Matches. $49 $C9 is
; stored at $C93D again, and the word now at $CD91 is called in bank 7.
;
; CopyGroupBytes, CallBankedHL, WaitUntilC71DClears,
; StagePointerUnlessD0B6Matches, and DispatchScriptOpcode are already
; source. Bank 5 at $55E0 and bank $4C at $4A40 are still INCBIN. Their
; file addresses are $0155E0 and $0130A40.

CopyD107GroupThenScript4A40::
    ld hl, $D107
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8D
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $CD91
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, $07
    call CallBankedHL
    ld hl, $55E0
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $40
    ld [hl+], a
    ld a, $4A
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ld hl, $CDB1
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, [$CDB0]
    call StagePointerUnlessD0B6Matches
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $CD91
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $07
    call CallBankedHL
    ret
