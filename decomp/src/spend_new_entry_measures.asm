; SpendNewEntryMeasures. Bank 2 at $5B35.
;
; AddSRAMEntryForOperand calls here after the new SRAM entry is written
; and SRAM is disabled. $CD52 holds that entry's address. $CD50 is the
; second opcode $2C operand.
;
; WRAM bank 7 is mapped. LoadD110Record copies the entry into $D110.
; $D389 is then set to 1: bit 0 set and bit 1 clear. The `set` / `res`
; pair is how this ROM builds that value from zero.
;
; SpendMeasureHundred then runs on $D110 once for each count in
; [$CD50] - 1. A count of 1 skips the loop. With bit 0 of $D389 set,
; those passes leave the measure word at record+5 unchanged.
;
; $CD52 is loaded into BC again and WriteD110RecordBody stores the
; $D110 body back over the SRAM entry. The caller's saved WRAM bank
; is restored after this returns.
;
; wCurrentWRAMBank, rSVBK, and WRAM_BANK_ENTRY are already defined.
; LoadD110Record, SpendMeasureHundred, and WriteD110RecordBody are
; already source.

SpendNewEntryMeasures::
    ld hl, $CD52
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D110
    ld a, [$CD50]
    dec a
    push af
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call LoadD110Record
    xor a
    set 0, a
    res 1, a
    ld [$D389], a
    pop af
    and a
    jr z, .writeBack
.spend:
    ld hl, $D110
    push af
    call SpendMeasureHundred
    pop af
    dec a
    jr nz, .spend
.writeBack:
    ld hl, $CD52
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D110
    call WriteD110RecordBody
    ret
