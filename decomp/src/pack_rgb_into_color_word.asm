; Bank 7 at $459A. SplitRgbFromColorWord leaves red in A, green in E, and
; blue in D, each in the low five bits. This packs them back into the
; little-endian GBC color word in BC (0bbbbbgg gggrrrrr). The name
; PackRgbIntoColorWord is already an EQU in step_color_word_toward_black.asm.

PackRgbChannelsIntoColorWord::
    rlca
    rlca
    rlca
    ld c, a
    srl e
    rr c
    srl e
    rr c
    srl e
    rr c
    ld a, d
    add a
    add a
    add e
    and $7f
    ld b, a
    ret
