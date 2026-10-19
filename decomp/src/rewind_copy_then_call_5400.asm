; Rewind BC by three, copy the counted block through $1EF5, map bank 3, and call $5400.
;
; $1EF5 adds three to BC before it reads the length word, copies that many
; bytes to $D000 in WRAM bank 6, and saves the pointer that follows. The
; three decrements put that length word at the pointer this routine was
; entered with. Bank 3 is stored to wCurrentROMBank and rROMB0, then $5400
; runs from that bank. BC is left as $1EF5 returned it.
;
; $1EF5 and $5400 are still INCBIN. The file address of $5400 is $00D400.
; wCurrentROMBank and rROMB0 are the names from reset.asm.

RewindCopyThenCall5400::
    dec bc
    dec bc
    dec bc
    call CopyPrefixedBlockToD000
    ld a, $03
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StageCopiedBlockArmSlot
    ret
