; Copy the waveform at HL into wave RAM, then restart channel 3.
;
; The ROM bank at $DF75 is mapped first through $3AB0, still INCBIN. On the
; way out that same routine maps the bank saved at $DF00.
;
; A header whose high nibble is $7 is a flat wave. The next byte is stored
; at $DF7D, wave RAM is filled with sample pair $88, and the last $0E bytes
; of the 16-byte record are skipped. Any other header falls through to
; $3C32, still INCBIN, which copies all 16 bytes. Both paths then write
; $DF14 to NR34 with the trigger bit set, and write it again with that bit
; clear. What $DF7D and $DF14 are used for outside this routine is unknown.
;
; rNR30 and rNR34 are the channel 3 DAC and frequency-high registers.
; $FF30 is wave RAM. Every register store below is the 2-byte ldh form.

DEF rNR30 EQU $FF1A
DEF rNR34 EQU $FF1E

LoadWaveform::
    push bc
    ld a, [$df75]
    call $3ab0
    ld a, [hl]
    and $f0
    cp $70
    jr nz, LoadWaveformCopy
    inc hl
    ld a, [hl+]
; Entry with the flat-wave parameter already in A.
LoadWaveformFlat::
    ld [$df7d], a
; Entry that fills wave RAM with $88 and skips $0E bytes at HL.
FillFlatWave::
    xor a
    ldh [rNR30], a
    ld a, $88
    ld c, $10
    push hl
    ld hl, $ff30
.flatByte
    ld [hl+], a
    dec c
    jr nz, .flatByte
    ld a, $80
    ldh [rNR30], a
    ld bc, $000e
    pop hl
    add hl, bc
    jr LoadWaveformRetrigger

LoadWaveformCopy:
    call $3c32

LoadWaveformRetrigger:
    ld a, [$df14]
    or $80
    ldh [rNR34], a
    and $7f
    ldh [rNR34], a
    ld a, [$df00]
    call $3ab0
    pop bc
    ret
