; Bank 2 at $6110. DispatchD0B0Script calls this after clearing $D0C0.
;
; Bank 2 at $5F4D runs, then CallBankedHL runs bank 5 at $45B0. $CCA7 and
; $D0D5 are cleared. A zero [$D0B1] stores 1 in $CCA7. A nonzero [$D0B1]
; leaves $CCA7 at 0. Both paths then install STAT handler $2AC1 through
; the 3-byte stores at $FF99. WRAM bank 7 is stored in wCurrentWRAMBank
; and selected with rSVBK. $CCA8 becomes $81.
;
; Nonzero [$D0B1] writes $01,$01,$00,$00,$00,$01 at $CC4D. Up to three
; $FF bytes are copied from $D0FA into $CC4F, stopping at the first other
; byte. $CCB4 is 0. Zero [$D0B1] writes five $01 bytes at $CC4D and a 0
; at $CC52. A zero [$D0D3] also clears $CC51. The four bytes at $D092 are
; scanned for a 0. None clear $CC4E and $CCA7. A 0 sums those four bytes.
; A sum of 0 or 4 leaves the record alone. Any other sum selects SRAM
; bank wSRAMBank (`add a, $00` keeps that byte) and reads $A118 plus the
; sum. $FF there clears $CC4E and $CCA7. $CCB4 is $0A on this path.
;
; Both paths store wCurrentWRAMBank at $CCB8, $F3 at $CCA9, $CC4D at
; $CCB6, and HoldLcdOff at $CCB0 and $CCB2. [$CCA7] is copied to $CD81.
; $CCB9 and $CCBA are cleared with `ld a, $00`. CallBankedHL runs bank 3
; at $417C, then $CCA7 becomes $FF.
;
; The wait reads $CD81. $05 points wCallback at $3919, clears $CD81, sets
; bit 4 of wButtonsPressed, calls bank 3 at $4141, runs FinishFrame, and
; complements $D0FF. Every pass then calls that same $4141 and FinishFrame.
; [$CCA7] of $FF waits again. $FE with a nonzero [$D0B1] stores 1 in
; $D0D5 and returns. $FE with [$D0B1] = 0 waits again. Any other value
; calls LoadSelectedRecordToD100 and bank 5 at $43E6. A nonzero [$D0AF]
; returns. Zero jumps back to the STAT install.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; hSTATHandler is the name from lcd_stat.asm. wFillCC4D, wUnknownCC4E,
; wUnknownCC4F, wUnknownCC51, wUnknownCCA8, wUnknownCCA9, wUnknownCCB0,
; wUnknownCCB2, wUnknownCCB6, wUnknownCCB9, and wUnknownCD81 are the names
; from handle_start_press.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are too.
; rRAMG is the name from reset.asm. wCallback is the name from
; default_state.asm. wButtonsPressed is the name from main_loop.asm.
; HoldLcdOff, CallBankedHL, FinishFrame, and LoadSelectedRecordToD100 are
; already source. $5F4D, $45B0, $417C, $4141, and $43E6 are still INCBIN.

; STAT handler installed for the wait. Body is still INCBIN.
DEF STAT_HANDLER_2AC1_LO EQU $C1
DEF STAT_HANDLER_2AC1_HI EQU $2A

; Idle callback stored when $CD81 is 5. Body is still INCBIN.
DEF CALLBACK_3919_LO EQU $19
DEF CALLBACK_3919_HI EQU $39

; How many $D0FA bytes may be copied, and how many $D092 flags are summed.
DEF D0FA_COPY_MAX EQU $03
DEF D092_FLAG_COUNT EQU $04

; Sums that skip the SRAM byte at $A118.
DEF D092_SUM_SKIP_LO EQU $00
DEF D092_SUM_SKIP_HI EQU $04

; SRAM byte indexed by the $D092 sum. Bank is wSRAMBank.
DEF sD092Mark EQU $A118

DriveD0B1Choice::
    call $5F4D
    ld hl, $45B0
    ld e, $05
    call CallBankedHL
    xor a
    ld [$CCA7], a
    ld [$D0D5], a
    ld a, [$D0B1]
    and a
    jr nz, .frame

    ld a, $01
    ld [$CCA7], a

.frame:
    ld a, STAT_HANDLER_2AC1_LO
    ld [$ff99], a
    ld a, STAT_HANDLER_2AC1_HI
    ld [$ff9a], a
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, $81
    ld [wUnknownCCA8], a
    ld a, [$D0B1]
    cp $00
    jr z, .zeroMark

    ld a, $01
    ld hl, wFillCC4D
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $01
    ld [hl], a
    ld hl, $D0FA
    ld d, D0FA_COPY_MAX
    ld bc, wUnknownCC4F

.copyFF:
    ld a, [hl+]
    cp $FF
    jr nz, .armZeroB4

    ld [bc], a
    inc bc
    dec d
    jr nz, .copyFF

.armZeroB4:
    ld a, $00
    ld [$CCB4], a
    ld a, $F3
    ld [wUnknownCCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, wFillCC4D
    ld hl, wUnknownCCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$CCA7]
    ld [wUnknownCD81], a
    ld a, $00
    ld [wUnknownCCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, $417C
    ld e, $03
    call CallBankedHL
    ld a, $FF
    ld [$CCA7], a
    jp .waitChoice

.zeroMark:
    ld a, $01
    ld hl, wFillCC4D
    ld d, $05

.fillOnes:
    ld [hl+], a
    dec d
    jr nz, .fillOnes

    xor a
    ld [hl], a
    ld a, [$D0D3]
    and a
    jr nz, .scanFlags

    xor a
    ld [wUnknownCC51], a

.scanFlags:
    xor a
    ld hl, $D092
    ld d, D092_FLAG_COUNT

.findZero:
    cp [hl]
    jr z, .sumFlags

    inc hl
    dec d
    jr nz, .findZero

.clearSlot:
    xor a
    ld [wUnknownCC4E], a
    ld [$CCA7], a
    jr .armRecord

.sumFlags:
    ld hl, $D092
    xor a
    ld d, D092_FLAG_COUNT

.addFlag:
    add [hl]
    inc hl
    dec d
    jr nz, .addFlag

    and a
    jr z, .armRecord

    cp D092_SUM_SKIP_HI
    jr z, .armRecord

    ld c, a
    ld b, D092_SUM_SKIP_LO
    ld hl, sD092Mark
    add hl, bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    ld b, a
    xor a
    ld [rRAMG], a
    ld a, b
    cp $FF
    jr z, .clearSlot

.armRecord:
    ld a, $0A
    ld [$CCB4], a
    ld a, $F3
    ld [wUnknownCCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, wFillCC4D
    ld hl, wUnknownCCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, HoldLcdOff
    ld hl, wUnknownCCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$CCA7]
    ld [wUnknownCD81], a
    ld a, $00
    ld [wUnknownCCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, $417C
    ld e, $03
    call CallBankedHL
    ld a, $FF
    ld [$CCA7], a

.waitChoice:
    ld a, [wUnknownCD81]
    cp $05
    jr nz, .poll

    ld a, CALLBACK_3919_LO
    ld [wCallback], a
    ld a, CALLBACK_3919_HI
    ld [wCallback + 1], a
    xor a
    ld [wUnknownCD81], a
    set 4, a
    ld [wButtonsPressed], a
    ld hl, $4141
    ld e, $03
    call CallBankedHL
    call FinishFrame
    ld hl, $D0FF
    ld a, [hl]
    cpl
    ld [hl], a

.poll:
    ld hl, $4141
    ld e, $03
    call CallBankedHL
    call FinishFrame
    ld a, [$CCA7]
    cp $FF
    jr nc, .waitChoice

    cp $FE
    jr nz, .applyChoice

    ld a, [$D0B1]
    cp $00
    jr z, .waitChoice

    ld a, $01
    ld [$D0D5], a
    ret

.applyChoice:
    ld hl, LoadSelectedRecordToD100
    ld e, $05
    call CallBankedHL
    ld hl, $43E6
    ld e, $05
    call CallBankedHL
    ld a, [$D0AF]
    and a
    ret nz

    jp .frame
