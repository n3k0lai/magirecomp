; Bank 4 at $715B. StepScriptPairCountdown calls this after copying
; the pair's second byte to $C9E9. Bank 4 is already mapped. This
; routine does not write rROMB0 and does not call out.
;
; $C9EA is the first of the three script bytes ScriptHandler1126 stored.
; When it is 0, $C9BC moves down by $C9E9 and a borrow becomes 0. When
; $C9BC is already 0 that path returns and leaves BC alone. When $C9EA
; is nonzero, $C9BC moves up by $C9E9 and a sum that is not below $60
; becomes $60. When $C9BC is already $60 that path returns and leaves
; BC alone. Either change saves BC, writes the clamped byte back to
; $C9BC, and restores BC.
;
; The downward step is two's complement: cpl / inc a / add. Carry means
; the difference stayed nonnegative. ApplyC9BCScrollThenFrame later
; masks $C9BC and copies it to wCameraPixelX. What $C9EA means besides
; which way the step goes is still unknown. $C9E9 is SCRIPT_PAIR_VALUE
; in step_script_pair_countdown.asm. wCameraPixelX is the name from
; queue_sprite_list.asm.

; Scroll byte later masked into wCameraPixelX.
DEF SCRIPT_SCROLL EQU $C9BC

; First script byte. Zero steps the scroll down; nonzero steps it up.
DEF SCRIPT_SCROLL_DIR EQU $C9EA

; Pair step stored by StepScriptPairCountdown.
DEF SCRIPT_PAIR_STEP EQU $C9E9

; Upper clamp for an upward step.
DEF SCRIPT_SCROLL_CAP EQU $60

StepScrollByScriptPair::
    ld a, [SCRIPT_SCROLL_DIR]
    and a
    jr nz, .increase
    ld a, [SCRIPT_SCROLL]
    and a
    ret z
    push bc
    ld c, a
    ld a, [SCRIPT_PAIR_STEP]
    cpl
    inc a
    add c
    jr c, .store
    xor a
    jp .store

.increase::
    ld a, [SCRIPT_SCROLL]
    cp SCRIPT_SCROLL_CAP
    ret z
    push bc
    ld c, a
    ld a, [SCRIPT_PAIR_STEP]
    add c
    cp SCRIPT_SCROLL_CAP
    jr c, .store
    ld a, SCRIPT_SCROLL_CAP

.store::
    ld [SCRIPT_SCROLL], a
    pop bc
    ret
