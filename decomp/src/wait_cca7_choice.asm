; Bank 5 at $590B. DispatchD0B0Script calls here on the path that is
; not [$CCA7] = $FE with [$D0B1] = 0.
;
; WRAM bank 7 is stored at $C937 and selected with rSVBK. [$D0B0] minus $0A
; indexes the word table at $402A in this bank. JumpHL calls that word.
; When it returns with D = 2, D stays 2. Otherwise D is 5, then 1 when
; [$D105] with bit 7 clear is at least 5.
;
; The choice block is then filled. $CCB4 is 1. The two loads of A just
; above that store are overwritten by it: [$D0B0] below $14 would have
; left 1, and any other value would have left 0. $CCA9 is $F3. $CCB8 is
; the WRAM bank in $C937. $CCB6 points at $D09B. $CCB0 and $CCB2 both
; point at $42E3. $CD81 receives D. $CCB9 is 0 and $CCBA is 2.
;
; Bank 3 at $417C runs once. $CCA7 is set to $FF. Each pass sets bit 4 of
; $C932 when [$D0B0] is at least $14, calls bank 3 at $4141, then calls
; FinishFrame, until [$CCA7] is no longer $FF. $C2D2 and $C2D3 are cleared
; on the way out.
;
; rSVBK is the name from timer_overflow.asm. JumpHL, CallBankedHL, and
; FinishFrame are already source. $402A, $417C, and $4141 are still INCBIN.

WaitForCca7Choice::
    ld a, $07
    ld [$C937], a
    ldh [rSVBK], a
    ld a, [$D0B0]
    sub $0A
    add a
    ld c, a
    ld b, $00
    ld hl, $402A
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    ld a, $02
    cp d
    jr z, .keepReturnedD
    ld d, $05
    ld a, [$D105]
    res 7, a
    cp $05
    jr c, .keepReturnedD
    ld d, $01
.keepReturnedD:
    ld a, [$D0B0]
    cp $14
    jr c, .markBelow14
    ld a, $00
    jr .storeOverwrittenMark
.markBelow14:
    ld a, $01
.storeOverwrittenMark:
    ld a, $01
    ld [$CCB4], a
    ld a, $F3
    ld [$CCA9], a
    ld a, [$C937]
    ld [$CCB8], a
    ld bc, $D09B
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $42E3
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $42E3
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, d
    ld [$CD81], a
    ld a, $00
    ld [$CCB9], a
    ld a, $02
    ld [$CCBA], a
    ld hl, $417C
    ld e, $03
    call CallBankedHL
    ld a, $FF
    ld [$CCA7], a
.waitChoice:
    ld a, [$D0B0]
    cp $14
    jr c, .runPass
    ld hl, $C932
    set 4, [hl]
.runPass:
    ld hl, $4141
    ld e, $03
    call CallBankedHL
    call FinishFrame
    ld a, [$CCA7]
    cp $FF
    jr z, .waitChoice
    xor a
    ld [$C2D2], a
    ld [$C2D3], a
    ret
