; SoundActive calls this at $5702 with A holding wSoundIndex ($C920).
; ROM bank $30 stays mapped.
;
; A is compared with the limit byte at $5A87. An index at or above that
; limit returns with the countdown state left alone.
;
; Otherwise the index selects a 3-byte entry. The little-endian word at
; $5A85 is added to $5A79 to reach the entry list, then the index times
; 3 selects the entry. Its first byte is added to the saved bank at
; $DF00 and stored at $DFA9. The next two bytes are a little-endian
; pointer; $84 is added and the sum is stored at $DFA7. $DFA6 is
; cleared, then $45 bytes at $DFB3 are cleared.
;
; $577F fills the countdown step at $DFAA. $3D65 is still INCBIN in
; bank 0. $DFAC is then set to $E4 and bit 7 of $DFA6 is set, which is
; the gate StepSoundCountdowns tests.

DEF wIndexSavedBank EQU $DF00
DEF wIndexCountdownFlags EQU $DFA6
DEF wIndexCountdownTable EQU $DFA7
DEF wIndexCountdownBank EQU $DFA9
DEF wIndexCountdownPack EQU $DFAC
DEF wIndexCountdownRecord EQU $DFB3

DEF IndexEntryOffset EQU $5A85
DEF IndexEntryLimit EQU $5A87

InstallSoundIndex:
    ld hl, IndexEntryLimit
    cp [hl]
    ret nc

    ld d, $00
    ld e, a
    ld h, $00
    ld l, a
    sla l
    rl h
    add hl, de
    ld e, l
    ld d, h
    ld hl, IndexEntryOffset
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, SoundDataHeader
    add hl, bc
    add hl, de
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wIndexSavedBank]
    add b
    ld bc, $0084
    add hl, bc
    ld [wIndexCountdownBank], a
    ld a, h
    ld [wIndexCountdownTable + 1], a
    ld a, l
    ld [wIndexCountdownTable], a
    xor a
    ld [wIndexCountdownFlags], a
    ld hl, wIndexCountdownRecord
    ld bc, $0045

.clear_record:
    xor a
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .clear_record

    call $577f
    call $3d65
    ld a, $e4
    ld [wIndexCountdownPack], a
    ld hl, wIndexCountdownFlags
    set 7, [hl]
    ret
