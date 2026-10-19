; InstallSoundIndex calls this at $3D65 after it stores the countdown
; table at $DFA7 and its bank at $DFA9. That pointer is already $84
; past the raw entry, the addend InstallSoundIndex applied.
;
; $DFA9 is mapped through MapRomBank. Subtracting $84 reaches four
; bytes, copied to $DFAD-$DFB0. The address of the following byte is
; saved at $DFB1. What those four bytes mean is unknown.
;
; The stored table's first big-endian word is an offset from the table
; to four big-endian slot offsets. A nonzero offset is added to the
; table and stored at $DFB3 + slot * 2, and bit `slot` of $DFA6 is set.
; A zero offset leaves that pointer and that bit clear.
;
; Each nonzero pointer is then read for three bytes. The first becomes
; the high byte of the 24-bit count at $DFBF + slot * 3, the second the
; middle byte, and the third the action at $DFBB + slot. The low byte
; of the count stays at the zero InstallSoundIndex wrote.
;
; Control leaves through MapRomBank with A = [$DF00]. It does not
; return to this routine.
;
; wCountdownFlags ($DFA6), wCountdownAction ($DFBB), and the count at
; $DFBF are the names from step_sound_countdowns.asm. wCountdownTable
; ($DFA7) is the name from step_indexed_countdown.asm.

DEF wSeedSavedBank EQU $DF00
DEF wSeedFlags EQU $DFA6
DEF wSeedTable EQU $DFA7
DEF wSeedBank EQU $DFA9
DEF wSeedHeader EQU $DFAD
DEF wSeedHeaderNext EQU $DFB1
DEF wSeedRecord EQU $DFB3
DEF wSeedAction EQU $DFBB
DEF wSeedCountHigh EQU $DFC1
DEF wSeedSlot EQU $DFF9
DEF wSeedActionByte EQU $DFFA

SeedCountdownFromTable:
    ld a, [wSeedBank]
    call MapRomBank
    ld a, [wSeedTable]
    ld l, a
    ld a, [wSeedTable + 1]
    ld h, a
    push hl
    ld bc, $ff7c
    add hl, bc
    ld a, [hl+]
    ld [wSeedHeader], a
    ld a, [hl+]
    ld [wSeedHeader + 1], a
    ld a, [hl+]
    ld [wSeedHeader + 2], a
    ld a, [hl+]
    ld [wSeedHeader + 3], a
    ld a, l
    ld [wSeedHeaderNext], a
    ld a, h
    ld [wSeedHeaderNext + 1], a
    pop hl
    ld a, [hl+]
    ld b, a
    ld a, [hl-]
    ld c, a
    ld e, l
    ld d, h
    add hl, bc
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a

.slot0:
    or b
    jr z, .slot1

    push hl
    ld l, e
    ld h, d
    add hl, bc
    ld a, l
    ld [wSeedRecord], a
    ld a, h
    ld [wSeedRecord + 1], a
    ld hl, wSeedFlags
    set 0, [hl]
    pop hl

.slot1:
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    or b
    jr z, .slot2

    push hl
    ld l, e
    ld h, d
    add hl, bc
    ld a, l
    ld [wSeedRecord + 2], a
    ld a, h
    ld [wSeedRecord + 3], a
    ld hl, wSeedFlags
    set 1, [hl]
    pop hl

.slot2:
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    or b
    jr z, .slot3

    push hl
    ld l, e
    ld h, d
    add hl, bc
    ld a, l
    ld [wSeedRecord + 4], a
    ld a, h
    ld [wSeedRecord + 5], a
    ld hl, wSeedFlags
    set 2, [hl]
    pop hl

.slot3:
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    or b
    jr z, .load_counts

    push hl
    ld l, e
    ld h, d
    add hl, bc
    ld a, l
    ld [wSeedRecord + 6], a
    ld a, h
    ld [wSeedRecord + 7], a
    pop hl
    ld hl, wSeedFlags
    set 3, [hl]

.load_counts:
    ld hl, wSeedRecord
    ld de, wSeedCountHigh
    xor a

.next_count:
    ld [wSeedSlot], a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    or c
    jr z, .advance_count

    ld a, [bc]
    inc bc
    ld [de], a
    dec de
    ld a, [bc]
    ld [de], a
    inc de
    inc bc
    ld a, [bc]
    ld [wSeedActionByte], a
    ld bc, wSeedAction
    ld a, [wSeedSlot]
    add c
    ld c, a
    ld a, b
    adc $00
    ld b, a
    ld a, [wSeedActionByte]
    ld [bc], a

.advance_count:
    inc de
    inc de
    inc de
    ld a, [wSeedSlot]
    inc a
    cp $04
    jr nz, .next_count

    ld a, [wSeedSavedBank]
    jp MapRomBank

SeedCountdownFromTableEnd:
