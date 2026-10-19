; Script entry at $2338, between opcode $9B's countdown and opcode $9D.
;
; ReturnUnlessC6EEIsTwo continues only when [wUnknownC6EE] is 2. The next
; script byte is the run length. BC, now past that byte, is saved as
; hScriptPtr (low byte first) through HL. $CCC2 is set to 1 and the next
; three bytes are cleared. From $CCC3 the length minus one is then written
; downward, one smaller each byte, until the value hits zero. A length of
; 1 leaves the three zeros in place. A longer length writes past them.
;
; The armed-slot fields LoadArmedSlotRecord reads are filled next. $CCB4
; is 3, $CCB8 copies [$C937], $CCB6 points at $CCC2, $CD81 is 0, and both
; $CCB9 and $CCBA are 1. $CCA9 is $F1. $CCB0 and $CCB2 both become $42E3,
; the two jump pointers DispatchMaskedAction uses. The zero at $CD81 is
; the 2-byte `ld a, $00` form.
;
; LoadArmedSlotRecord then runs in bank 3 through CallBankedHL. $CCA7 is
; set to $FF. hScriptHandler becomes $23A7 with the `ldh` form, and this
; returns. That continuation is still INCBIN.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.
; wUnknownC6EE is the name from setup_window.asm. CallBankedHL is the
; name from call_hl_in_bank.asm. LoadArmedSlotRecord is already source.
; $C937, $CCA7, $CCA9, $CCB0, $CCB4, $CCB8, $CCB9, $CCBA, $CCC2, and
; $CD81 have no names on this path.

; Next script handler. Still INCBIN.
DEF Opcode9CContinue EQU $23A7

Opcode9C::
    call ReturnUnlessC6EEIsTwo
    ld a, [bc]
    ld e, a
    inc bc
    ld hl, hScriptPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $01
    ld hl, $ccc2
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, e
    dec a
    ld hl, $ccc3

.fill:
    ld [hl+], a
    dec a
    jr nz, .fill

    ld a, $03
    ld [$ccb4], a
    ld a, $f1
    ld [$cca9], a
    ld a, [$c937]
    ld [$ccb8], a
    ld bc, $ccc2
    ld hl, $ccb6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $42e3
    ld hl, $ccb0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $42e3
    ld hl, $ccb2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $00
    ld [$cd81], a
    ld a, $01
    ld [$ccb9], a
    ld a, $01
    ld [$ccba], a
    ld hl, LoadArmedSlotRecord
    ld e, $03
    call CallBankedHL
    ld a, $ff
    ld [$cca7], a
    ld a, LOW(Opcode9CContinue)
    ldh [hScriptHandler], a
    ld a, HIGH(Opcode9CContinue)
    ldh [hScriptHandler + 1], a
    ret
