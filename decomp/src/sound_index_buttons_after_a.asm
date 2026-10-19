; Start, Select, and B continue the sound-index button tests. Bank 7 stays
; mapped. AdvanceSoundIndexOnA jumps here when A was not newly pressed.
;
; Bit 0 of wButtonsPressed is A, bit 1 is B, bit 2 is Select, and bit 3 is
; Start (ReadJoypad: low nibble A, B, Select, Start). The first set bit
; among Start, Select, and B wins. If none of those is newly pressed, the
; routine returns.
;
; Start queues $10 in wSoundSlotA. Select queues $0F. B copies $C927 into
; wSoundSlotA, then steps that byte through 0-$27 and wraps to 0. What
; those three queued values mean to the slot-A sound command is still
; unknown. InitSoundState clears $C927 with the other sound bytes.
; wSoundSlotA is the name from select_sound_command.asm. wButtonsPressed
; is the name from main_loop.asm.

; Cursor cleared by InitSoundState. Range after wrap is 0-$27.
DEF wSoundSlotACursor EQU $C927

; Queued in wSoundSlotA. Which command each id selects is still unknown.
DEF SOUND_SLOT_A_ON_START EQU $10
DEF SOUND_SLOT_A_ON_SELECT EQU $0F

SoundIndexButtonsAfterA:
    ld a, [wButtonsPressed]
    bit 3, a
    jp z, .not_start

    ld a, SOUND_SLOT_A_ON_START
    ld [wSoundSlotA], a
    ret

.not_start:
    ld a, [wButtonsPressed]
    bit 2, a
    jp z, .not_select

    ld a, SOUND_SLOT_A_ON_SELECT
    ld [wSoundSlotA], a
    ret

.not_select:
    ld a, [wButtonsPressed]
    bit 1, a
    ret z

    ld a, [wSoundSlotACursor]
    ld [wSoundSlotA], a
    ld a, [wSoundSlotACursor]
    inc a
    cp $28
    jr nz, .store_cursor

    xor a

.store_cursor:
    ld [wSoundSlotACursor], a
    ret
