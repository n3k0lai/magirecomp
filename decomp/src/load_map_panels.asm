; Bank 0 at $31D5. LcdOffSetup calls this after ParkSprites.
;
; The current ROM bank is saved. $311F and $314F, both still INCBIN, run
; first. ROM bank $42 is then mapped. The `ld a, a` after `ld a, $42`
; leaves A holding $42. Eight calls to $304E pass a BG-map address in HL
; and a source address in bank $42 in BC. Those sources start at $4000 and
; step by $28. $304E sets E to $04 and D to $05, then calls $2D2C.
; $3056, still INCBIN, runs next and reads the eight bytes at $C9B3.
; rWX is set to $A7, which places the window at screen X 160. The saved
; ROM bank is written back with the 3-byte stores.
;
; $31D9, $31E5, $3200, $3203, and $3233 are also entries. $31D9 skips the
; push. $31E5 starts at the bank $42 map. $3200 is the third $304E call.
; $3203 is the fourth. $3233 is the window store and the bank restore.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. rWX is the name
; from setup_window.asm.

; ROM bank mapped for the eight panel sources.
DEF MAP_PANEL_BANK EQU $42

LoadMapPanels::
    ld a, [wCurrentROMBank]
    push af

LoadMapPanelsFrom311F::
    call StageMapPanelSources
    call FillMapPanelTiles
    ld a, MAP_PANEL_BANK
    ld a, a
    ld [wCurrentROMBank], a

MapBank42AndCopyPanels::
    ld [rROMB0], a
    ld hl, $98E0
    ld bc, $4000
    call CopyOneMapPanel
    ld hl, $98C5
    ld bc, $4028
    call CopyOneMapPanel
    ld hl, $98CB
    ld bc, $4050

CopyPanelFrom4050::
    call CopyOneMapPanel

CopyPanelsFrom4078::
    ld hl, $98F0
    ld bc, $4078
    call CopyOneMapPanel
    ld hl, $9800
    ld bc, $40A0
    call CopyOneMapPanel
    ld hl, $9805
    ld bc, $40C8
    call CopyOneMapPanel
    ld hl, $980B
    ld bc, $40F0
    call CopyOneMapPanel
    ld hl, $9810
    ld bc, $4118
    call CopyOneMapPanel
    call ApplyC9B3Bytes

HideWindowRestoreBank::
    ld a, $A7
    ldh [rWX], a
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
