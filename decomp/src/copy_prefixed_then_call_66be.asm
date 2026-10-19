; Copy the prefixed block at BC to $D000, map bank 3, and call $66BE.
;
; CopyPrefixedBlockToD000 reads the length at BC, copies that many bytes
; to $D000 in WRAM bank 6, and plants the following pointer as the script.
; Bank 3 is stored to wCurrentROMBank and rROMB0, then $66BE runs from that
; bank. This routine returns with whatever $66BE left.
;
; $66BE is still INCBIN. Its file address is $00E6BE. wCurrentROMBank and
; rROMB0 are the names from reset.asm. CopyPrefixedBlockToD000 is the
; routine at $1EF5.

CopyPrefixedBlockThenCall66BE::
    call CopyPrefixedBlockToD000
    ld a, $03
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call SetupPrefixedBlockChoice
    ret
