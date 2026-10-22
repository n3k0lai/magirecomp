; sub_0C0AE9: 27 bytes, model-proposed instructions, bank $30 (AGENTS.md W1).
; Reached from: no lifted reference yet
; Proposal evidence: Df33BitMasks ends at $4AE8 ($E6 is not a mask). This routine masks A to 0–7, indexes that table, and clears the matching bit in $DF33, returning Z/A=0 if it was already clear and A=1 if it cleared it. It falls through no calls and ends on RET at $4B03, immediately before SoundCommandBranchIfPeriodAt
; Name and comments wait for a naming pass (AGENTS.md S4).

sub_0C0AE9::
    and $07
    ld e, a
    ld d, $00
    ld hl, Df33BitMasks
    add hl, de
    ld a, [$DF33]
    ld e, a
    and [hl]
    ret z
    ld a, [hl]
    cpl
    ld d, a
    ld a, e
    and d
    ld [$DF33], a
    ld a, $01
    and a
    ret
