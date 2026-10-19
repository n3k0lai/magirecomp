; Read SRAM $A122 and set $CD1F when that byte is at least $D0.
;
; Called from CallBank4_5494ThenEnterScript after bank 4 is mapped. BC is
; saved and restored. $CD1F is cleared first. SRAM bank $C727 is selected.
; `add a, $00` keeps that bank byte and its flags; nothing reads them.
; SRAM is enabled only long enough to copy $A122 into B, then disabled.
;
; A byte below $D0 leaves $CD1F clear, so the caller copies a length-prefixed
; block before entering the script. A byte of $D0 or more stores 1 at $CD1F,
; and the caller enters the script at the original BC.
;
; $A122 is sEntryIdsEnd from indexed_tail_07.asm, the byte just past the
; ten-id list at $A118. What $D0 means on that byte is still unknown.
; wUnknownCD1F is the name from call_bank4_5494_then_enter_script.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. This routine does not call out.

; Byte at $A122 that makes the caller skip the prefixed-block copy.
DEF ENTRY_END_DIRECT EQU $D0

FlagDirectScriptFromEntryEnd::
    push bc
    xor a
    ld [wUnknownCD1F], a
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [$A122]
    ld b, a
    xor a
    ld [rRAMG], a
    ld a, b
    cp ENTRY_END_DIRECT
    jr c, .below
    ld a, $01
    ld [wUnknownCD1F], a
.below
    pop bc
    ret
