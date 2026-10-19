; Bank 2 at $71EF. Index 3 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $D074 counts tries. It is cleared on entry and incremented at the top
; of the loop. Inc leaves A at 0, so a wrap from $FF to 0 ends the search
; with A = 0.
;
; Otherwise AddDividerStep's byte is divided by 6. DivideCByB leaves the
; quotient in H and the remainder in L. Remainder 0 ends the search with
; A = 0. Remainder 1 is decremented to 0 and ends the same way.
; Remainders 2 through 5 read the byte at $D0D9 + $20 + remainder - 2.
; Anything other than $FF retries. $FF keeps remainder - 1 in A.
;
; A is stored at $CCA7. CallBankedHL runs bank 5 at $56AF, then bank 5
; at $43E6. A zero byte at $D0AF starts the search again.
;
; ResolveD103BeforeMarkScan runs next. A nonzero $D0C9 returns.
; When bit 6 of $D0EE is set, AddDividerStep runs again: bit 4 set calls
; $714F, and bit 4 clear calls PickD096SlotPlus5. When bit 6 is clear,
; $D105 below 5 calls $714F, and $D105 at or above 5 calls
; PickD096SlotPlus5.
;
; $714F, bank 5 at $56AF, and bank 5 at $43E6 are still INCBIN.
; AddDividerStep, DivideCByB, CallBankedHL, ResolveD103BeforeMarkScan,
; and PickD096SlotPlus5 are already source.

MatchSixRemainderThenPickSlot::
    xor a
    ld [$D074], a
.retry:
    xor a
    ld hl, $D074
    inc [hl]
    jr z, .postScript
    call AddDividerStep
    ld c, a
    ld b, $06
    call DivideCByB
    ld a, l
    and a
    jr z, .postScript
    dec a
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
    call ResolveD103BeforeMarkScan
    ld a, [$D0C9]
    and a
    ret nz
    ld a, [$D0EE]
    and $40
    jr z, .d0eeBit6Clear
    call AddDividerStep
    bit 4, a
    jr z, .pickD096
    jr .call714F
.d0eeBit6Clear:
    ld a, [$D105]
    cp $05
    jr nc, .pickD096
.call714F:
    call $714F
    ret
.pickD096:
    call PickD096SlotPlus5
    ret
