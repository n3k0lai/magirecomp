; Run a bank-7 script for each nonzero id in the pair at $D134 and $D135.
;
; Each id is copied to $CD8C. $CD8F is pointed at the two-byte buffer $CD91.
; CallBankedHL maps bank 7 and calls $68F8, which is still INCBIN. That call
; leaves a pointer at $CD93. This routine then calls that pointer in bank 7.
; A zero id skips that half. CallBankedHL is the name from call_hl_in_bank.asm.

DEF wPairIdA EQU $D134
DEF wPairIdB EQU $D135
DEF wScriptId EQU $CD8C
DEF wScriptBufPtr EQU $CD8F
DEF wScriptBuf EQU $CD91
DEF wScriptPtr EQU $CD93
DEF PairScriptLookup EQU $68F8
DEF PAIR_SCRIPT_BANK EQU $07

RunPairIdScripts::
    ld a, [wPairIdA]
    and a
    jr z, .second
    ld a, [wPairIdA]
    ld [wScriptId], a
    ld bc, wScriptBuf
    ld hl, wScriptBufPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, PairScriptLookup
    ld e, PAIR_SCRIPT_BANK
    call CallBankedHL
    ld hl, wScriptPtr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, PAIR_SCRIPT_BANK
    call CallBankedHL
.second:
    ld a, [wPairIdB]
    and a
    ret z
    ld a, [wPairIdB]
    ld [wScriptId], a
    ld bc, wScriptBuf
    ld hl, wScriptBufPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, PairScriptLookup
    ld e, PAIR_SCRIPT_BANK
    call CallBankedHL
    ld hl, wScriptPtr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, PAIR_SCRIPT_BANK
    call CallBankedHL
    ret
