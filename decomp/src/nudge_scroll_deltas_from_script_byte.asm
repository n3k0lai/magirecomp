; Script step at $1D2A. H receives the camera edge flags at $C842 and L
; is set to 2, one count for each axis. D receives the script byte at
; BC. BC is left where it is. ROM bank 1 is stored to wCurrentROMBank
; and rROMB0, then this tails into $4587 in that bank.
;
; $4587 compares hFFA6 with the map column at $C85F and hFFA7 with the
; map row at $C860. A match, or an edge bit that blocks the step,
; decrements L and skips that axis. Otherwise D, or its negation, is
; added into the pixel delta at $C843 or $C844. L landing on 0 advances
; BC and plants the initial script handler. The edge bits themselves
; are still only partly known from the scroll steps.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm.

NudgeScrollDeltasFromScriptByte::
    ld a, [$C842]
    ld h, a
    ld l, $02
    ld a, [bc]
    ld d, a
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp NudgeCameraDeltas
