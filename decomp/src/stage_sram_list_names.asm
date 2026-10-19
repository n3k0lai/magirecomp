; Bank 3 at $70D4. StageSramListArmSlot calls this after the SRAM list
; count at $A122 has been stored in $CCCC and SRAM has been disabled.
; This routine does not write rROMB0. The calls below stay in this bank.
;
; $71AA fills $CCCD with up to eight SRAM ids, using $FF for the rest.
; $CCE6 then points at the ten-byte name table at $5AA6, and both $CCE8
; and $CCEA are set to $0A. TurnOffLCD runs, then $7103 walks those ids.
; $77F3 is called with BC = $5320 and A = $10. $7393 and $7415 run,
; TurnOnLCDIfOff turns the LCD back on, and $7213 walks the eight bytes
; at $CCCD. Control returns to the caller.
;
; $71AA, $7103, $7393, $7415, and $7213 are still INCBIN. $77F3 is still
; INCBIN and is already listed. TurnOffLCD and TurnOnLCDIfOff are source.
; IndexedNameTable in copy_indexed_name.asm is the same $5AA6 word; that
; file is included later, so the address is written here.

; Still INCBIN in this bank.
DEF Bank3_7213 EQU $7213

; Ten-byte name records. Record 0 is id 0.
DEF NameTable5AA6 EQU $5AA6

; Length stored at the stride $CCE8 and at $CCEA.
DEF NAME_STRIDE_0A EQU $0A

; Tile-copy source passed to $77F3.
DEF TILE_SRC_5320 EQU $5320

; Count passed to $77F3 in A.
DEF TILE_COUNT_10 EQU $10

; Base word for the name records. Low byte is $CCE6.
DEF NAME_BASE_CCE6 EQU $CCE6

StageSramListNames::
    call FillSramListIds
    ld bc, NameTable5AA6
    ld hl, NAME_BASE_CCE6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, NAME_STRIDE_0A
    ld [$CCE8], a
    ld [$CCEA], a
    call TurnOffLCD
    call StageSramNameTiles
    ld bc, TILE_SRC_5320
    ld a, TILE_COUNT_10
    call CopyFixedThenCallerTiles
    call PaintSramListRecordBytes
    call PaintSramListMarks
    call TurnOnLCDIfOff
    call Bank3_7213
    ret
