; Bank 2 at $725E. Index 0 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $D074 counts tries. It is cleared on entry and incremented at the top
; of the loop. Inc leaves A at 0, so a wrap from $FF to 0 ends the search
; with A = 0.
;
; Otherwise AddDividerStep's byte is divided by 5. DivideCByB leaves the
; quotient in H and the remainder in L. Remainder 0 ends the search with
; A = 0. Remainders 1-4 read the byte at $D0D9 + $20 + remainder - 1.
; Anything other than $FF retries. $FF keeps that remainder in A.
;
; A is stored at $CCA7. CallBankedHL runs bank 5 at $56AF, then bank 5
; at $43E6. A zero byte at $D0AF starts the search again. Any other value
; calls PickD091MarkIntoD103 and returns.
;
; AddDividerStep, DivideCByB, CallBankedHL, and PickD091MarkIntoD103 are
; already source. Bank 5's $56AF and $43E6 are still INCBIN.

MatchDividerRemainderToFF::
    xor a
    ld [$D074], a
.retry:
    xor a
    ld hl, $D074
    inc [hl]
    jr z, .postScript
    call AddDividerStep
    ld c, a
    ld b, $05
    call DivideCByB
    ld a, l
    and a
    jr z, .postScript
    push af
    dec a
    ld hl, $D0D9
    ld bc, $0020
    add hl, bc
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp $FF
    pop bc
    ld a, b
    jr nz, .retry
.postScript:
    ld [$CCA7], a
    ld hl, $56AF
    ld e, $05
    call CallBankedHL
    ld hl, $43E6
    ld e, $05
    call CallBankedHL
    ld a, [$D0AF]
    and a
    jr z, .retry
    call PickD091MarkIntoD103
    ret
