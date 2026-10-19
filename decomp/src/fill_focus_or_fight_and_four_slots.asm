; Bank 2 at $5F4D. DriveD0B1Choice calls this before bank 5 at $45B0.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names are from timer_overflow.asm. $D0FF is cleared.
;
; A zero [$D0B1] plants the bank 5 record at $5F0E ("Focus") at
; wIndexedWordLow. Any other value plants $5EAE ("Fight"). wIndexedTilePtr
; is $D02A and wIndexedCallFlag is 0, so FillIndexedSlot writes only the
; seven-byte field and does not append the extra bytes.
;
; Eight bytes at $D0F1 are copied to $D01B. Indexes 3, 2, 1, and 0 then
; each read the flag at $D0F9 plus that index. $FF loads the word at
; $D01B plus twice the index. Any other flag uses word 0, which
; FillIndexedSlot turns into seven spaces. The destination is $D031 plus
; index times 7, the same length FillIndexedSlot copies. The flag stays 0.
;
; After index 0, E is $FF and the routine returns. The load from $D01B
; on the way back to the loop is unused.
;
; wIndexedWordLow, wIndexedTilePtr, and wIndexedCallFlag are the names
; from indexed_tail_08.asm. MulCByB, CallBankedHL, and FillIndexedSlot
; are already source. $5EAE and $5F0E are still INCBIN data in bank 5.

; Seven bytes between name slots, matching FillIndexedSlot's copy length.
DEF NAME_SLOT_STRIDE EQU $07

; Last of the four flags at $D0F9. The loop counts down through 0.
DEF NAME_SLOT_LAST EQU $03

; Four words copied from $D0F1 onto $D01B.
DEF NAME_WORD_BYTES EQU $08

; Field written for the Fight or Focus record, just before the four slots.
DEF wFocusFightField EQU $D02A

; First of the four name slots.
DEF wNameSlot0 EQU $D031

; Words copied from $D0F1. Slot index N uses the word at this base plus 2N.
DEF wNameWords EQU $D01B

; One flag byte per slot. $FF keeps that slot's word; anything else blanks it.
DEF wNameSlotFlags EQU $D0F9

FillFocusOrFightAndFourSlots::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [$D0FF], a
    ld bc, $5EAE
    ld a, [$D0B1]
    cp $00
    jr nz, .plantRecord

    ld bc, $5F0E

.plantRecord:
    ld hl, wIndexedWordLow
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, wFocusFightField
    ld hl, wIndexedTilePtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    xor a
    ld [wIndexedCallFlag], a
    ld hl, FillIndexedSlot
    ld e, $05
    call CallBankedHL
    ld bc, $D0F1
    ld hl, wNameWords
    ld d, NAME_WORD_BYTES

.copyWords:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyWords

    ld e, NAME_SLOT_LAST
    ld d, $00

.nextSlot:
    ld hl, wNameSlotFlags
    add hl, de
    ld a, [hl]
    cp $FF
    jr z, .loadWord

    ld bc, $0000
    push bc
    jr .placeSlot

.loadWord:
    ld hl, wNameWords
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl

.placeSlot:
    ld b, NAME_SLOT_STRIDE
    ld c, e
    push de
    call MulCByB
    pop de
    ld bc, wNameSlot0
    add hl, bc
    pop bc
    ld a, h
    ld [wIndexedTilePtr + 1], a
    ld a, l
    ld [wIndexedTilePtr], a
    ld hl, wIndexedWordLow
    ld a, c
    ld [hl+], a
    ld [hl], b
    xor a
    ld [wIndexedCallFlag], a
    push de
    ld hl, FillIndexedSlot
    ld e, $05
    call CallBankedHL
    pop de
    dec e
    ld a, $FF
    cp e
    ret z

    ld hl, wNameWords
    add hl, de
    ld a, [hl]
    jr .nextSlot
