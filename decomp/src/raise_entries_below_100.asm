; RaiseEntriesBelow100. Called after $D14E is stored at SRAM $A005.
;
; WRAM bank 7 is mapped. $D074 counts down from 10 while HL walks from
; $D383 down through the ten bytes. Each pass clears $D071. A zero byte
; skips that slot. A nonzero byte selects sEntryIds from the end: the
; remaining count minus one is the index. SRAM bank wSRAMBank is enabled
; for that read (`add a, $00` leaves the bank byte unchanged), then
; disabled. The id times ENTRY_STRIDE, plus sEntryBase, is stored at
; $D0CF/$D0D0.
;
; $55C3 returns a measure in HL. Below 100, $5C1E loads the record at
; $D110 and $57F1 repeats until the big-endian word at $D115 is at least
; 100. Each $57F1 call stores 1 in wSoundIndex and wSoundActive and sets
; $D389 to bit 1, then clears $D389 before the word is tested. $5C93
; writes the record back from the pointer at $D0CF.
;
; After the ten slots, the same measure is taken for sEntryBase. At least
; 100 returns. Otherwise $5C1E, $59A3, and $5C93 run once, with $D389
; bit 0 cleared and bit 1 set, and both sound bytes set to 1.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. sEntryIds, sEntryBase,
; ENTRY_STRIDE, and WRAM_BANK_ENTRY are the names from indexed_tail_07.asm.
; MulCByB is already source. wSoundIndex and wSoundActive are the names
; from select_sound_command.asm.

DEF MEASURE_UNDER EQU $0064

RaiseEntriesBelow100::
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, $D383
    ld a, $0A
    ld [$D074], a
.slot:
    xor a
    ld [$D071], a
    ld a, [hl-]
    and a
    jp z, .countDown
    push hl
    ld hl, sEntryIds
    ld a, [$D074]
    dec a
    ld c, a
    ld b, $00
    add hl, bc
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, [hl]
    ld c, a
    xor a
    ld [rRAMG], a
    ld b, ENTRY_STRIDE
    call MulCByB
    ld bc, sEntryBase
    add hl, bc
    ld a, h
    ld [$D0D0], a
    ld a, l
    ld [$D0CF], a
    call $55C3
    ld bc, MEASURE_UNDER
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld hl, $D0CF
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    jr nc, .popSlot
    ld hl, $D110
    call $5C1E
.raiseWord:
    ld a, $01
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a
    ld hl, $D389
    ld [hl], $00
    set 1, [hl]
    ld hl, $D110
    call $57F1
    xor a
    ld [$D389], a
    ld hl, $D115
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    ld bc, MEASURE_UNDER
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    jr c, .raiseWord
    ld hl, $D0CF
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D110
    call $5C93
.popSlot:
    pop hl
.countDown:
    push hl
    ld hl, $D074
    dec [hl]
    pop hl
    jp nz, .slot
    ld bc, sEntryBase
    ld hl, $D0CF
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $55C3
    ld bc, MEASURE_UNDER
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ret nc
    ld bc, sEntryBase
    ld hl, $D110
    call $5C1E
    ld a, $01
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a
    ld hl, $D389
    res 0, [hl]
    set 1, [hl]
    ld hl, $D110
    call $59A3
    ld hl, $D110
    ld bc, sEntryBase
    call $5C93
    ret
