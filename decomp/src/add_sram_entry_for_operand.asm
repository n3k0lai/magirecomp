; Bank 4 at $5D19. Opcode $2C stores its first operand at $CD51 and its
; second at $CD50, then CallBankedHL enters here. Only $CD51 is read.
;
; SRAM bank wSRAMBank is enabled and the byte at sEntryIdsEnd is
; incremented (`add a, $00` leaves the bank byte unchanged). The operand
; is saved at $C726. Its $2D-byte record is ENTRY_RECORD_TABLE plus the
; operand times ENTRY_RECORD_STRIDE, stored at $CD8D. $CD91 is stored at
; $CD8F, and bank 4's $40F0 runs. That address is still INCBIN.
;
; SRAM bank wSRAMBank + 1 is then enabled. Records of ENTRY_STRIDE bytes
; are scanned from sEntryBase + ENTRY_STRIDE until a $FF byte. The index
; of that record is stored at $CD56 and the address at $CD52. The free
; slot is filled from $CD51 and the $CD91 buffer:
;   +0       the operand
;   +1       [$CD91]
;   +2       1
;   +3..+7   zero
;   +8       [$CD92]
;   +9..+18  [$CD95] through [$CD9E]
;   +19      zero
;   +20..+21 [$CD9F] and [$CDA0]
;   +22..+33 [$CDA2] through [$CDAD]
;   +34..+36 zero
; SRAM is disabled. Bank 2's $5B35, still INCBIN, runs, and the WRAM bank
; saved at wCurrentWRAMBank is written back with the 3-byte `ld [rSVBK], a`.
;
; SRAM bank wSRAMBank is enabled again. The first $FF among the ten
; sEntryIds bytes is replaced with the new record index ($CD56 plus 1).
; A list with no $FF is left as it is. SRAM is disabled and this returns.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from handle_start_press.asm.
; rRAMG is the name from reset.asm. sEntryIds, sEntryIdsEnd, sEntryBase,
; and ENTRY_STRIDE are the names from indexed_tail_07.asm.
; ENTRY_RECORD_TABLE and ENTRY_RECORD_STRIDE are the names from
; record_ptr_from_id.asm. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. MulCByB and CallBankedHL are already source.

; Bytes copied from $CD95 and from $CDA2.
DEF ENTRY_NAME_COPY EQU $0A
DEF ENTRY_TAIL_COPY EQU $0C

; Ten id slots at sEntryIds. $FF marks a free slot.
DEF ENTRY_ID_SLOTS EQU $0A

AddSRAMEntryForOperand::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sEntryIdsEnd
    inc [hl]
    xor a
    ld [rRAMG], a
    ld a, [$CD51]
    ld [$C726], a
    ld b, a
    ld c, ENTRY_RECORD_STRIDE
    call MulCByB
    ld bc, ENTRY_RECORD_TABLE
    add hl, bc
    ld a, h
    ld [$CD8E], a
    ld a, l
    ld [$CD8D], a
    ld bc, $CD91
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $40F0
    ld e, $04
    call CallBankedHL
    ld hl, sEntryBase + ENTRY_STRIDE
    ld bc, ENTRY_STRIDE
    ld d, $00
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
.findFree:
    ld a, [hl]
    cp $FF
    jr z, .foundFree
    add hl, bc
    inc d
    jr .findFree
.foundFree:
    ld a, d
    ld [$CD56], a
    ld a, h
    ld [$CD53], a
    ld a, l
    ld [$CD52], a
    ld bc, $CD91
    ld a, [$CD51]
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, $01
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    inc bc
    inc bc
    ld d, ENTRY_NAME_COPY
.copyName:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyName
    xor a
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    inc bc
    inc bc
    ld d, ENTRY_TAIL_COPY
.copyTail:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyTail
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [rRAMG], a
    ld a, [wCurrentWRAMBank]
    push af
    ld hl, $5B35
    ld e, $02
    call CallBankedHL
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ld hl, sEntryIds
    ld d, ENTRY_ID_SLOTS
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, $FF
.scanIds:
    cp [hl]
    jr z, .storeIndex
    inc hl
    dec d
    jr nz, .scanIds
    jr .disable
.storeIndex:
    ld a, [$CD56]
    inc a
    ld [hl], a
.disable:
    xor a
    ld [rRAMG], a
    ret
