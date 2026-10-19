; FillCountdownStep calls this at $3D4A. The bank at $DFA9 is mapped,
; then the big-endian word four bytes after the countdown table at
; $DFA7 is loaded into HL. That word is what FillCountdownStep scales
; into the countdown step at $DFAA.
;
; Control leaves through MapRomBank with A = [$DF00], which restores
; the bank saved before the table was read. MapRomBank preserves HL.
;
; $DFA7, $DFA9, and $DF00 are the names from step_indexed_countdown.asm.

DEF wScaleTable EQU $DFA7
DEF wScaleBank EQU $DFA9
DEF wScaleSavedBank EQU $DF00

ReadCountdownScaleWord:
    ld a, [wScaleBank]
    call MapRomBank
    ld a, [wScaleTable]
    ld l, a
    ld a, [wScaleTable + 1]
    ld h, a
    ld bc, $0004
    add hl, bc
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    ld a, [wScaleSavedBank]
    jp MapRomBank
