; Bank 0 at $314F. LoadMapPanels calls this after StageMapPanelSources.
;
; The current ROM bank is saved. Bank $04 is mapped and $7016 runs. Bank $07
; is mapped and $5CB9 runs. Bank $04 is mapped again. $2EB6, still INCBIN, is
; called with BC = $4030, HL = $C72B, E = $1C, and A = $04. $C9D8 is set to
; $61. Bank $07 is mapped and $481E runs, the same call StageMapPanelSources
; makes after a different $C9D8 value.
;
; VRAM bank 0 is selected with the 3-byte store. Bank $43 is mapped. CopyBytes
; copies $0300 bytes from $619D to $9000. VRAM bank 1 is selected the same
; way. Bank $43 stays mapped. $2D2C, still INCBIN, is called with HL = $9800,
; E = $14, D = $0D, and BC = $5F95. The saved bank is written back, then bank
; $04 is stored over it and $65CF runs.
;
; $315E, $31B0, $31C3, and $31CE are also entries. $315E skips the save and
; the $7016 call. $31B0 expects the bank number in A and starts at the
; rROMB0 store before $2D2C. $31C3 writes A as the restored bank, then forces
; bank $04. $31CE maps A through rROMB0 and calls $65CF.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. wUnknownC9D8 is
; the name from indexed_tail_07.asm. rVBK and CopyBytes are the names from
; setup_window.asm. $C72B is still unnamed. What $2EB6 does with those four
; arguments is still unknown.

; Bank 0, still INCBIN. HL, E, D, and BC are the values above.
DEF Call_2D2C EQU $2D2C

; Bank $04 is mapped again. CPU address in that bank.
DEF Call_Bank4_65CF EQU $65CF

FillMapPanelTiles::
    ld a, [wCurrentROMBank]
    push af
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StoreIndexedPtrPlus11

MapBank7AndCall5CB9::
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call WritePanelWordThenZero
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld bc, $4030
    ld hl, $C72B
    ld e, $1C
    ld a, $04
    call Call_2EB6
    ld a, $61
    ld [wUnknownC9D8], a
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank7_481E
    xor a
    ld [rVBK], a
    ld a, $43
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, $619D
    ld de, $9000
    ld bc, $0300
    call CopyBytes
    ld a, $01
    ld [rVBK], a
    ld a, $43
    ld [wCurrentROMBank], a

CopyPanelMapFrom5F95::
    ld [rROMB0], a
    ld hl, $9800
    ld a, $14
    ld e, a
    ld a, $0D
    ld d, a
    ld bc, $5F95
    call Call_2D2C
    pop af

RestoreBankThenForce04::
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, $04
    ld [wCurrentROMBank], a

MapBankAndCall65CF::
    ld [rROMB0], a
    call Call_Bank4_65CF
    ret
