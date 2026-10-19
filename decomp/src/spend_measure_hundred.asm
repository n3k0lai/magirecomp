; SpendMeasureHundred. Bank 2 at $57F1.
;
; HL is a record, usually $D110. RaiseEntriesBelow100 calls this while the
; big-endian word at record+5 ($D115) is still at least 100, after setting
; bit 1 of $D389. Each call maps WRAM bank 7, then takes two rDIV samples
; through MaskDivByC with C = 3.
;
; The first sample times 5 is stored at $D38B (0, 5, 10, or 15). The second
; plus one is stored at $D388 (1 through 4). The byte at record+3 is loaded
; into E with D clear. The five calls below see that DE and HL pointing at
; record+4. What they read there is still unknown.
;
; Unless bit 0 of $D389 is set, the big-endian word at record+5 is reduced
; by 100 and written back, including when that underflows. If the byte at
; record+4 is already $63, the saved record pointer is popped and this
; returns. Otherwise that byte is incremented. Once it reaches $3E, $D38B
; is cleared.
;
; $5AFA, $59F2, $5A2B, $5A64, and $5AAF each return a byte in A. Those bytes
; are added to record+11 through record+15, and each sum is capped at $63.
; Record+17 plus the $D388 roll (low 8 bits only) is added to the big-endian
; word at record+9, and that word is capped at 250.
;
; The byte at record+16 indexes JitterScaledTableByte with scale $0A. That
; signed offset is added to one more than the original record+4 byte, and
; the sum is stored at $D38A with no cap. $5657 and $58FF then run. Both
; are still INCBIN. $58FF returns immediately unless bit 1 of $D389 is set.
;
; wCurrentWRAMBank, rSVBK, and WRAM_BANK_ENTRY are already defined.
; MaskDivByC, MulCByB, and JitterScaledTableByte are already source.
; MEASURE_UNDER is the 100 from raise_entries_below_100.asm.

DEF STAT_CAP EQU $63
DEF MEASURE_WORD_CAP EQU $00FA
DEF RANK_ROLL_CLEAR EQU $3E

SpendMeasureHundred::
    push hl
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld c, $03
    call MaskDivByC
    ld c, a
    ld b, $05
    call MulCByB
    ld a, l
    ld [$D38B], a
    ld c, $03
    call MaskDivByC
    inc a
    ld [$D388], a
    pop hl
    push hl
    ld bc, $0003
    add hl, bc
    ld d, $00
    ld e, [hl]
    ld a, [$D389]
    bit 0, a
    jr nz, .rankByte

    pop hl
    push hl
    ld bc, $0005
    add hl, bc
    push hl
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
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c

.rankByte:
    pop hl
    push hl
    ld bc, $0004
    add hl, bc
    ld a, [hl]
    ld [$D38A], a
    cp STAT_CAP
    jr nz, .growRank

    pop hl
    ret

.growRank:
    inc a
    ld [hl], a
    cp RANK_ROLL_CLEAR
    jr c, .contributions

    xor a
    ld [$D38B], a

.contributions:
    call $5AFA
    ld [$D38C], a
    call $59F2
    ld [$D38D], a
    call $5A2B
    ld [$D38E], a
    call $5A64
    ld [$D38F], a
    call $5AAF
    ld [$D390], a
    pop hl
    push hl
    ld de, $000B
    add hl, de
    ld a, [$D38C]
    add [hl]
    cp STAT_CAP
    jr c, .stat0
    ld a, STAT_CAP
.stat0:
    ld [hl], a
    inc hl
    ld a, [$D38D]
    add [hl]
    cp STAT_CAP
    jr c, .stat1
    ld a, STAT_CAP
.stat1:
    ld [hl], a
    inc hl
    ld a, [$D38E]
    add [hl]
    cp STAT_CAP
    jr c, .stat2
    ld a, STAT_CAP
.stat2:
    ld [hl], a
    inc hl
    ld a, [$D38F]
    add [hl]
    cp STAT_CAP
    jr c, .stat3
    ld a, STAT_CAP
.stat3:
    ld [hl], a
    inc hl
    ld a, [$D390]
    add [hl]
    cp STAT_CAP
    jr c, .stat4
    ld a, STAT_CAP
.stat4:
    ld [hl], a
    pop hl
    push hl
    ld bc, $0011
    add hl, bc
    ld a, [hl]
    ld l, a
    ld h, $00
    ld d, h
    ld a, [$D388]
    ld e, a
    add hl, de
    ld e, l
    pop hl
    push hl
    ld bc, $0009
    add hl, bc
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, de
    ld de, MEASURE_WORD_CAP
    ld a, h
    cp d
    jr nz, .wordCompared
    ld a, l
    cp e
.wordCompared:
    jr c, .storeWord
    ld h, d
    ld l, e
.storeWord:
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c
    pop hl
    push hl
    ld bc, $0010
    add hl, bc
    ld b, [hl]
    ld a, $0A
    call JitterScaledTableByte
    ld b, a
    ld a, [$D38A]
    inc a
    add b
    ld [$D38A], a
    pop hl
    call $5657
    call $58FF
    ret
