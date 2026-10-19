; Bank 0 at $32DF. DispatchPanelIndexInBank maps the bank in A, then
; calls here. That caller stores 0, so this entry runs in bank 0.
;
; rVBK is set to 1 with the 3-byte form. [$C9B2] selects a bank 4 routine.
; Values 0 through 6 call $660B plus the index times $88. Any other value
; calls the seventh routine at $69C3. Each arm stores bank 4 in
; wCurrentROMBank and rROMB0 before the call.
;
; $32FF, $3304, and $330A are entries inside the index-1 arm. $3304 maps
; the bank already in A and calls $6693. $330A jumps to the shared tail.
; That tail maps bank 7 and calls $445F. $3382 stores IdleCallback at
; wCallback. $3384 stores A as the low byte and $29 as the high byte.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. rVBK is the
; name from setup_window.asm. wUnknownC9B2 is the name from
; copy_indexed_panel_block.asm. wCallback and IdleCallback are the names
; from default_state.asm. The bank 4 routines and $445F are still INCBIN.

DEF PANEL_ROUTINE_BANK EQU $04
DEF PANEL_TAIL_BANK EQU $07
DEF PanelIndexRoutine EQU $660B
DEF PANEL_INDEX_STRIDE EQU $88

RunIndexedPanelRoutine::
    ld a, $01
    ld [rVBK], a
    ld a, [wUnknownC9B2]
    cp $00
    jp nz, PanelIndexNotZero

    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine
    jp PanelIndexFinish

PanelIndexNotZero:
    cp $01
    jp nz, PanelIndexNotOne

PanelIndex1::
    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a

MapBankAndCallPanelIndex1::
    ld [rROMB0], a
    call PanelIndexRoutine + PANEL_INDEX_STRIDE

JumpToPanelFinish::
    jp PanelIndexFinish

PanelIndexNotOne:
    cp $02
    jp nz, PanelIndexNotTwo

    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine + 2 * PANEL_INDEX_STRIDE
    jp PanelIndexFinish

PanelIndexNotTwo:
    cp $03
    jp nz, PanelIndexNotThree

    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine + 3 * PANEL_INDEX_STRIDE
    jp PanelIndexFinish

PanelIndexNotThree:
    cp $04
    jp nz, PanelIndexNotFour

    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine + 4 * PANEL_INDEX_STRIDE
    jp PanelIndexFinish

PanelIndexNotFour:
    cp $05
    jp nz, PanelIndexNotFive

    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine + 5 * PANEL_INDEX_STRIDE
    jp PanelIndexFinish

PanelIndexNotFive:
    cp $06
    jp nz, PanelIndexOther

    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine + 6 * PANEL_INDEX_STRIDE
    jp PanelIndexFinish

PanelIndexOther:
    ld a, PANEL_ROUTINE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PanelIndexRoutine + 7 * PANEL_INDEX_STRIDE

PanelIndexFinish:
    ld a, PANEL_TAIL_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Call_Bank7_445F

StoreIdleCallback::
    ld a, LOW(IdleCallback)

StoreCallbackHigh29::
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
