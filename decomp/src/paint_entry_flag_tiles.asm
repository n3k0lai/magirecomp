; Bank 0 at $3931. PaintEntryDigitsAndChoose stores this address at
; wCallback, then FinishFrame runs it once before the entry-digit choice
; wait.
;
; VRAM bank 0 is selected with the 3-byte form. The WRAM bank at
; wCurrentWRAMBank is saved, then bank 7 is stored there and selected
; with ldh [rSVBK]. [$D0A0] nonzero writes tile $0D at $9C60; zero writes
; $80. VRAM bank 1, again the 3-byte form, writes attribute $4F on that
; same cell. VRAM bank 0 is restored. [$D0A1] picks $0D or $80 the same
; way at $9C73. The saved WRAM bank is written back to wCurrentWRAMBank
; and to rSVBK with the 3-byte form. wCallback becomes IdleCallback.
;
; The push at $3938 is also an entry: A is already the bank to restore.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm. wEntryA11DPlus1 is the name
; from load_five_sram_entry_digits.asm. The window map at $9C00 is
; vBGMap in draw_start_screen_map.asm. wCallback and IdleCallback are
; the names from default_state.asm.

; Tile when the flag byte is nonzero, and the blank when it is zero.
DEF ENTRY_FLAG_TILE EQU $0D
DEF ENTRY_FLAG_BLANK EQU $80

; Attribute written on the first cell in VRAM bank 1.
DEF ENTRY_FLAG_ATTR EQU $4F

; Cleared beside wEntryA11DPlus1. What sets it again is still unknown.
DEF wEntryA11DNext EQU $D0A1

; Window-map cells on the $9C00 map. $9C60 is row 3 column 0.
; $9C73 is row 3 column $13.
DEF vEntryFlagLeft EQU $9C60
DEF vEntryFlagRight EQU $9C73

DEF WRAM_BANK_ENTRY_FLAGS EQU $07

PaintEntryFlagTiles::
    xor a
    ld [rVBK], a
    ld a, [wCurrentWRAMBank]

PaintEntryFlagTilesFromA::
    push af
    ld a, WRAM_BANK_ENTRY_FLAGS
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wEntryA11DPlus1]
    and a
    jr z, .blankLeft
    ld a, ENTRY_FLAG_TILE
    jr .writeLeft

.blankLeft:
    ld a, ENTRY_FLAG_BLANK

.writeLeft:
    ld hl, vEntryFlagLeft
    ld [hl], a
    ld a, $01
    ld [rVBK], a
    ld a, ENTRY_FLAG_ATTR
    ld [hl], a
    xor a
    ld [rVBK], a
    ld a, [wEntryA11DNext]
    and a
    jr z, .blankRight
    ld a, ENTRY_FLAG_TILE
    jr .writeRight

.blankRight:
    ld a, ENTRY_FLAG_BLANK

.writeRight:
    ld hl, vEntryFlagRight
    ld [hl], a
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
