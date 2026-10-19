; StepSlotPair command $4D when $CC47 is 6. Runs after SetupCommand4D.
;
; Mode becomes 7 and $CC4B becomes 1, which is the redraw flag the start
; loop tests. $CD81 is restored as $CCA0 plus $1C, the inverse of the
; store StepSlotPair makes when the command and the mode disagree.
;
; SRAM bank $C727 is mapped and enabled. The id at $A118[$CC4C] times $25
; selects a record in the next SRAM bank. The byte at record+$22+$CCA0 is
; replaced with $CCA3, the group offset SetupCommand4D just stored.
; Back in bank $C727, a nonzero old byte increments $A019[old]. $A019
; indexed by the new byte is always decremented. SRAM is then disabled.
;
; `add a, $00` leaves the RAM-bank byte unchanged. Nothing reads those flags.
; wUnknownCC47, wUnknownCC4C, and wUnknownCD81 are the names from
; handle_start_press.asm. wUnknownCC4B is the name from after_start_loop.asm.
; wUnknownCCA3 is the name from setup_command_4d.asm. rRAMG is the name from
; reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the names from
; handle_start_press.asm. sEntryIds, sEntryBase, sEntryScan, ENTRY_STRIDE,
; and ENTRY_PAIR_OFF are the names from indexed_tail_07.asm. MulCByB is
; already source.

; Saved as $CD81 minus $1C on a mode mismatch. Restored below.
DEF wUnknownCCA0 EQU $CCA0

; Added back onto $CCA0 to recover the slot index.
DEF SLOT_RESTORE_BIAS EQU $1C

; Mode stored when command $4D ran while the previous mode was 6.
DEF MODE_AFTER_6 EQU $07

Mode6AfterCommand4D::
    ld a, MODE_AFTER_6
    ld [wUnknownCC47], a
    ld a, $01
    ld [wUnknownCC4B], a
    ld a, [wUnknownCCA0]
    add SLOT_RESTORE_BIAS
    ld [wUnknownCD81], a
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wUnknownCC4C]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc
    ld a, [hl]
    ld c, a
    ld b, ENTRY_STRIDE
    call MulCByB
    ld bc, sEntryBase + ENTRY_PAIR_OFF
    add hl, bc
    ld a, [wUnknownCCA0]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, [wUnknownCCA3]
    ld b, [hl]
    ld [hl], a
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, b
    and a
    jr z, .adjustNew

    ld c, a
    ld b, $00
    ld hl, sEntryScan
    add hl, bc
    inc [hl]

.adjustNew:
    ld a, [wUnknownCCA3]
    ld c, a
    ld b, $00
    ld hl, sEntryScan
    add hl, bc
    dec [hl]
    xor a
    ld [rRAMG], a
    ret
