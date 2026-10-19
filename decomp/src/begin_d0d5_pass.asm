; Bank 2 at $6AED. LoopWhileD0D5 calls here at the top of every pass.
;
; Five bytes are written at $C71B, the last of the four seven-byte script
; records FinishFrame handles. FinishFrame then runs until wUnknownC6EE
; is 0. The record is written again with the second byte $B8 instead of
; $BA, and FinishFrame runs until wUnknownC6EE is 2.
;
; $D0B1 is cleared. WRAM bank 7 is selected, and the $37-byte record at
; $D147 is copied to $D0D9. Bank 7 is selected again. $D0EE and the word
; at $D0FD are cleared. StoreSlotPairs0214 runs with A = [$D103].
;
; $D0C2, $D0C0, and $D0C1 are set to $58, $06, and $0B, then bank 5 at
; $57BA runs. $5FDF runs next. Those three bytes are set to $58, $00, and
; $0B, and bank 5 at $57BA runs again. The word at $D100 is compared with
; $5272. Equal sets the three bytes to $58, $02, and $0B and calls $57BA
; a third time. $D0D9 is copied back to $D147.
;
; wUnknownC6EE is the name from setup_window.asm. wCurrentWRAMBank and
; rSVBK are the names from timer_overflow.asm. FinishFrame, Copy37ByteRecord,
; StoreSlotPairs0214, and CallBankedHL are already source. $5FDF and bank 5's
; $57BA are still INCBIN.

BeginD0D5Pass::
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
.waitZero:
    ld a, [wUnknownC6EE]
    cp $00
    jr z, .writeSecond
    call FinishFrame
    jr .waitZero
.writeSecond:
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
.waitTwo:
    ld a, [wUnknownC6EE]
    cp $02
    jr z, .copyIn
    call FinishFrame
    jr .waitTwo
.copyIn:
    xor a
    ld [$D0B1], a
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $D147
    ld hl, $D0D9
    call Copy37ByteRecord
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [$D0EE], a
    ld hl, $D0FD
    ld [hl+], a
    ld [hl], a
    ld a, [$D103]
    call StoreSlotPairs0214
    ld a, $58
    ld [$D0C2], a
    ld a, $06
    ld [$D0C0], a
    ld a, $0B
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    call $5FDF
    ld a, $58
    ld [$D0C2], a
    ld a, $00
    ld [$D0C0], a
    ld a, $0B
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    ld hl, $D100
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $5272
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    jr nz, .copyBack
    ld a, $58
    ld [$D0C2], a
    ld a, $02
    ld [$D0C0], a
    ld a, $0B
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
.copyBack:
    ld bc, $D0D9
    ld hl, $D147
    call Copy37ByteRecord
    ret
