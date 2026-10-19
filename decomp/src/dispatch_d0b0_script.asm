; Bank 2 at $5FDF. BeginD0D5Pass calls here after the first bank 5
; $57BA. $D0C0 is cleared, then $6110 runs. A nonzero [$D0D5] returns.
;
; WRAM bank 7 is selected. [$D0B0] picks the five-byte script written at
; $C71B. FinishFrame runs until wUnknownC6EE matches the value for that
; script. $0A also stores [$D0B1] with bit 7 clear into $D103, then both
; $0A and $0B return. Any other [$D0B0] continues.
;
; A zero [$D104] posts $02,$BA,$5C,$66,$0A and waits for wUnknownC6EE = 0,
; then calls bank 5 at $590B. A nonzero [$D104] calls bank 5 at $578B
; first, posts that same script, and waits. [$CCA7] = $FE with [$D0B1] = 0
; posts $02,$B8,$5C,$66,$0A, waits for wUnknownC6EE = 2, and starts over.
; Any other [$CCA7], or a nonzero [$D0B1] after $578B, takes the $590B
; path. A nonzero [$D0B1] there starts over as well.
;
; When [$CCA7] is not $FE after $590B, [$D103] >= $14 returns. Otherwise
; [$CCA7] is stored in $D103 and $D0C1 and bank 5 at $579D runs.
;
; wUnknownC6EE is the name from setup_window.asm. wCurrentWRAMBank and
; rSVBK are the names from timer_overflow.asm. FinishFrame and CallBankedHL
; are already source. $6110, $578B, $590B, and $579D are still INCBIN.

DispatchD0B0Script::
    xor a
    ld [$D0C0], a
    call $6110
    ld a, [$D0D5]
    and a
    ret nz
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D0B0]
    cp $0A
    jr nz, .notMark0A
    ld a, [$D0B1]
    res 7, a
    ld [$D103], a
    ld hl, $C71B
    ld a, $02
    ld [hl+], a
    ld a, $BA
    ld [hl+], a
    ld a, $5C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitZeroAfter0A:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .doneAfter0A
    call FinishFrame
    jr .waitZeroAfter0A
.doneAfter0A:
    ret
.notMark0A:
    cp $0B
    jr nz, .otherMark
    ld hl, $C71B
    ld a, $02
    ld [hl+], a
    ld a, $BA
    ld [hl+], a
    ld a, $5C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitZeroAfter0B:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .doneAfter0B
    call FinishFrame
    jr .waitZeroAfter0B
.doneAfter0B:
    ret
.otherMark:
    ld a, [$D104]
    and a
    jr nz, .d104Set
    ld hl, $C71B
    ld a, $02
    ld [hl+], a
    ld a, $BA
    ld [hl+], a
    ld a, $5C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitZeroNoD104:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .to590B
    call FinishFrame
    jr .waitZeroNoD104
.to590B:
    jr .call590B
.d104Set:
    ld hl, $578B
    ld e, $05
    call CallBankedHL
    ld hl, $C71B
    ld a, $02
    ld [hl+], a
    ld a, $BA
    ld [hl+], a
    ld a, $5C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitZeroD104:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .checkFeAfter578B
    call FinishFrame
    jr .waitZeroD104
.checkFeAfter578B:
    ld a, [$CCA7]
    cp $FE
    jr nz, .call590B
    ld a, [$D0B1]
    cp $00
    jp nz, DispatchD0B0Script
    ld hl, $C71B
    ld a, $02
    ld [hl+], a
    ld a, $B8
    ld [hl+], a
    ld a, $5C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitTwoAfter578B:
    ld a, [wUnknownC6EE]
    cp $02
    jr z, .restartAfter578B
    call FinishFrame
    jr .waitTwoAfter578B
.restartAfter578B:
    jp DispatchD0B0Script
.call590B:
    ld hl, $590B
    ld e, $05
    call CallBankedHL
    ld a, [$CCA7]
    cp $FE
    jp nz, .storeCca7
    ld a, [$D0B1]
    cp $00
    jp nz, DispatchD0B0Script
    ld hl, $C71B
    ld a, $02
    ld [hl+], a
    ld a, $B8
    ld [hl+], a
    ld a, $5C
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitTwoAfter590B:
    ld a, [wUnknownC6EE]
    cp $02
    jr z, .restartAfter590B
    call FinishFrame
    jr .waitTwoAfter590B
.restartAfter590B:
    jp DispatchD0B0Script
.storeCca7:
    ld a, [$D103]
    cp $14
    ret nc
    ld a, [$CCA7]
    ld [$D103], a
    ld [$D0C1], a
    ld hl, $579D
    ld e, $05
    call CallBankedHL
    ret
