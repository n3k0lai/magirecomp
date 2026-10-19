; Bank 7 at $4586. StepColorWords calls this with BC holding a little-endian
; GBC color word (0bbbbbgg gggrrrrr). A returns red, E green, and D blue,
; each in the low five bits. StepColorWords stores them at $C82D, $C82C,
; and $C82B. The name SplitColorWord is already an EQU in step_color_words.asm.

SplitRgbFromColorWord::
    ld a, c
    srl b
    rr c
    srl b
    rr c
    ld d, b
    srl c
    srl c
    srl c
    ld e, c
    and $1f
    ret
