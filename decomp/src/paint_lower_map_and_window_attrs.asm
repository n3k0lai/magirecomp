; Bank 4 at $65CF. Called from $314F after the panel tiles are copied and
; bank $04 is mapped again.
;
; VRAM bank 0: FillBytes writes $00 over $A0 bytes at $99A0. That span is
; BG map rows 13 through 17 ($9800 + $01A0, five rows of 32).
; VRAM bank 1: the same span is filled with attribute $07.
; Still in VRAM bank 1, ClampAddedByte adds $06 to the $01A0 bytes at
; $9800 (rows 0 through 12) and stores $FF when the sum is not below $FF.
; Still in VRAM bank 1, $A0 bytes at the window map $9C00 are filled
; with $8F.
;
; rVBK is the name from setup_window.asm. FillBytes and ClampAddedByte
; are already source.

PaintLowerMapAndWindowAttrs::
    xor a
    ld [rVBK], a
    ld hl, $99A0
    ld bc, $00A0
    ld a, $00
    ld e, a
    call FillBytes
    ld a, $01
    ld [rVBK], a
    ld hl, $99A0
    ld bc, $00A0
    ld a, $07
    ld e, a
    call FillBytes
    ld hl, $9800
    ld bc, $01A0
    ld d, $FF
    ld a, $06
    ld e, a
    call ClampAddedByte
    ld hl, $9C00
    ld bc, $00A0
    ld a, $8F
    ld e, a
    call FillBytes
    ret
