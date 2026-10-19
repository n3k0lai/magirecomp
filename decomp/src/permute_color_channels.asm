; Bank 7 at $4787. PermutePanelPaletteChannels calls this with HL at color 1
; of a background palette, BC = 3, and E holding the channel index from
; wUnknownC9D8. Each pass loads one little-endian GBC color word
; (0bbbbbgg gggrrrrr) into BC, rewrites its channels, and stores it back.
; HL then advances by two. BC counts the words. DE is restored each pass.
;
; SplitRgbFromColorWord leaves red in A, green in E, and blue in D.
; PackRgbChannelsIntoColorWord packs those registers back into BC.
; Index 1 swaps red and blue. Index 2 swaps green and blue. Index 3 swaps
; red and green and then falls into the index-1 swap, so (R, G, B) becomes
; (B, R, G). Any other index, including 0, rotates the other way:
; (R, G, B) becomes (G, B, R).
;
; The caller in permute_panel_palette_channels.asm still names this address
; with DEF PermuteRgbWordsAtHl. Both callees are already source in this bank.

PermuteColorChannels::
    push bc
    ld a, [hli]
    ld c, a
    ld a, [hld]
    ld b, a
    push hl
    push de
    ld a, e
    cp $01
    jr z, .swapRedBlue
    cp $02
    jr z, .swapGreenBlue
    cp $03
    jr z, .swapRedGreen

    call SplitRgbFromColorWord
    ld b, a
    ld a, e
    ld e, d
    ld d, b
    call PackRgbChannelsIntoColorWord
    jr .storeWord

.swapGreenBlue:
    call SplitRgbFromColorWord
    ld b, e
    ld e, d
    ld d, b
    call PackRgbChannelsIntoColorWord
    jr .storeWord

.swapRedGreen:
    call SplitRgbFromColorWord
    ld b, e
    ld e, a
    ld a, b
    call PackRgbChannelsIntoColorWord

.swapRedBlue:
    call SplitRgbFromColorWord
    ld b, a
    ld a, d
    ld d, b
    call PackRgbChannelsIntoColorWord

.storeWord:
    pop de
    pop hl
    ld a, c
    ld [hli], a
    ld a, b
    ld [hli], a
    pop bc
    dec bc
    ld a, c
    or b
    jr nz, PermuteColorChannels
    ret
