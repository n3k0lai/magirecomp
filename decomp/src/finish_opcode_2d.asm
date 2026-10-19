; Bank 2 at $752D. Opcode2D copies four script bytes to $D392, clears
; $D396, maps this bank, and jumps here.
;
; $D0D8 is cleared, then $748B runs. That call can set $D0AF and $D0D8.
; A zero [$D0AF] with $D0D8 still zero returns. A zero [$D0AF] with
; $D0D8 set clears the high byte at $D0E0, stores 1 at $D0E1, and returns.
;
; A nonzero [$D0AF] copies [$D338] to $D0C2, stores 2 at $D0C0 and $0C
; at $D0C1, and calls ApplyIndexedIdRecord in bank 5. $4653 runs next.
; The word at $D07B is the destination for a $37-byte copy from $D110.
; [$D103] indexes $D07D, and that byte becomes [$D396] plus one. $51C2
; is stored at $D100. [$D392] selects a $37-byte record at $D147, and
; the record at $D0D9 is copied there.
;
; ApplyIndexedIdRecord, CallBankedHL, Copy37ByteRecord, and
; IndexTimes37PlusD147 are already source. $748B and $4653 are still
; INCBIN.

FinishOpcode2D::
    xor a
    ld [$D0D8], a
    call $748B
    ld a, [$D0AF]
    and a
    jr nz, .d0afSet
    ld a, [$D0D8]
    and a
    ret z
    xor a
    ld [$D0E0], a
    ld a, $01
    ld [$D0E1], a
    ret

.d0afSet:
    ld a, [$D338]
    ld [$D0C2], a
    ld a, $02
    ld [$D0C0], a
    ld a, $0C
    ld [$D0C1], a
    ld hl, ApplyIndexedIdRecord
    ld e, $05
    call CallBankedHL
    call $4653
    ld hl, $D07B
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $D110
    call Copy37ByteRecord
    ld a, [$D103]
    ld c, a
    ld b, $00
    ld hl, $D07D
    add hl, bc
    ld a, [$D396]
    inc a
    ld [hl], a
    ld bc, $51C2
    ld hl, $D100
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$D392]
    call IndexTimes37PlusD147
    ld bc, $D0D9
    call Copy37ByteRecord
    ret
