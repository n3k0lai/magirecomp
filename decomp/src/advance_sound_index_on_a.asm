; Newly pressed A advances a sound index and returns. Bank 7 stays mapped.
;
; Bit 0 of wButtonsPressed is A (ReadJoypad: low nibble A, B, Select, Start).
; When that bit is clear, control jumps to $59CA, still INCBIN, which tests
; the other buttons. DE is preserved on the taken path.
;
; $C926 counts 0 through $28 and wraps to 0. When that count differs from
; wSoundIndex, it becomes the new index and wSoundActive is set to 1.
; Either way, wSoundSelect is cleared and $C92C is set to $0F. InitSoundState
; clears $C926 with the other sound bytes. What the count is for, besides
; feeding wSoundIndex, is still unknown.
;
; wButtonsPressed is the name from main_loop.asm. wSoundIndex, wSoundActive,
; and wSoundSelect are the names from select_sound_command.asm. $C92C is
; the byte handle_start_press.asm calls wUnknownC92C.

; Index source cleared by InitSoundState. Range after wrap is 0-$28.
DEF wSoundIndexCursor EQU $C926

AdvanceSoundIndexOnA:
    ld a, [wButtonsPressed]
    bit 0, a
    jp z, SoundIndexButtonsAfterA

    ld a, [wSoundIndexCursor]
    inc a
    cp $29
    jr nz, .store_cursor

    xor a

.store_cursor:
    ld [wSoundIndexCursor], a
    push de
    ld a, [wSoundIndexCursor]
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .index_unchanged

    ld a, e
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a

.index_unchanged:
    xor a
    ld [wSoundSelect], a
    ld a, $0F
    ld [wUnknownC92C], a
    pop de
    ret
