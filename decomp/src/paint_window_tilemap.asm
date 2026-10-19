; Bank 3 at $56FA. Called after $CCA7 is set to $FF while staging the
; window tiles. [$CD54] is set to 1. CallBankedHL maps bank 4 and runs
; $557A, then restores the bank. rVBK is cleared with the 3-byte form,
; so the stores below hit the tile map in VRAM bank 0.
;
; Tile $91 is written at $9C29, $9C2A, $9D69, and $9D6A. $65D2 stores C
; ascending indexes at HL, stepping by DE and leaving HL and A one past
; the run. The first call writes $92, $93, and $94 at $9C4D. $95 is then
; stored at $9C51, skipping $9C50.
;
; Seven more runs start at $97. Each pass adds $16 to HL before writing
; ten tiles, so the first cell is $9C63. The writer advances HL by $0A,
; and $16 + $0A is one 32-byte map row, so the next pass begins on the
; row below. The index keeps rising across those seven rows. B is the
; row count. It is saved around the call because C is the run length.
; On return B is 0 and the last run has ended.
;
; $557A and $65D2 are still INCBIN. [$CD54] is still unnamed beyond this
; flag. rVBK is the name from setup_window.asm. CallBankedHL is the name
; from call_hl_in_bank.asm. The $9C00 map is the window map named in
; setup_window.asm.

; Set to 1 before the bank 4 call. Its other readers are still unknown.
DEF wWindowFlagCD54 EQU $CD54
DEF WINDOW_FLAG_CD54 EQU $01

DEF Bank4_557A EQU $557A
DEF BANK4_557A EQU $04

; Same bank. Writes C ascending bytes at HL with stride DE.
DEF WriteAscendingStride EQU $65D2

DEF WINDOW_CORNER_TILE EQU $91
DEF WINDOW_RUN_TILE EQU $92
DEF WINDOW_SKIP_TILE EQU $95
DEF WINDOW_BLOCK_TILE EQU $97
DEF WINDOW_RUN_LEN EQU $03
DEF WINDOW_BLOCK_LEN EQU $0A
DEF WINDOW_BLOCK_ROWS EQU $07
; $16 before a $0A run lands the next row $20 bytes later.
DEF WINDOW_ROW_BIAS EQU $0016
DEF WINDOW_STRIDE EQU $0001

DEF WINDOW_CELL_9C29 EQU $9C29
DEF WINDOW_CELL_9C2A EQU $9C2A
DEF WINDOW_CELL_9D69 EQU $9D69
DEF WINDOW_CELL_9D6A EQU $9D6A
DEF WINDOW_CELL_9C4D EQU $9C4D
DEF WINDOW_CELL_9C51 EQU $9C51

PaintWindowTilemap::
    ld a, WINDOW_FLAG_CD54
    ld [wWindowFlagCD54], a
    ld hl, Bank4_557A
    ld e, BANK4_557A
    call CallBankedHL
    xor a
    ld [rVBK], a
    ld a, WINDOW_CORNER_TILE
    ld [WINDOW_CELL_9C29], a
    ld [WINDOW_CELL_9C2A], a
    ld [WINDOW_CELL_9D69], a
    ld [WINDOW_CELL_9D6A], a
    ld a, WINDOW_RUN_TILE
    ld hl, WINDOW_CELL_9C4D
    ld de, WINDOW_STRIDE
    ld c, WINDOW_RUN_LEN
    call WriteAscendingStride
    ld a, WINDOW_SKIP_TILE
    ld [WINDOW_CELL_9C51], a
    ld a, WINDOW_BLOCK_TILE
    ld hl, WINDOW_CELL_9C4D
    ld de, WINDOW_STRIDE
    ld b, WINDOW_BLOCK_ROWS
.row
    push bc
    ld bc, WINDOW_ROW_BIAS
    add hl, bc
    pop bc
    ld c, WINDOW_BLOCK_LEN
    call WriteAscendingStride
    dec b
    jr nz, .row
    ret
