; Bank 3 at $55E3. DispatchCopiedBlockChoice calls this for a $CCA7
; value other than $FF, $FE, $0B, $0C, or $0D, then starts that loop
; again.
;
; When $CCCB is zero, the byte at $CCFC is loaded and discarded,
; wSoundRequest becomes 1, and RefreshFrame runs. $CCCB is then
; cleared either way. $CCA7 minus 3 indexes the $CCCD table, and that
; byte is stored at $CCFC.
;
; DE is preserved around the compare. The `ld a, a` leaves the table
; byte in A so it can be copied to E. When it differs from
; wSoundIndex, it becomes the new index and wSoundActive is set to 1.
; Either way, wSoundSelect is cleared and wUnknownC92C becomes $0F.
;
; wSoundRequest, wSoundIndex, wSoundActive, and wSoundSelect are the
; names from select_sound_command.asm. wUnknownC92C is the name from
; handle_start_press.asm. CHOICE_BYTES is the name from
; fill_choice_table_from_records.asm. RefreshFrame is already source.

DEF CHOICE_INDEX_BASE EQU $03
DEF SOUND_REQUEST_MARK EQU $01
DEF SOUND_LEVEL_0F EQU $0F

CommitCopiedBlockChoice::
    ld a, [$CCCB]
    cp $00
    jr nz, .storeChoice

    ld a, [$CCFC]
    ld a, SOUND_REQUEST_MARK
    ld [wSoundRequest], a
    call RefreshFrame

.storeChoice:
    ld a, $00
    ld [$CCCB], a
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld c, a
    ld b, $00
    ld hl, CHOICE_BYTES
    add hl, bc
    ld a, [hl]
    ld [$CCFC], a
    push de
    ld a, a
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .indexUnchanged

    ld a, e
    ld [wSoundIndex], a
    ld a, SOUND_REQUEST_MARK
    ld [wSoundActive], a

.indexUnchanged:
    xor a
    ld [wSoundSelect], a
    ld a, SOUND_LEVEL_0F
    ld [wUnknownC92C], a
    pop de
    ret
