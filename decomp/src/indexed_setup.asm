; Copy tile blocks for the index in $CC47, then run that index's tail.
;
; $CC47 times two selects a pointer in the table at $51D9. That record's
; first word is the block destination ($CC45). The next byte is how many
; groups follow. Each group is a source pointer ($CC43) and a count ($CC42).
; CopyIndexedBlocks copies each group. Indexes 0, 1, and 2 are rewritten
; and this runs again: 0 becomes 1, 1 becomes 5, and 2 becomes 7.
; Index $0A returns after the copies. Every other index calls $5157, then:
;   3, 4, 6, $0B  store words at $CC82 and bytes at $CC87, call $63D6 and
;                 $636A, set $CD81, and call $4274 in bank 3
;   5             calls $6649
;   7             calls $6A39
;   8             calls $6CCA
;   9             calls $659C
;   $0B           also fills eleven $80 bytes on five map rows at $9C66
;                 when the matching byte at $CC5A is zero
; Index 6 also clears $CCA3 and $CCA1. The exit stores 0 in $CC4B.
; Anything that is not one of those indexes spins on the compare with 9.
;
; CopyIndexedBlocks, MulCByB, and CallBankedHL are already source.
; $CC42, $CC43, and $CC45 are wBlockCount, wBlockSrc, and wBlockDest in
; handle_start_press.asm. $CC47 and $CC4B are named there and in
; after_start_loop.asm. Those EQUs are included later, so this file uses
; the addresses.

; Bank stored by CallBankedHL for indexes 3, 4, 6, and $0B.
DEF INDEXED_FAR_BANK EQU $03
DEF IndexedFar4274 EQU $4274

; First map address filled for index $0B, and how many $80 bytes.
DEF INDEXED_MAP_ROW EQU $9C66
DEF INDEXED_MAP_FILL EQU $0B
DEF INDEXED_ROW_BYTES EQU $20
DEF INDEXED_ROW_COUNT EQU $05

IndexedSetup::
    ld hl, $51D9
    ld a, [$CC47]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, d
    ld [$CC46], a
    ld a, e
    ld [$CC45], a
    ld a, [hl+]
    ld d, a
.groups:
    push de
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    ld a, b
    ld [$CC44], a
    ld a, c
    ld [$CC43], a
    ld a, [hl+]
    ld [$CC42], a
    push hl
    call CopyIndexedBlocks
    pop hl
    pop de
    dec d
    jr nz, .groups
    ld a, [$CC47]
    cp $03
    jr nc, .past_low
    inc a
    cp $01
    jr z, .restart
    sla a
    inc a
.restart:
    ld [$CC47], a
    jr IndexedSetup
.past_low:
    ld a, [$CC47]
    cp $0A
    jp z, .clear
    call CopyIndexedMap
    ld a, [$CC47]
    cp $07
    jr nz, .not07
    call DrawIndexedEntry
    jp .clear
.not07:
    cp $04
    jr nz, .not04
    ld bc, $A3A7
    ld hl, $CC82
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $5DFF
    ld hl, $CC84
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $0D
    ld [$CC87], a
    ld a, $22
    ld [$CC88], a
    call ScanGroupBytes
    call WriteGroupRowDigits
    ld a, $0D
    ld [$CD81], a
    ld hl, IndexedFar4274
    ld e, INDEXED_FAR_BANK
    call CallBankedHL
    jp .clear
.not04:
    cp $03
    jr nz, .not03
    ld bc, $A5A5
    ld hl, $CC82
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $6FF5
    ld hl, $CC84
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $06
    ld [$CC87], a
    ld a, $22
    ld [$CC88], a
    call ScanGroupBytes
    call WriteGroupRowDigits
    ld a, $06
    ld [$CD81], a
    ld hl, IndexedFar4274
    ld e, INDEXED_FAR_BANK
    call CallBankedHL
    jp .clear
.not03:
    cp $06
    jr nz, .not06
    xor a
    ld [$CCA3], a
    ld [$CCA1], a
    ld bc, $A019
    ld hl, $CC82
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $6916
    ld hl, $CC84
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $0D
    ld [$CC87], a
    ld a, $13
    ld [$CC88], a
    call ScanGroupBytes
    call WriteGroupRowDigits
    ld a, $0D
    ld [$CD81], a
    ld hl, IndexedFar4274
    ld e, INDEXED_FAR_BANK
    call CallBankedHL
    jr .clear
.not06:
    cp $0B
    jr nz, .not0B
    ld bc, $A4A6
    ld hl, $CC82
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $0D
    ld [$CC87], a
    ld a, $01
    ld [$CC88], a
    call ScanGroupBytes
    call WriteGroupRowDigits
    ld hl, $CC5A
    ld d, $00
.row:
    ld a, [hl+]
    and a
    jr nz, .next_row
    push hl
    push de
    ld b, d
    ld c, INDEXED_ROW_BYTES
    call MulCByB
    ld bc, INDEXED_MAP_ROW
    add hl, bc
    ld c, INDEXED_MAP_FILL
    ld a, $80
.fill:
    ld [hl+], a
    dec c
    jr nz, .fill
    pop de
    pop hl
.next_row:
    inc d
    ld a, INDEXED_ROW_COUNT
    cp d
    jr nz, .row
    ld a, $0D
    ld [$CD81], a
    ld hl, IndexedFar4274
    ld e, INDEXED_FAR_BANK
    call CallBankedHL
    jr .clear
.not0B:
    cp $05
    jr nz, .not05
    call DrawIndex5Tail
    jr .clear
.not05:
    cp $08
    jr nz, .not08
    call DrawIndexedSlots
    jr .clear
.not08:
    cp $09
    jr nz, .not08
    call DrawIndex9Map
.clear:
    xor a
    ld [$CC4B], a
    ret
