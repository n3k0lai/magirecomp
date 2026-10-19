; Bank 7 at $425F.
;
; Saves wCurrentROMBank, then CallBankedHL runs RecordPtrFromId in bank 4
; and restores that bank. HL comes back as the entry record plus $1E.
; Eight more bytes land on a little-endian pointer and the bank byte after
; it. wUnknownC9DA selects how far to walk that pointer:
; 0 adds 0, 1 adds $18, 2 adds $30, and 3 adds $48. Any other value adds
; 0. $18 is one block of twelve words.
;
; `ld a, imm` does not change flags, so the `jr z` after $30 and after $48
; is taken because the matching `cp` just set Z.
;
; The adjusted pointer is stored at wPairSourcePtr and the bank byte at
; wPairSourceBank. MapPairBankThenCopyTwelveWordPairs copies that block.
; The saved bank is written back to wCurrentROMBank and rROMB0.
;
; RecordPtrFromId is the name from record_ptr_from_id.asm. CallBankedHL is
; the name from call_hl_in_bank.asm. wUnknownC9DA is the name from
; dispatch_nonzero_d016.asm. wPairSourcePtr and wPairSourceBank are the
; names from load_c9_record_picture.asm. MapPairBankThenCopyTwelveWordPairs
; is the name from map_pair_bank_then_copy_twelve_word_pairs.asm.
; wCurrentROMBank and rROMB0 are the names from reset.asm.

; Bytes from RecordPtrFromId's return value to the pointer and bank.
DEF PAIR_FIELD_SKIP EQU $0008

; One block of twelve word pairs.
DEF PAIR_BLOCK_BYTES EQU $18

StagePairBlockFromEntryRecord::
    ld a, [wCurrentROMBank]
    push af
    ld hl, RecordPtrFromId
    ld e, $04
    call CallBankedHL
    ld bc, PAIR_FIELD_SKIP
    add hl, bc
    ld b, $00
    ld a, [wUnknownC9DA]
    cp b
    jr z, .storePair

    cp $01
    jr nz, .checkTwo

    ld a, 1 * PAIR_BLOCK_BYTES
    jr .storePair

.checkTwo:
    cp $02
    jr nz, .checkThree

    ld a, 2 * PAIR_BLOCK_BYTES
    jr z, .storePair

.checkThree:
    cp $03
    jr nz, .clearOffset

    ld a, 3 * PAIR_BLOCK_BYTES
    jr z, .storePair

.clearOffset:
    xor a

.storePair:
    ld c, a
    ld a, [hl+]
    push hl
    ld h, [hl]
    ld l, a
    add hl, bc
    ld b, h
    ld c, l
    ld a, c
    ld [wPairSourcePtr], a
    ld a, b
    ld [wPairSourcePtr + 1], a
    pop hl
    inc hl
    ld a, [hl+]
    ld [wPairSourceBank], a
    call MapPairBankThenCopyTwelveWordPairs
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
