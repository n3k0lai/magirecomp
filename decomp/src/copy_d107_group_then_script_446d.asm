; Bank 2 at $50E6. The word at $D107 is stored at $CD8D, and $CD8F
; is pointed at $CD91. CopyGroupBytes in bank 7 copies $22 bytes from
; that word onto $CD91.
;
; Bank 5 at $55E0, still INCBIN, builds the text that follows. $49 $C9
; is stored at $C93D so that word points at $C949. The five-byte script
; at $C71B is $4C $6D $44 $66 $0A: bank $4C, pointer $446D, handler
; DispatchScriptOpcode. WaitUntilC71DClears runs that script.
;
; The word now at $CD91 is called in bank 7. $49 $C9 is stored at $C93D
; again. A nonzero [$D017] returns. A zero [$D017] treats the original
; word at $D107 as a group pointer: subtract $5DFF, divide by $22, and
; add the quotient to $A3A7. SRAM bank [$C727] is enabled for that one
; byte, which is decremented. SRAM is disabled and [$D107] is cleared.
;
; CopyGroupBytes, CallBankedHL, WaitUntilC71DClears, DivideHLByA, and
; DispatchScriptOpcode are already source. rRAMG is the name from
; reset.asm. $C727 and $4000 are the SRAM bank and RAM-bank register
; named wSRAMBank and rRAMB in handle_start_press.asm, which is included
; later. Bank 5 at $55E0 and bank $4C at $446D are still INCBIN. Their
; file addresses are $0155E0 and $013046D.

CopyD107GroupThenScript446D::
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
    ld a, $6D
    ld [hl+], a
    ld a, $44
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ld hl, $CD91
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $07
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld a, [$D017]
    and a
    ret nz

    ld hl, $D107
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $5DFF
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, $22
    call DivideHLByA
    ld l, a
    ld h, $00
    ld bc, $A3A7
    add hl, bc
    ld a, $0A
    ld [rRAMG], a
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    dec [hl]
    xor a
    ld [rRAMG], a
    xor a
    ld [$D107], a
    ret
