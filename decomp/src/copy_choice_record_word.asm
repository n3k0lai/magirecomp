; Bank 3 at $6D72. PaintPrefixedChoiceRows calls here with the choice
; id in A when the mode at $CCCB is not zero. $6930 calls here with
; that same id after selecting SRAM bank 0. This routine does not write
; rROMB0. The bank change goes through CallBankedHL.
;
; B keeps the id and C is $22. MulCByB leaves the product in HL. Adding
; $5DFF and then $0A points at $5E09 plus the id times $22, the first
; word of that bank 7 record. The pointer is stored at $CD8D. $CD8F
; points at $CD91. CallBankedHL maps bank 7 and runs $5D9B, which copies
; those two bytes to $CD91. They return in BC, low byte in C.
;
; GROUP_BASE_5DFF and STRIDE_22 are the names from
; setup_prefixed_block_choice.asm. $CD8D and $CD8F are wGroupScaled and
; wGroupListPtr in scan_group_bytes.asm, which is included later.
; MulCByB and CallBankedHL are already source. $5D9B is still INCBIN.

; Still INCBIN in bank 7. Copies two bytes from [$CD8D] to [$CD8F].
DEF Bank7_5D9B EQU $5D9B

; Bytes from the group base at $5DFF to the record's first word.
DEF RECORD_WORD_SKIP EQU $0A

DEF CHOICE_WORD_PTR EQU $CD8D
DEF CHOICE_WORD_PTR_HI EQU $CD8E
DEF CHOICE_WORD_DEST_PTR EQU $CD8F
DEF CHOICE_WORD_DEST EQU $CD91
DEF CHOICE_WORD_BANK EQU $07

CopyChoiceRecordWord::
    ld b, a
    ld c, STRIDE_22
    call MulCByB
    ld de, GROUP_BASE_5DFF
    add hl, de
    ld e, RECORD_WORD_SKIP
    ld d, $00
    add hl, de
    ld a, h
    ld [CHOICE_WORD_PTR_HI], a
    ld a, l
    ld [CHOICE_WORD_PTR], a
    ld bc, CHOICE_WORD_DEST
    ld hl, CHOICE_WORD_DEST_PTR
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, Bank7_5D9B
    ld e, CHOICE_WORD_BANK
    call CallBankedHL
    ld hl, CHOICE_WORD_DEST
    ld c, [hl]
    inc hl
    ld b, [hl]
    ret
