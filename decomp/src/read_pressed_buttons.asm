; Sample the joypad buttons and return them in B.
;
; C is $00, so `ldh [c], a` is rP1 ($FF00). $10 selects A, B, Select,
; and Start. Five `nop`s and fourteen reads let the lines settle. The
; low nibble is complemented into B, so a pressed button is a set bit.
; $30 then releases both select lines.
;
; WalkEnvelope calls this between records and stops when B shares a bit
; with the byte at $DFFE. The tails at $3D38, $3D3A, and $3D3C are the
; same sample with fewer reads. $3D48 only writes A to rP1 and returns.
;
; rP1 is the name from switch_to_double_speed.asm.

ReadPressedButtons::
    ld c, $00
    ld a, $10
    ldh [c], a
REPT 5
    nop
ENDR
REPT 4
    ldh a, [c]
ENDR

; Ten reads left. Callers still inside INCBIN jump here.
ReadPressedButtons10::
REPT 2
    ldh a, [c]
ENDR

; Eight reads left.
ReadPressedButtons8::
REPT 2
    ldh a, [c]
ENDR

; Six reads left.
ReadPressedButtons6::
REPT 6
    ldh a, [c]
ENDR
    and $0f
    cpl
    ld b, a
    ld a, $30

; Write A to rP1 and return. Used to release the select lines.
ReleaseJoypadSelect::
    ldh [c], a
    ret
