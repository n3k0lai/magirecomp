; Walk BC sample records and drive the pulse envelopes.
;
; The ROM bank at $DF75 is mapped through $2100, the same MBC window as
; rROMB0 ($2000). The word at $DF76 is the first record. A record whose
; high nibble is $7 is a flat hold: the next byte is a repeat count at
; $DF7D (wWaveSampleCopy), the other $0E bytes are skipped, and both
; pulse envelopes are held at $70 for $20 steps per repeat. Any other
; record is sixteen bytes. Each byte is played high nibble, then low
; nibble. $20 steps cover the record.
;
; A nibble is written to rNR12 and rNR22 only when it differs from the
; nibble in E. Those writes also store $87 to rNR14 and rNR24, which
; retriggers both pulse channels. The matching path is twelve `nop`s, so
; both paths take the same time before the $14-iteration delay. On a
; sample byte, the even step's two `nop`s plus `jr` match the odd step's
; `inc hl` and `swap a`. The flat hold has no pointer advance, so that
; padding is a single `jr`.
;
; After a record, bit 7 of H means the pointer left the $4000-$7FFF
; window. H is pulled back to $40 and the bank at $DF75 is incremented
; and mapped. $3D2A then returns a bitfield in B. If that bitfield shares
; a bit with $DFFE, the walk stops. Otherwise BC is the number of records
; still to play. What $3D2A and $DFFE are is still unknown.
;
; rNR12 and rNR22 are the channel 1 and 2 envelope registers. rNR14 and
; rNR24 are the channel 1 and 2 frequency-high registers. wWaveSampleCopy
; is the name from update_wave_duty.asm.

DEF rNR12 EQU $FF12
DEF rNR14 EQU $FF14
DEF rNR22 EQU $FF17
DEF rNR24 EQU $FF19

WalkEnvelope::
    ld a, [$df75]
    ld [$2100], a
    ld e, $00
    ld hl, $df76
    ld a, [hl+]
    ld h, [hl]
; Entry with the pointer low byte in A. H already holds the high byte.
WalkEnvelopeAtPointer::
    ld l, a
; Entry at the record HL points to. E is the last envelope nibble.
WalkEnvelopeRecord::
    ld a, [hl]
    ld d, a
    and $f0
    cp $70
    ld a, d
    jr z, .flat

    ld d, $20
.nibble:
    bit 0, d
    jr nz, .lowNibble
    nop
    nop
    jr .apply
.lowNibble:
    inc hl
    swap a
.apply:
    and $f0
    cp e
    ld e, a
    jr z, .same
    ldh [rNR12], a
    ldh [rNR22], a
    ld a, $87
    ldh [rNR14], a
    ldh [rNR24], a
    jr .delay
.same:
REPT 12
    nop
ENDR
.delay:
    ld a, $14
.wait:
    dec a
    jr nz, .wait
    dec d
    ld a, [hl]
    jr nz, .nibble

; Next record, after a bank wrap when the pointer has left ROM.
.nextRecord:
    bit 7, h
    jr z, .gate
    ld h, $40
    ld a, [$df75]
    inc a
    ld [$df75], a
    ld [$2100], a
.gate:
    push bc
    call $3d2a
    ld a, [$dffe]
    and b
    pop bc
    ret nz
    dec bc
    ld a, b
    or c
    jr nz, WalkEnvelopeRecord
    ret

.flat:
    inc hl
    ld a, [hl+]
    ld [wWaveSampleCopy], a
    push bc
    ld bc, $000e
    add hl, bc
    pop bc
.hold:
    ld a, $77
    ld d, $20
.flatNibble:
    bit 0, d
    jr nz, .flatLow
    jr .flatApply
.flatLow:
    swap a
.flatApply:
    and $f0
    cp e
    ld e, a
    jr z, .flatSame
    ldh [rNR12], a
    ldh [rNR22], a
    ld a, $87
    ldh [rNR14], a
    ldh [rNR24], a
    jr .flatDelay
.flatSame:
REPT 12
    nop
ENDR
.flatDelay:
    ld a, $14
.flatWait:
    dec a
    jr nz, .flatWait
    dec d
    ld a, $77
    jr nz, .flatNibble
    ld a, [wWaveSampleCopy]
    dec a
    ld [wWaveSampleCopy], a
    jr nz, .hold
    jr .nextRecord
