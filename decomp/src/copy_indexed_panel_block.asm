; Bank 0 at $323F. ApplyC9B3Bytes calls here after each bank 4 $6542.
;
; The mapped bank is pushed. Bank 4 is mapped and $648D runs. $3250 is
; another entry: A is stored as the ROM bank, then $6542 runs. From $323F,
; A is 4. The bank in wUnknownC6E6 is mapped. The byte at wUnknownC6E9+2
; is stored to rVBK with the 3-byte form. $0140 bytes are copied from the
; word at wUnknownC6E6+1 to the word at wUnknownC6E9. [$C9D9] is stored
; at $C9B2.
;
; $3286 is another entry. A is mapped, then $32DF runs. Bank 7 is mapped
; and $445F runs. The pushed bank is restored. $3250 and $3286 do not
; push; the pop belongs to the push at $323F.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. rVBK is the
; name from setup_window.asm. CopyHLToDE is the name from copy_bytes.asm.
; wUnknownC6E6 and wUnknownC6E9 are the names from indexed_tail_07.asm.
; Call_Bank4_6542 is the name from apply_c9b3_bytes.asm. $648D, $32DF,
; and $445F are still INCBIN. What $6542 writes into the $C6E6 block is
; still unknown.

; Index copied into $C9B2 before $3286. ApplyC9B3Bytes stores 0-7 here.
DEF wUnknownC9D9 EQU $C9D9

; Receives [$C9D9]. $32DF reads this byte. Its other uses are still unknown.
DEF wUnknownC9B2 EQU $C9B2

; Still INCBIN. Bank 4 is mapped before this call.
DEF Call_Bank4_648D EQU $648D

; Still INCBIN. Bank 7 is mapped before this call.
DEF Call_Bank7_445F EQU $445F

DEF PANEL_BLOCK_LEN EQU $0140

CopyIndexedPanelBlock::
    ld a, [wCurrentROMBank]
    push af
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_648D
    ld a, $04

CopyIndexedPanelFromBank::
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542
    ld a, [wUnknownC6E6]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wUnknownC6E9 + 2]
    ld [rVBK], a
    ld a, [wUnknownC6E6 + 2]
    ld h, a
    ld a, [wUnknownC6E6 + 1]
    ld l, a
    ld a, [wUnknownC6E9 + 1]
    ld d, a
    ld a, [wUnknownC6E9]
    ld e, a
    ld bc, PANEL_BLOCK_LEN
    call CopyHLToDE
    ld a, [wUnknownC9D9]
    ld [wUnknownC9B2], a
    ld a, $00

DispatchPanelIndexInBank::
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call RunIndexedPanelRoutine
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank7_445F
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
