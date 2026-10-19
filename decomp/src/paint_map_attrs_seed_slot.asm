; Bank 3 at $7463. StageTilesArmSlot calls this before it arms the slot.
;
; The LCD is turned off, then VRAM bank 1 is selected. $234 bytes from
; $9C00 through $9E33, the second background map, are filled with attribute
; $0F: palette 7 and tile data from VRAM bank 1. $12 bytes at $9E21 are
; then $4F, which adds a vertical flip. Rows 1 through 16 of that map get
; $2F in column 0 (a horizontal flip). The row index is shifted left five
; times, which is a multiply by 32. $9C00, $9C2A, and $9DA0 are stamped
; $2F, $9E33 and $9D89 are stamped $4F, and $9E20 and $9D8A are stamped
; $6F (both flips).
;
; The window is pulled on screen: Y is 0 and X is 7, the left edge.
; CopyVRAMBank1Tiles runs in bank 6, then CopyVRAM9000ToWRAM4 runs in
; bank 4. $CD81, the slot index, is cleared. The record at $CCD6, the one
; StageTilesArmSlot later points $CCB6 at, is planted as three $01 bytes,
; ten $00 bytes, and a final $01 that is immediately overwritten so $CCE3
; is 0. A is 0 on return.
;
; The rVBK store is the 3-byte form. rVBK, wWindowX, and wWindowY are the
; names from setup_window.asm. TurnOffLCD and CallBankedHL are already
; source. CopyVRAMBank1Tiles and CopyVRAM9000ToWRAM4 are already source.

; Attribute bytes written into VRAM bank 1.
DEF SEED_ATTR_BANK1 EQU $0F
DEF SEED_ATTR_HFLIP EQU $2F
DEF SEED_ATTR_VFLIP EQU $4F
DEF SEED_ATTR_BOTH EQU $6F

; Second background map. $234 bytes covers $9C00 through $9E33.
DEF vAttrMap EQU $9C00
DEF vAttrFillBase EQU $9BFF
DEF ATTR_FILL_BYTES EQU $0234
DEF vAttr4FRun EQU $9E21
DEF ATTR_4F_COUNT EQU $12
DEF SEED_ROW_COUNT EQU $10
; Five shifts turn the row index into a 32-byte row offset.
DEF ATTR_ROW_SHIFTS EQU $05

DEF vSeed9C2A EQU $9C2A
DEF vSeed9DA0 EQU $9DA0
DEF vSeed9E33 EQU $9E33
DEF vSeed9D89 EQU $9D89
DEF vSeed9E20 EQU $9E20
DEF vSeed9D8A EQU $9D8A

; Slot index cleared here. StageTilesArmSlot reads it back later.
DEF wArmedSlotIndex EQU $CD81

; Record StageTilesArmSlot points $CCB6 at. $CCE3 is cleared last.
DEF wArmedSlotRecord EQU $CCD6
DEF wArmedSlotCCE3 EQU $CCE3
DEF ARMED_SLOT_MARK EQU $01
DEF BANK_COPY_TILES EQU $06
DEF BANK_COPY_9000 EQU $04

PaintMapAttrsSeedSlot::
    call TurnOffLCD
    ld a, $01
    ld [rVBK], a
    ld d, SEED_ATTR_BANK1
    ld bc, ATTR_FILL_BYTES
.fill_attr:
    ld hl, vAttrFillBase
    add hl, bc
    ld [hl], d
    dec bc
    ld a, c
    or b
    jr nz, .fill_attr
    ld a, SEED_ATTR_VFLIP
    ld d, ATTR_4F_COUNT
    ld hl, vAttr4FRun
.stamp_4f:
    ld [hl+], a
    dec d
    jr nz, .stamp_4f
    ld bc, SEED_ROW_COUNT
.stamp_row:
    ld hl, vAttrMap
    push bc
    ld a, ATTR_ROW_SHIFTS
.shift_row:
    sla c
    rl b
    dec a
    jr nz, .shift_row
    add hl, bc
    ld a, SEED_ATTR_HFLIP
    ld [hl+], a
    pop bc
    dec c
    jr nz, .stamp_row
    ld a, SEED_ATTR_HFLIP
    ld [vAttrMap], a
    ld [vSeed9C2A], a
    ld [vSeed9DA0], a
    ld a, SEED_ATTR_VFLIP
    ld [vSeed9E33], a
    ld [vSeed9D89], a
    ld a, SEED_ATTR_BOTH
    ld [vSeed9E20], a
    ld [vSeed9D8A], a
    xor a
    ld [wWindowY], a
    ld a, WINDOW_X
    ld [wWindowX], a
    ld hl, CopyVRAMBank1Tiles
    ld e, BANK_COPY_TILES
    call CallBankedHL
    ld hl, CopyVRAM9000ToWRAM4
    ld e, BANK_COPY_9000
    call CallBankedHL
    xor a
    ld [wArmedSlotIndex], a
    ld hl, wArmedSlotRecord
    ld c, ARMED_SLOT_MARK
    ld [hl], c
    inc hl
    ld [hl], c
    inc hl
    ld [hl], c
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], c
    ld [wArmedSlotCCE3], a
    ret
