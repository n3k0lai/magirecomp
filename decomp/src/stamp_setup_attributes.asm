; Stamp BG-map attributes for the setup index in $CC47, with VRAM bank 1 selected.
;
; Called from AfterStartLoop while the LCD is off, after IndexedSetup, and
; only when $CC4B is 1. This bank stays mapped.
;
; Six cells are set to $0F (palette 7, tile data from VRAM bank 1). Indexes
; 3, 4, 6, and $0B then write $2F, $4F, and $6F (the same attribute with
; horizontal flip, vertical flip, and both) and fall into the index-7
; stores, which write that trio again at a second set of cells. Index 7
; does only the second set. Any other index returns.
;
; Index 9 copies eight rows of twelve attribute bytes from $6FAC in this
; bank onto the map at $9C44. Each row is $20 bytes apart: the copy advances
; twelve bytes, then adds $14. $CC89 holds the rows still to copy.
; SRAM bank $C727 is then selected. `add a, $00` keeps that bank byte and
; its flags; nothing reads them. Byte $A3A4 (sMapFlag) is compared after
; SRAM is disabled:
;   >= 2  writes $0F at $9CCA
;   >= 4  writes $0F at $9CEA
;   >= 5  writes $0F at $9D0A
;   == 6  calls $65FD with BC = $700C
; Those three cells are one map column, one row apart. A lower value returns.
;
; Index 5 jumps to DrawStartScreenAttrs. The 3-byte stores to rVBK and rRAMG
; match the ROM. rVBK is the name from setup_window.asm. rRAMG is the name
; from reset.asm. rRAMB, wSRAMBank, SRAM_ENABLE, and wUnknownCC47 are the
; names from handle_start_press.asm. sMapFlag and the $0F/$2F/$4F/$6F names
; are from draw_start_screen_map.asm.

; Indexes that share the first flip trio, then fall through.
DEF ATTR_INDEX_LO EQU $03
DEF ATTR_INDEX_04 EQU $04
DEF ATTR_INDEX_06 EQU $06
DEF ATTR_INDEX_0B EQU $0B
DEF ATTR_INDEX_07 EQU $07
DEF ATTR_INDEX_09 EQU $09
DEF ATTR_INDEX_05 EQU $05

; Cells written $0F before the index test. Roles still unknown.
DEF vAttr9C2A EQU $9C2A
DEF vAttr9D32 EQU $9D32
DEF vAttr9D29 EQU $9D29
DEF vAttr9D42 EQU $9D42
DEF vAttr9D2A EQU $9D2A
DEF vAttr9D52 EQU $9D52

; Second trio, used by index 7 and by the fall-through above.
DEF vAttr9D49 EQU $9D49
DEF vAttr9D4A EQU $9D4A

; Index 9 block copy. Source is still INCBIN in this bank.
DEF vAttrBlock EQU $9C44
DEF AttrBlockSrc EQU $6FAC
DEF ATTR_BLOCK_ROWS EQU $08
DEF ATTR_BLOCK_COLS EQU $0C
; $20 map stride minus the twelve bytes the column loop already advanced.
DEF ATTR_BLOCK_GAP EQU $14

; Row countdown. Role outside this copy is still unknown.
DEF wUnknownCC89 EQU $CC89

; Same column, successive rows. Written as sMapFlag crosses 2, 4, and 5.
DEF vAttr9CCA EQU $9CCA
DEF vAttr9CEA EQU $9CEA
DEF vAttr9D0A EQU $9D0A
DEF MAP_FLAG_MARK_2 EQU $02
DEF MAP_FLAG_MARK_4 EQU $04
DEF MAP_FLAG_MARK_5 EQU $05
DEF MAP_FLAG_CALL EQU $06

; Still INCBIN in this bank. BC is the pointer it is called with.
DEF Bank6_65FD EQU $65FD

StampSetupAttributes::
    ld a, $01
    ld [rVBK], a
    ld a, ATTR_FILL
    ld [vAttr9C2A], a
    ld [vAttr9D32], a
    ld [vAttr9D29], a
    ld [vAttr9D42], a
    ld [vAttr9D2A], a
    ld [vAttr9D52], a
    ld a, [wUnknownCC47]
    cp ATTR_INDEX_LO
    jr z, .flipFirst
    cp ATTR_INDEX_04
    jr z, .flipFirst
    cp ATTR_INDEX_06
    jr z, .flipFirst
    cp ATTR_INDEX_0B
    jr z, .flipFirst
    cp ATTR_INDEX_07
    jr z, .flipSecond
    cp ATTR_INDEX_09
    jr z, .copyBlock
    cp ATTR_INDEX_05
    jr z, .startScreen
    ret

.flipFirst:
    ld a, ATTR_ROW
    ld [vAttr9C2A], a
    ld a, ATTR_RUN
    ld [vAttr9D29], a
    ld a, ATTR_CORNER
    ld [vAttr9D2A], a

.flipSecond:
    ld a, ATTR_ROW
    ld [vAttr9C2A], a
    ld a, ATTR_RUN
    ld [vAttr9D49], a
    ld a, ATTR_CORNER
    ld [vAttr9D4A], a
    ret

.copyBlock:
    ld hl, vAttrBlock
    ld bc, AttrBlockSrc
    ld a, ATTR_BLOCK_ROWS
    ld [wUnknownCC89], a

.row:
    ld d, ATTR_BLOCK_COLS

.col:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .col

    ld a, [wUnknownCC89]
    dec a
    jr z, .readFlag

    ld [wUnknownCC89], a
    ld de, ATTR_BLOCK_GAP
    add hl, de
    jr .row

.readFlag:
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, [sMapFlag]
    ld b, a
    xor a
    ld [rRAMG], a
    ld a, b
    cp MAP_FLAG_MARK_2
    ret c

    ld a, ATTR_FILL
    ld [vAttr9CCA], a
    ld a, b
    cp MAP_FLAG_MARK_4
    ret c

    ld a, ATTR_FILL
    ld [vAttr9CEA], a
    ld a, b
    cp MAP_FLAG_MARK_5
    ret c

    ld a, ATTR_FILL
    ld [vAttr9D0A], a
    ld a, b
    cp MAP_FLAG_CALL
    ret nz

    ld bc, Index9AttrStrip
    call Bank6_65FD
    ret

.startScreen:
    jp DrawStartScreenAttrs
