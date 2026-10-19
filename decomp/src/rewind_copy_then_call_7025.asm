; Rewind BC by three, copy the counted block through $1EF5, map bank 3, and call $7025.
;
; CopyPrefixedBlockToD000 skips three bytes, reads a little-endian length
; into BC, copies that many bytes to $D000 in WRAM bank 6, and plants the
; following pointer as the script. The three decrements put that length
; word at the pointer this routine was entered with. Bank 3 is stored to
; wCurrentROMBank and rROMB0, then $7025 runs from that bank. BC is the
; length when that call starts, and this routine returns with whatever
; $7025 left.
;
; $7025 is still INCBIN. Its file address is $00F025. wCurrentROMBank and
; rROMB0 are the names from reset.asm. CopyPrefixedBlockToD000 is the
; routine at $1EF5.

RewindCopyThenCall7025::
    dec bc
    dec bc
    dec bc
    call CopyPrefixedBlockToD000
    ld a, $03
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StageSramListArmSlot
    ret
