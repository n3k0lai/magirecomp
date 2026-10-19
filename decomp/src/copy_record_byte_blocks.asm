; Read one SRAM record byte and queue twelve tile indexes for CopyIndexedBlocks.
;
; The caller passes the record base in HL and a byte offset in BC, and has
; already stored the VRAM destination at $CC45. This adds the offset, maps
; SRAM bank $C727+1, and copies that one byte to $CD91. HL and BC both
; advance; neither value is used again.
;
; A nonzero byte is saved at $CD8C. $CD8F is pointed at $CD91, then
; CallBankedHL runs bank 7's $68F8. A zero byte instead copies twelve
; indexes from $524E in this bank to $CD98. Either way, $CC43 is set to
; $CD98, $CC42 is set to 12, and CopyIndexedBlocks runs. The caller owns
; the destination, so the two record bytes at offsets $22 and $23 land at
; different VRAM addresses.
;
; $C727, $CC42, and $CC43 are wSRAMBank, wBlockCount, and wBlockSrc from
; handle_start_press.asm, which is included later. rRAMG is the name from
; reset.asm. The stores to rRAMG are the 3-byte form. CallBankedHL and
; CopyIndexedBlocks are already source. $68F8 and the twelve bytes at
; $524E are still INCBIN.

; Byte just read from the record. Also the lookup buffer.
DEF wRecordByte EQU $CD91

; Id passed to the bank 7 lookup. Same address as the script id at $CD8C.
DEF wRecordByteId EQU $CD8C

; Pointer to wRecordByte, low byte first.
DEF wRecordBytePtr EQU $CD8F

; Twelve tile indexes consumed by CopyIndexedBlocks.
DEF wRecordIndexes EQU $CD98
DEF RECORD_INDEX_COUNT EQU $0C

; Bank 7 lookup for the id at $CD8C. Same entry RunPairIdScripts uses.
DEF RecordByteLookup EQU $68F8
DEF RECORD_BYTE_BANK EQU $07

CopyRecordByteBlocks::
    add hl, bc
    ld bc, wRecordByte
    ld a, [$C727]
    add a, $01
    ld [$4000], a
    ld a, $0A
    ld [rRAMG], a
    ld a, [hl+]
    ld [bc], a
    inc bc
    xor a
    ld [rRAMG], a
    ld a, [wRecordByte]
    and a
    jr z, .defaultIndexes

    ld [wRecordByteId], a
    ld bc, wRecordByte
    ld hl, wRecordBytePtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, RecordByteLookup
    ld e, RECORD_BYTE_BANK
    call CallBankedHL

.queueIndexes:
    ld bc, wRecordIndexes
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, RECORD_INDEX_COUNT
    ld [$CC42], a
    call CopyIndexedBlocks
    ret

.defaultIndexes:
    ld bc, wRecordIndexes
    ld hl, DefaultRecordIndexGlyphs
    ld d, RECORD_INDEX_COUNT
.copyDefault:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyDefault
    jr .queueIndexes
