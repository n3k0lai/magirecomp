; AdjustA000RecordOnce. Bank 2 at $59A3.
;
; RaiseEntriesBelow100 calls this once for the copy of sEntryBase ($A000)
; loaded at $D110, after clearing bit 0 of $D389 and setting bit 1.
; HL is that record. WRAM bank 7 is mapped.
;
; Unless bit 0 of $D389 is set, $3812 runs with BC = -100 and HL still
; pointing at the record. What $3812 writes is still unknown. The byte at
; record+4 is saved at $D38A. If that byte is already $63, the saved
; pointer is popped and this returns. Otherwise the byte is incremented.
;
; One more than the saved byte picks the step in DE: $000A below $20,
; $0010 below $3C, and $0001 from $3C up. $3821 receives that DE with HL
; restored to the record. $596F then returns at once unless bit 1 of
; $D389 is set; the caller sets that bit, so $596F continues. Both calls
; are still INCBIN.
;
; wCurrentWRAMBank, rSVBK, and WRAM_BANK_ENTRY are already defined.
; MEASURE_UNDER and STAT_CAP are already defined.

AdjustA000RecordOnce::
    push hl
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D389]
    bit 0, a
    jr nz, .rankByte

    ld bc, MEASURE_UNDER
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    call $3812

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
    pop hl
    ld a, [$D38A]
    inc a
    cp $20
    jr nc, .midBand

    ld de, $000A
    jr .applyStep

.midBand:
    cp $3C
    jr nc, .highBand

    ld de, $0010
    jr .applyStep

.highBand:
    ld de, $0001

.applyStep:
    call $3821
    call $596F
    ret
