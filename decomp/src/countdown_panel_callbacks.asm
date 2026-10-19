; Bank 4 at $61EB. ContinueAfterC71BPlant and the slot walk at bank 2
; $4344 reach this through CallBankedHL after storing $F0 at $C9D8 and
; the panel index minus one at $C9D9.
;
; The current ROM bank at wCurrentROMBank is saved. $648D in this bank
; runs, then $C9D3 is set to $15 by loading $14 and incrementing. Bank 4
; at $6542 runs through CallBankedHL. Both of those routines are still
; INCBIN.
;
; The index at wUnknownC9D9 is copied to wUnknownC9B2. wCallback becomes
; RunIndexedPanelRoutine ($32DF). $C9D3 is $15, so it is not yet $14:
; it is stored as $14 and FinishFrame runs once, then the compare stops.
; $C9D3 is incremented back to $15. wCallback becomes $2949. Each pass
; decrements $C9D3 and, until that decrement is zero, calls FinishFrame.
; That is fourteen frames, and $C9D3 is left at 1. wCallback then becomes
; IdleCallback ($29A4). The saved ROM bank is written back to
; wCurrentROMBank and rROMB0.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. wCallback and
; IdleCallback are the names from default_state.asm. wUnknownC9D9 and
; wUnknownC9B2 are the names from copy_indexed_panel_block.asm.
; RunIndexedPanelRoutine is the name from run_indexed_panel_routine.asm.
; CallBankedHL and FinishFrame are already source. $2949 is bank 0 only
; if the callback bank at $C6E6 is already 0; this routine does not
; write that bank.

; Call_Bank4_648D is the name from copy_indexed_panel_block.asm.
; Call_Bank4_6542 is the name from apply_c9b3_bytes.asm. Both are still
; INCBIN. CallBankedHL maps bank 4 before $6542. $648D is reached with
; rROMB0 left alone.

; Planted at wCallback for the fourteen-frame stretch. Its bank is the
; value already at wCallbackBank.
DEF Callback2949 EQU $2949

; Frame counter for the two callback stretches. $C9D3 is also the entry
; row pointer in other routines.
DEF wPanelFrameCount EQU $C9D3

CountdownPanelCallbacks::
    ld a, [wCurrentROMBank]
    push af
    call Call_Bank4_648D
    ld a, $14
    inc a
    ld [wPanelFrameCount], a
    ld hl, Call_Bank4_6542
    ld e, $04
    call CallBankedHL
.plantPanelRoutine:
    ld a, [wUnknownC9D9]
    ld [wUnknownC9B2], a
    ld a, LOW(RunIndexedPanelRoutine)
    ld [wCallback], a
    ld a, HIGH(RunIndexedPanelRoutine)
    ld [wCallback + 1], a
    ld a, [wPanelFrameCount]
    cp $14
    jr z, .raiseCount
    dec a
    ld [wPanelFrameCount], a
    call FinishFrame
    jr .plantPanelRoutine
.raiseCount:
    inc a
    ld [wPanelFrameCount], a
.plant2949:
    ld a, LOW(Callback2949)
    ld [wCallback], a
    ld a, HIGH(Callback2949)
    ld [wCallback + 1], a
    ld a, [wPanelFrameCount]
    dec a
    jr z, .plantIdle
    ld [wPanelFrameCount], a
    call FinishFrame
    jr .plant2949
.plantIdle:
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
