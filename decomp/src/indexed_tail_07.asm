; Index 7 of IndexedSetup. Draw one SRAM list entry onto the start screen.
;
; $CD81 picks how $CC4C walks the ten-byte list at SRAM $A118 in the bank
; at $C727. $19, $1C, and $1D read that index once. $1B steps forward,
; skips $FF, and wraps from $A122 back to $A118 with the index cleared.
; Anything else steps backward, skips $FF, and wraps from $A117 to $A121
; with the index set to 9.
;
; The chosen byte times $25 is a record at $A000 in the next SRAM bank.
; Its first byte is stored at $CD8C. Bank 6's $5A60 runs with $CD8F
; pointing at $CC8A. Those bytes are copied to VRAM $8AB0, then $5134
; runs. WRAM bank 7 takes six bytes from record+9 into $D11B and two
; from record+$22 into $D134. Bank 5's $4109 runs, the six bytes move
; to $CD91, and $5EE8 writes each as two tiles.
;
; Five more record bytes (offsets 2, 3, 4, 7, and 8) land at $CD91.
; Two of them are drawn the same way. The word at $CD94 becomes the
; three start-screen digits at $9D2F. $617E runs for record+$22 into
; VRAM $8FD0 and record+$23 into VRAM $9090. The record's first byte
; is stored at $C9D8 and bank 4's $648D runs.
;
; $CC89 counts twenty calls through CopyGlyphBytes with the bank in
; $C6E6. $CC69 and $CC6A are set to 1. SRAM $A019 is OR-ed for $FE
; bytes in bank $C727. A nonzero result returns. A zero result sets
; $CCA4 and copies record+$22 and record+$23 over those two bytes.
;
; `add a, $00` leaves the RAM bank unchanged. The `and a` after the
; OR retests A once SRAM is off. The stores to rVBK and rRAMG are the
; 3-byte form. rRAMG is the name from reset.asm. rRAMB, wSRAMBank,
; SRAM_ENABLE, wBlockCount, wBlockSrc, wBlockDest, wUnknownCC4C, and
; wUnknownCD81 are the names from handle_start_press.asm. rVBK is the
; name from setup_window.asm. rSVBK and wCurrentWRAMBank are the names
; from timer_overflow.asm. wUnknownCC89 is the name from
; stamp_setup_attributes.asm. CopyIndexedBlocks, MulCByB, CallBankedHL,
; FormatStartDigits, WriteDigitTiles, and CopyGlyphBytes are already
; source. $5134, $5EE8, $617E, $5A60, $4109, and $648D are still INCBIN.

; Cleared on entry. Set when the $A019 scan is all zeros.
DEF wUnknownCCA4 EQU $CCA4

; First byte of the chosen record.
DEF wUnknownCD8C EQU $CD8C

; Pointer filled before the bank 6 call at $5A60. Low byte first.
DEF wUnknownCD8F EQU $CD8F

; Six stat bytes, then the five-byte map group, then a word for digits.
DEF wUnknownCD91 EQU $CD91

; Pair set to 1 before the $A019 scan. Replaced from the record if the scan is zero.
DEF wUnknownCC69 EQU $CC69

; Bank byte passed to CopyGlyphBytes. What selects it is still unknown.
DEF wUnknownC6E6 EQU $C6E6

; Destination pointer passed to the still-INCBIN routine at $648D.
DEF wUnknownC6E9 EQU $C6E9

; First byte of the record, saved again after the map writes.
DEF wUnknownC9D8 EQU $C9D8

; WRAM bank 7 holds the six-byte and two-byte copies from the record.
DEF WRAM_BANK_ENTRY EQU $07
DEF wEntrySix EQU $D11B
DEF wEntryPair EQU $D134

; List of ten ids in the SRAM bank at $C727. $FF entries are skipped.
DEF sEntryIds EQU $A118
DEF sEntryIdsEnd EQU $A122
DEF sEntryIdsBefore EQU $A117
DEF sEntryIdsLast EQU $A121
DEF ENTRY_ID_LAST EQU $09

; Records live in the next SRAM bank. Each is $25 bytes from $A000.
DEF sEntryBase EQU $A000
DEF ENTRY_STRIDE EQU $25
DEF ENTRY_SIX_OFF EQU $0009
DEF ENTRY_PAIR_OFF EQU $0022
DEF ENTRY_MAP_OFF EQU $0002

; $CD81 values that read $A118[$CC4C] without scanning.
DEF ENTRY_MODE_DIRECT_A EQU $19
DEF ENTRY_MODE_DIRECT_B EQU $1C
DEF ENTRY_MODE_DIRECT_C EQU $1D
; $CD81 value that scans the list forward.
DEF ENTRY_MODE_FORWARD EQU $1B

; Bytes OR-ed at $A019. A nonzero byte returns early.
DEF sEntryScan EQU $A019
DEF ENTRY_SCAN_LEN EQU $FE

; Tile copies and map cells. $A1 is the digit tile base.
DEF ENTRY_BLOCK_SRC EQU $CC8A
DEF ENTRY_BLOCK_DEST EQU $8AB0
DEF ENTRY_BLOCK_COUNT EQU $0A
DEF ENTRY_TAIL_DEST EQU $8FD0
DEF ENTRY_NEXT_DEST EQU $9090
DEF ENTRY_GLYPH_DEST EQU $8D60
DEF ENTRY_GLYPH_COUNT EQU $14
DEF ENTRY_DIGIT_BASE EQU $A1

DEF ENTRY_MAP_9C8A EQU $9C8A
DEF ENTRY_MAP_9C91 EQU $9C91
DEF ENTRY_MAP_9CCA EQU $9CCA
DEF ENTRY_MAP_9CAA EQU $9CAA
DEF ENTRY_MAP_9CB1 EQU $9CB1
DEF ENTRY_MAP_9CD1 EQU $9CD1
DEF ENTRY_MAP_9C6A EQU $9C6A
DEF ENTRY_MAP_9C71 EQU $9C71
DEF ENTRY_MAP_9D2F EQU $9D2F

; Still INCBIN. This bank stays mapped except across CallBankedHL.
DEF FAR_BANK_5A60 EQU $06
DEF Far_4109 EQU $4109
DEF FAR_BANK_4109 EQU $05
DEF Far_648D EQU $648D
DEF FAR_BANK_648D EQU $04

DrawIndexedEntry::
    xor a
    ld [wUnknownCCA4], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, [wUnknownCD81]
    cp ENTRY_MODE_DIRECT_A
    jr z, .readId

    cp ENTRY_MODE_DIRECT_B
    jr z, .readId

    cp ENTRY_MODE_DIRECT_C
    jr nz, .notDirect

.readId:
    ld a, [wUnknownCC4C]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc
    ld a, [hl]
    jr .haveId

.notDirect:
    cp ENTRY_MODE_FORWARD
    jr nz, .scanBack

    ld a, [wUnknownCC4C]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc

.scanForward:
    inc hl
    ld a, [wUnknownCC4C]
    inc a
    ld [wUnknownCC4C], a
    ld bc, sEntryIdsEnd
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    push hl
    add hl, bc
    ld a, h
    or l
    pop hl
    jr nz, .forwardByte

    xor a
    ld [wUnknownCC4C], a
    ld hl, sEntryIds

.forwardByte:
    ld a, [hl]
    cp $FF
    jr z, .scanForward

    jr .haveId

.scanBack:
    ld a, [wUnknownCC4C]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc

.scanBackLoop:
    dec hl
    ld a, [wUnknownCC4C]
    dec a
    ld [wUnknownCC4C], a
    ld bc, sEntryIdsBefore
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    push hl
    add hl, bc
    ld a, h
    or l
    pop hl
    jr nz, .backByte

    ld a, ENTRY_ID_LAST
    ld [wUnknownCC4C], a
    ld hl, sEntryIdsLast

.backByte:
    ld a, [hl]
    cp $FF
    jr z, .scanBackLoop

    jr .haveId

.haveId:
    ld c, a
    ld b, ENTRY_STRIDE
    call MulCByB
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld bc, sEntryBase
    add hl, bc
    push hl
    ld a, [hl]
    ld [wUnknownCD8C], a
    xor a
    ld [rRAMG], a
    ld bc, ENTRY_BLOCK_SRC
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, FAR_BANK_5A60
    call CallBankedHL
    ld hl, ENTRY_BLOCK_SRC
    ld a, h
    ld [wBlockSrc + 1], a
    ld a, l
    ld [wBlockSrc], a
    ld bc, ENTRY_BLOCK_DEST
    ld hl, wBlockDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, ENTRY_BLOCK_COUNT
    ld [wBlockCount], a
    call CopyIndexedBlocks
    call CopyIndex7VRAMTiles
    pop hl
    push hl
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, ENTRY_SIX_OFF
    add hl, bc
    ld bc, wEntrySix
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld d, $06

.copySix:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copySix

    pop hl
    push hl
    ld bc, ENTRY_PAIR_OFF
    add hl, bc
    ld bc, wEntryPair
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    xor a
    ld [rRAMG], a
    ld hl, Far_4109
    ld e, FAR_BANK_4109
    call CallBankedHL
    ld hl, wEntrySix
    ld bc, wUnknownCD91
    ld d, $06

.copyStats:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyStats

    xor a
    ld [rVBK], a
    ld a, [wUnknownCD91]
    ld hl, ENTRY_MAP_9C8A
    call WriteTwoDecimalTiles
    ld a, [wUnknownCD91 + 1]
    ld hl, ENTRY_MAP_9C91
    call WriteTwoDecimalTiles
    ld a, [wUnknownCD91 + 2]
    ld hl, ENTRY_MAP_9CCA
    call WriteTwoDecimalTiles
    ld a, [wUnknownCD91 + 3]
    ld hl, ENTRY_MAP_9CAA
    call WriteTwoDecimalTiles
    ld a, [wUnknownCD91 + 4]
    ld hl, ENTRY_MAP_9CB1
    call WriteTwoDecimalTiles
    ld a, [wUnknownCD91 + 5]
    ld hl, ENTRY_MAP_9CD1
    call WriteTwoDecimalTiles
    pop hl
    push hl
    ld bc, ENTRY_MAP_OFF
    add hl, bc
    ld bc, wUnknownCD91
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    inc hl
    inc hl
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    xor a
    ld [rRAMG], a
    ld a, [wUnknownCD91]
    ld hl, ENTRY_MAP_9C6A
    call WriteTwoDecimalTiles
    ld a, [wUnknownCD91 + 2]
    ld hl, ENTRY_MAP_9C71
    call WriteTwoDecimalTiles
    ld hl, wUnknownCD91 + 3
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld hl, ENTRY_MAP_9D2F
    ld d, ENTRY_DIGIT_BASE
    call WriteDigitTiles
    ld bc, ENTRY_TAIL_DEST
    ld hl, wBlockDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    pop hl
    push hl
    ld bc, ENTRY_PAIR_OFF
    call CopyRecordByteBlocks
    ld bc, ENTRY_NEXT_DEST
    ld hl, wBlockDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    pop hl
    push hl
    ld bc, ENTRY_PAIR_OFF + 1
    call CopyRecordByteBlocks
    pop hl
    push hl
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    ld [wUnknownC9D8], a
    xor a
    ld [rRAMG], a
    ld hl, Far_648D
    ld e, FAR_BANK_648D
    call CallBankedHL
    ld bc, ENTRY_GLYPH_DEST
    ld hl, wUnknownC6E9
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, ENTRY_GLYPH_COUNT
    ld [wUnknownCC89], a

.glyphs:
    ld a, [wUnknownC6E6]
    ld e, a
    ld hl, CopyGlyphBytes
    call CallBankedHL
    ld hl, wUnknownCC89
    dec [hl]
    jr nz, .glyphs

    ld hl, wUnknownCC69
    ld a, $01
    ld [hl+], a
    ld [hl+], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sEntryScan
    ld d, ENTRY_SCAN_LEN
    xor a

.orScan:
    or [hl]
    inc hl
    dec d
    jr nz, .orScan

    push af
    xor a
    ld [rRAMG], a
    pop af
    and a
    pop hl
    ret nz

    push hl
    ld a, $01
    ld [wUnknownCCA4], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    pop hl
    ld bc, ENTRY_PAIR_OFF
    add hl, bc
    or [hl]
    inc hl
    ld bc, wUnknownCC69
    ld [bc], a
    inc bc
    xor a
    or [hl]
    ld [bc], a
    xor a
    ld [rRAMG], a
    ret
