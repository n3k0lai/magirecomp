; Bank 4 at $6346. Opcode25Bank4 calls this after ClearMapScrollBytes,
; with $C9BB already zero.
;
; The LCD is turned off and the timer is armed. While $C9BB is zero, the
; WRAM bank is saved, bank 6 copies the $8E00 tiles, and three routines in
; this bank run ($628F, $6277, $624E). Those three are still INCBIN. The
; saved bank is written back with the 3-byte form. A nonzero $C9BB skips
; that block and continues here.
;
; Bank 1 builds the pointer list. The shadow-OAM cursors are cleared, every
; sprite is parked, and $31D5, WriteQuadRecords, and RunScriptRecord run.
; $31D5 is still INCBIN. WRAM bank 7 is then selected. $D391, the second
; opcode $25 operand, is turned into a word index as (byte - $59) * 2.
; The word is read from the table at $61C3 in this bank and passed to
; $2FC0 in BC. That call and the table are still INCBIN. The saved WRAM
; bank is restored.
;
; The LCD is turned on if it is off. $C9AF and $C9B0, cleared by
; ClearMapScrollBytes, are copied to the camera and to rSCX and rSCY.
; IdleCallback is stored at wCallback and EmptyStatHandler at hSTATHandler.
; The STAT stores are the 3-byte form.
;
; TurnOffLCD, SetTimerModulo, ParkSprites, WriteQuadRecords,
; RunScriptRecord, and TurnOnLCDIfOff are the labels in bank 0.
; CallBankedHL is the name from call_hl_in_bank.asm. CopyVRAMBank1Tiles is
; the bank 6 routine at $5EFB. InitPointerList is bank 1 at $40D3.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wShadowOAMCursor and wShadowOAMPrevEnd are the names from
; hide_leftover_sprites.asm. wCameraPixelX and wCameraPixelY are the names
; from queue_sprite_list.asm. wCallback, IdleCallback, and EmptyStatHandler
; are the names from default_state.asm. hSTATHandler is the name from
; lcd_stat.asm.

DEF rSCX EQU $FF43
DEF rSCY EQU $FF42

; Second operand of opcode $25, read from WRAM bank 7.
DEF wOpcode25Second EQU $D391

; Scroll bytes copied into the camera. Cleared by ClearMapScrollBytes.
DEF wScrollX EQU $C9AF
DEF wScrollY EQU $C9B0

LcdOffSetup::
    call TurnOffLCD
    call SetTimerModulo
    ld a, [$C9BB]
    and a
    jr nz, .after_tiles

    ld a, [wCurrentWRAMBank]
    push af
    ld hl, CopyVRAMBank1Tiles
    ld e, $06
    call CallBankedHL
    call CopyC7ABToCC02
    call CopyVRAM8000ToWRAM6
    call CopyVRAM9000ToWRAM4
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a

.after_tiles:
    ld hl, InitPointerList
    ld e, $01
    call CallBankedHL
    ld a, $00
    ld [wShadowOAMCursor], a
    ld [wShadowOAMPrevEnd], a
    call ParkSprites
    call LoadMapPanels
    call WriteQuadRecords
    call RunScriptRecord
    ld a, [wCurrentWRAMBank]
    push af
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wOpcode25Second]
    sub $59
    add a
    ld c, a
    ld b, $00
    ld hl, Opcode25MapListTable
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld b, h
    ld c, l
    call CopyMapRecords
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    call TurnOnLCDIfOff
    ld a, [wScrollX]
    ld [wCameraPixelX], a
    ldh [rSCX], a
    ld a, [wScrollY]
    ld [wCameraPixelY], a
    ldh [rSCY], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ld a, LOW(EmptyStatHandler)
    ld [hSTATHandler], a
    ld a, HIGH(EmptyStatHandler)
    ld [hSTATHandler + 1], a
    ret
