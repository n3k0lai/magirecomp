; Word-table handler at $4415 (table entry 0 at $42A9).
;
; $CD81 selects a 4-byte record at $493B. Bit 0 of B is the masked-action
; flag from DispatchMaskedAction: set uses the first pair, clear uses the
; pair at offset 2. The first byte of a pair is a command. The second is
; the next slot index.
;
; A command below $2C, and any other command besides $2C, $2D, $4D, $58,
; and $63, is compared with $CC47. A match stores the next index in $CD81.
; A mismatch stores $CD81 minus $1C in $CCA0, sets $CC4B to 1, stores the
; command in $CC47, then stores the next index. If $CC47 is 7, the command
; is 6, and $CCA4 is nonzero, $14 is stored in $C921 and $CD81 is left as
; it is.
; $2C and $2D only set $CC4B to 1.
; $58 decrements the latch at $CD80 when it is set. When the latch is
; clear, $CC47 picks the next index: 6 stores 7 in $CC47 and $19 in $CD81,
; 3 stores 1, and $0B stores 5. Any other value continues on the compare
; path with $CC47 pushed in place of the command.
; $4D clears $CD80 when it holds 1, then calls $6DDF in bank 6. It also
; calls $6530 in bank 6 when $CC47 is 6. Those calls are skipped when
; $CC47 is $0B and $CD81 is not $24. If $CD80 was not 1, it is set to 1.
; When the bank 6 calls run and $CC47 is not 6, three words are dropped
; from the stack and control goes to $43BF.
; $63 drops three stacked words and jumps to $43BF, which does not return
; here. Every path that stays finishes in CopyIndexedSlot.
;
; The dispatcher at $41E3 reaches this through JumpHL. CallBankedHL is the
; trampoline at $0773. $43BF, the record at $493B, and the two bank 6
; routines are still INCBIN.

StepSlotPair::
    ld a, [$cd81]
    add a
    add a
    bit 0, b
    jr nz, .indexed

    add $02

.indexed
    ld hl, $493b
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl+]
    push hl
    push af
    cp $2c
    jp c, .compareMode

    cp $63
    jr nz, .notQuit

    add sp, $06
    jp $43bf

.notQuit
    cp $58
    jr nz, .notLatch

    ld hl, $cd80
    ld a, [hl]
    and a
    jr z, .latchClear

    dec [hl]
    jp .reloadSlot

.latchClear
    ld a, [$cc47]
    cp $06
    jr z, .fromMode6

    cp $03
    jr z, .fromMode3

    cp $0b
    jr z, .fromMode0B

    pop bc
    push af
    jp .compareMode

.fromMode6
    ld a, $01
    ld [$cc4b], a
    ld a, $07
    ld [$cc47], a
    ld a, $19
    ld [$cd81], a
    jr .reloadSlot

.fromMode3
    ld a, $01
    ld [$cd81], a
    jr .reloadSlot

.fromMode0B
    ld a, $05
    ld [$cd81], a
    jr .reloadSlot

.notLatch
    cp $4d
    jr nz, .notToggle

    ld a, [$cd80]
    cp $01
    jr nz, .setLatch

    xor a
    ld [$cd80], a
    ld a, [$cc47]
    cp $0b
    jr nz, .callBank6

    ld a, [$cd81]
    cp $24
    jr nz, .reloadSlot

.callBank6
    ld hl, $6ddf
    ld e, $06
    call CallBankedHL
    ld a, [$cc47]
    cp $06
    jr nz, .leaveToLoad

    ld hl, $6530
    ld e, $06
    call CallBankedHL
    jr .reloadSlot

.leaveToLoad
    add sp, $06
    jp $43bf

.setLatch
    ld a, $01
    ld [$cd80], a
    jr .reloadSlot

.notToggle
    cp $2d
    jr nz, .not2D

    ld a, $01
    ld [$cc4b], a
    jr .reloadSlot

.not2D
    cp $2c
    jr nz, .compareMode

    ld a, $01
    ld [$cc4b], a
    jr .reloadSlot

.reloadSlot
    pop bc
    pop bc
    ld a, [$cd81]
    jr .copySlot

.compareMode
    pop af
    pop hl
    ld b, a
    ld a, [$cc47]
    cp b
    jr z, .takeNext

    cp $07
    jr nz, .storeMode

    ld a, b
    cp $06
    jr nz, .storeMode

    ld a, [$cca4]
    and a
    jr z, .storeMode

    ld a, $14
    ld [$c921], a
    jr .copySlot

.storeMode
    ld a, [$cd81]
    sub $1c
    ld [$cca0], a
    ld a, $01
    ld [$cc4b], a
    ld a, b
    ld [$cc47], a

.takeNext
    ld a, [hl]
    ld [$cd81], a

.copySlot
    call CopyIndexedSlot
    ret
