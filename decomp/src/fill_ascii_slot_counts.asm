; Bank 5 at $4A9D. RunD0B1MapStrips calls this after $4B05 and
; before the $9C00 map strips, with bank 5 still mapped.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names, and WRAM_BANK_ENTRY, are already defined. Twelve bytes at
; $D057 are filled with $2D, four groups of "---".
;
; Index C runs from 0. The word at $D0F1 plus 2*C is advanced by two
; and stored at $CD8D. Bank 5 at $5E45 returns the byte that pointer
; addresses in D. A zero byte leaves that group's dashes in place.
; Any other byte is formatted by FormatStartDigits and written as three
; ASCII digits (each place plus $30) at $D057 plus 3*C. Hundreds, tens,
; and ones are wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes.
;
; C then advances. C = 4 returns. Otherwise the flag at wNameSlotFlags
; plus the new C must be $FF or the routine returns, so slot 0 always
; runs and slots 1 through 3 run only when their own flag is $FF.
; wNameSlotFlags is the name from fill_focus_or_fight_and_four_slots.asm.
; FormatStartDigits, MulCByB, and CallBankedHL are already source.
; $5E45 is still INCBIN.

; Four three-byte fields. 4 * 3 = 12, the fill length.
DEF SLOT_COUNT EQU $04
DEF DIGITS_PER_SLOT EQU $03
DEF SLOT_DIGIT_BYTES EQU $0C

; Hyphen, so an unused or zero count stays "---".
DEF ASCII_HYPHEN EQU $2D
; FormatStartDigits leaves a binary place. Adding this makes '0' through '9'.
DEF ASCII_ZERO EQU $30

; First of the four ASCII fields.
DEF wSlotCountText EQU $D057
; Word per slot. Index N uses the word at this base plus 2*N.
DEF wSlotWordTable EQU $D0F1

; Pointer $5E45 reads. Low byte, then high byte.
DEF wPointedByteLow EQU $CD8D
DEF wPointedByteHigh EQU $CD8E

FillAsciiSlotCounts::
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, ASCII_HYPHEN
    ld hl, wSlotCountText
    ld b, SLOT_DIGIT_BYTES

.fillHyphen:
    ld [hl+], a
    dec b
    jr nz, .fillHyphen

    ld c, $00

.nextSlot:
    ld b, $00
    ld hl, wSlotWordTable
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    inc hl
    ld a, h
    ld [wPointedByteHigh], a
    ld a, l
    ld [wPointedByteLow], a
    ld hl, $5E45
    ld e, $05
    call CallBankedHL
    ld a, d
    ld d, $00
    or d
    jr z, .advance
    ld e, a
    push bc
    call FormatStartDigits
    pop bc
    ld b, DIGITS_PER_SLOT
    call MulCByB
    ld de, wSlotCountText
    add hl, de
    ld a, [wStartDigitHundreds]
    add a, ASCII_ZERO
    ld [hl+], a
    ld a, [wStartDigitTens]
    add a, ASCII_ZERO
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add a, ASCII_ZERO
    ld [hl+], a

.advance:
    inc c
    ld a, SLOT_COUNT
    cp c
    ret z
    ld b, $00
    ld hl, wNameSlotFlags
    add hl, bc
    ld a, [hl]
    cp $FF
    ret nz
    jr .nextSlot
