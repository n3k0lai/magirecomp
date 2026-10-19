; Bank 3 at $50D0. Called after bank 3 is stored to wCurrentROMBank and rROMB0.
;
; $7463 runs first. BC is then $4CB3 for $76FA. The block destination at
; $CC45 is $8860, and $772F runs with A = $68. The block source at $CC43
; is $52F2 and the count at $CC42 is $10. CallBankedHL maps bank 6 and
; runs CopyIndexedBlocks, which copies those sixteen 16-byte blocks into
; VRAM bank 1 at $8860, then restores this bank.
;
; $CCB4 is $08, the index LoadArmedSlotRecord uses at the $4524 table.
; $CCA9 is $F3. The WRAM bank in $C937 is copied to $CCB8. $CCB6 points
; at $CCD6, $CCB0 holds $6B77, and $CCB2 holds $42E3. $CD81 is read and
; stored back to itself. $CCB9 is 1 and $CCBA is 0, so LoadArmedSlotRecord
; returns before ReloadSlotPosition. CallBankedHL maps bank 3 and runs
; that routine. $CCA7 is then $FF. TurnOnLCDIfOff and RefreshFrame run.
; $CCE3 is 3 and $CCEB is $F9. Control leaves through $4F83.
;
; $7463, $76FA, $772F, and $4F83 are still INCBIN. wCurrentWRAMBank is
; the name from timer_overflow.asm. CallBankedHL, CopyIndexedBlocks,
; LoadArmedSlotRecord, TurnOnLCDIfOff, and RefreshFrame are already source.
; $CC42, $CC43, and $CC45 are named in handle_start_press.asm, which is
; included later, so this file uses the addresses.

; Still INCBIN in this bank.
DEF Bank3_772F EQU $772F

DEF TILE_DEST_8860 EQU $8860
DEF TILE_SRC_52F2 EQU $52F2
DEF TILE_BLOCK_COUNT EQU $10
DEF TILE_CALL_A EQU $68
DEF BANK6_COPY EQU $06
DEF SLOT_TABLE_INDEX EQU $08
DEF SLOT_MARK_F3 EQU $F3
DEF SLOT_PTR_CCD6 EQU $CCD6
DEF SLOT_WORD_6B77 EQU $6B77
DEF SLOT_WORD_42E3 EQU $42E3
DEF SLOT_FLAG_ONE EQU $01
DEF CHOICE_WAIT EQU $FF
DEF BANK3_ARMED EQU $03
DEF CCE3_VALUE EQU $03
DEF CCEB_VALUE EQU $F9

StageTilesArmSlot::
    call PaintMapAttrsSeedSlot
    ld bc, $4CB3
    call PlaceWindowCopyMap
    ld de, TILE_DEST_8860
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld a, TILE_CALL_A
    call Bank3_772F
    ld bc, TILE_SRC_52F2
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, TILE_BLOCK_COUNT
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, BANK6_COPY
    call CallBankedHL
    ld a, SLOT_TABLE_INDEX
    ld [$CCB4], a
    ld a, SLOT_MARK_F3
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, SLOT_PTR_CCD6
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_6B77
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_42E3
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$CD81]
    ld [$CD81], a
    ld a, SLOT_FLAG_ONE
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, BANK3_ARMED
    call CallBankedHL
    ld a, CHOICE_WAIT
    ld [$CCA7], a
    call TurnOnLCDIfOff
    call RefreshFrame
    ld a, CCE3_VALUE
    ld [$CCE3], a
    ld a, CCEB_VALUE
    ld [$CCEB], a
    jp DispatchArmedChoice

StageTilesArmSlotEnd:
