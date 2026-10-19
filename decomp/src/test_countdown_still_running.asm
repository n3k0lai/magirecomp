; SoundCountdownIdle calls this with bank $30 already mapped.
; Returns 1 when the low nibble of wCountdownFlags ($DFA6) is set
; or any bit of $DFD3 is set, and returns 0 otherwise. A nonzero
; result skips the idle restore of the countdown snapshot.

TestCountdownStillRunning::
    ld a, [wCountdownFlags]
    and $0f
    jr nz, .running
    ld a, [$DFD3]
    and a
    jr nz, .running
    xor a
    ret

.running:
    ld a, $01
    ret
