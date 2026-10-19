; Bank 0 at $3056. LoadMapPanels calls this after the eight panel copies.
;
; Each of the eight bytes at $C9B3-$C9BA is stored in wUnknownC9D8, and the
; index 0 through 7 is stored at $C9D9. Bank $04 is written to
; wCurrentROMBank and rROMB0, then $6542 in that bank runs, then $323F.
; The eight passes are separate copies. The return is at $311F.
;
; $305E, $3082, $30D0, and $30FC are also entries. $305E is the index store
; of pass 0, after `ld a, $00`. $3082 is the $6542 call of pass 1. $30D0 is
; the $323F call of pass 4. $30FC is the rROMB0 store of pass 6. What reaches
; those four addresses is still unknown.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. wUnknownC9D8 is
; the name from indexed_tail_07.asm. $C9D9 and $C9B3-$C9BA are still unnamed.
; ClearMapScrollBytes fills $C9B3-$C9BA with $F0. What $6542 and $323F do
; with wUnknownC9D8 and $C9D9 is still unknown.

; Still INCBIN in bank $04. Each pass maps that bank first.
DEF Call_Bank4_6542 EQU $6542

ApplyC9B3Bytes::
    ld a, [$C9B3]
    ld [wUnknownC9D8], a
    ld a, $00

ApplyC9B3From305E::
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ld a, [$C9B4]
    ld [wUnknownC9D8], a
    ld a, $01
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a

ApplyC9B3From3082::
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ld a, [$C9B5]
    ld [wUnknownC9D8], a
    ld a, $02
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ld a, [$C9B6]
    ld [wUnknownC9D8], a
    ld a, $03
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ld a, [$C9B7]
    ld [wUnknownC9D8], a
    ld a, $04
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542

ApplyC9B3From30D0::
    call CopyIndexedPanelBlock
    ld a, [$C9B8]
    ld [wUnknownC9D8], a
    ld a, $05
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ld a, [$C9B9]
    ld [wUnknownC9D8], a
    ld a, $06
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a

ApplyC9B3From30FC::
    ld [rROMB0], a
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ld a, [$C9BA]
    ld [wUnknownC9D8], a
    ld a, $07
    ld [$C9D9], a
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank4_6542
    call CopyIndexedPanelBlock
    ret
