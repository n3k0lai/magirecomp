; StepSlotPair command $4D. This bank stays mapped.
;
; Slot $24 jumps to $6C9D, still INCBIN, which writes one of two fixed
; script records at wThirdScriptRecord. Any other slot stores 0 at $C723
; when the slot is 4, and 3 otherwise. The pointer at $C190 is read in
; WRAM bank 5 and that byte is stored at $C725. What those three bytes
; are used for is still unknown.
;
; The group pointer is wGroupPointers[(slot - wGroupFlagOffset) * 2].
; Its low byte minus the SRAM address at wGroupSRAM is saved at $CCA3
; and $C724. That offset times $22, plus wGroupAddend, is stored at
; wGroupScaled. wGroupListPtr is pointed at wGroupList0B, then
; CopyGroupBytes in bank 7 copies $22 bytes there. Mode 6 returns after
; that copy.
;
; Any other mode fills the script record FinishFrame runs at $C714.
; A nonzero word at $CDAE (inside the copied list) supplies the bank at
; $CDAD and that pointer. A zero word uses the bank at $C9FF and the
; pointer at $CA00. The handler is always $0A66. Thirteen bytes from
; wGroupListOther, also inside the copy, are then written at $C949 with
; a $FC byte after them, and $C93D is pointed at $C949. What reads that
; buffer is still unknown.
;
; Selecting WRAM bank 5 is ldh. Restoring it is the 3-byte form.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wUnknownCD81 and wUnknownCC47 are the names from handle_start_press.asm.
; wGroupPointers and wGroupFlagOffset are the names from
; write_group_row_digits.asm. wGroupSRAM, wGroupAddend, wGroupScaled,
; wGroupListPtr, wGroupList0B, and wGroupListOther are the names from
; scan_group_bytes.asm. GROUP_BYTE_COUNT is the name from
; copy_group_bytes.asm. MulCByB, CallBankedHL, CopyGroupBytes, and
; INITIAL_SCRIPT_HANDLER are already source.

; 0 when the slot is 4, else 3. What reads it is still unknown.
DEF wUnknownC723 EQU $C723

; Byte fetched through $C190 while WRAM bank 5 is mapped.
DEF wUnknownC725 EQU $C725
DEF wBank5Ptr EQU $C190
DEF WRAM_BANK5 EQU $05

; Low byte of (group pointer - SRAM address). IndexedSetup also writes $CCA3.
DEF wUnknownCCA3 EQU $CCA3
DEF wUnknownC724 EQU $C724

; Third of the four script records FinishFrame runs.
DEF wThirdScriptRecord EQU $C714

; Bank and pointer inside the $22 bytes CopyGroupBytes wrote at $CD91.
DEF wGroupListBank EQU $CDAD
DEF wGroupListWord EQU $CDAE

; Used when that word is zero. What fills them is still unknown.
DEF wFallbackScriptBank EQU $C9FF
DEF wFallbackScriptPtr EQU $CA00

; Destination of the 13-byte tail, and the pointer stored just before it.
DEF wUnknownC93D EQU $C93D
DEF wListTailDest EQU $C949
DEF LIST_TAIL_LEN EQU $0D
DEF LIST_TAIL_MARK EQU $FC

SetupCommand4D::
    ld a, [wUnknownCD81]
    cp $24
    jp z, WriteSlot24ScriptRecord

    cp $04
    jr nz, .slotNot4

    ld a, $00
    jr .storeSlotKind

.slotNot4:
    ld a, $03

.storeSlotKind:
    ld [wUnknownC723], a
    ld hl, wBank5Ptr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wCurrentWRAMBank]
    push af
    ld a, WRAM_BANK5
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl]
    ld [wUnknownC725], a
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ld a, [wGroupFlagOffset]
    ld b, a
    ld a, [wUnknownCD81]
    sub b
    add a
    ld c, a
    ld b, $00
    ld hl, wGroupPointers
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wGroupSRAM + 1]
    ld b, a
    ld a, [wGroupSRAM]
    ld c, a
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld b, l
    ld a, l
    ld [wUnknownCCA3], a
    ld [wUnknownC724], a
    ld c, GROUP_BYTE_COUNT
    call MulCByB
    ld a, [wGroupAddend + 1]
    ld b, a
    ld a, [wGroupAddend]
    ld c, a
    add hl, bc
    ld a, h
    ld [wGroupScaled + 1], a
    ld a, l
    ld [wGroupScaled], a
    ld bc, wGroupList0B
    ld hl, wGroupListPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, GROUP_BUILD_BANK
    call CallBankedHL
    ld a, [wUnknownCC47]
    cp $06
    ret z

    ld hl, wGroupListWord
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .fallbackScript

    ld hl, wThirdScriptRecord
    ld a, [wGroupListBank]
    ld [hl+], a
    ld a, [wGroupListWord]
    ld [hl+], a
    ld a, [wGroupListWord + 1]
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a

.copyTail:
    ld hl, wGroupListOther
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld bc, wListTailDest
    ld d, LIST_TAIL_LEN

.copyByte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyByte

    ld a, LIST_TAIL_MARK
    ld [bc], a
    inc bc
    ret

.fallbackScript:
    ld hl, wThirdScriptRecord
    ld a, [wFallbackScriptBank]
    ld [hl+], a
    ld a, [wFallbackScriptPtr]
    ld [hl+], a
    ld a, [wFallbackScriptPtr + 1]
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    jr .copyTail
