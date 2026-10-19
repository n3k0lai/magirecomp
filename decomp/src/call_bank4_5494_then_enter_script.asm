; Map bank 4, call $5494, then either enter the script at BC or copy a block.
;
; Bank 4 is stored to wCurrentROMBank and rROMB0, and $5494 runs from that
; bank. hScriptBank is written back to both bank registers. A nonzero byte
; at $CD1F leaves through EnterScriptFromLookup, which reads a bank and a
; pointer from the BC this routine was entered with.
;
; A zero byte advances BC by three and saves it. CopyPrefixedBlockToD000
; skips three more bytes, copies the length-prefixed block to $D000, and
; clears BC, so the saved pointer is restored after the copy. Bank 4 is
; mapped again and $5926 is called. A nonzero byte at $CD49 returns with
; that saved BC. A zero byte maps hScriptBank again and leaves through
; EnterScriptFromLookup.
;
; What $CD1F and $CD49 mean is still unknown. $5494 and $5926 are still
; INCBIN. Their file addresses are $011494 and $015926. wCurrentROMBank,
; rROMB0, and hScriptBank are the names from reset.asm.
; CopyPrefixedBlockToD000 is the routine at $1EF5. EnterScriptFromLookup
; is the routine at $1465.

; Bank 4, still INCBIN. CPU address while that bank is mapped.
DEF Bank4_5494 EQU $5494

; Nonzero after $5494 skips the copy and enters the script at the original BC.
DEF wUnknownCD1F EQU $CD1F

; Nonzero after $5926 returns instead of entering the script.
DEF wUnknownCD49 EQU $CD49

CallBank4_5494ThenEnterScript::
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Bank4_5494
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wUnknownCD1F]
    and a
    jp nz, EnterScriptFromLookup
    inc bc
    inc bc
    inc bc
    push bc
    call CopyPrefixedBlockToD000
    ld a, $04
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StageCopiedBlockWindow
    pop bc
    ld a, [wUnknownCD49]
    and a
    ret nz
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp EnterScriptFromLookup
