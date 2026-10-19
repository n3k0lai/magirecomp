; Select VRAM bank 1 and copy 512 bytes from $CA02 back onto tiles $E0-$FF.
;
; LoadBothVRAMBanks calls this through CallBankedHL after the LCD is off
; and before it fills $9000 from WRAM bank 4. HL is the source and BC is
; the destination. CopyRows20By10 copies $20 rows of $10 bytes.
;
; CopyVRAMBank1Tiles saved these tiles the other way, from $8E00 into
; $CA02. $8E00 is tiles $E0-$FF of the $8000 pattern table. The store to
; rVBK is the 3-byte form. rVBK is the name from setup_window.asm.
; wUnknownCA02 and vTilesE0 are the names from copy_vram_bank1_tiles.asm.
; CopyRows20By10 is already source in this bank.

RestoreVRAMBank1Tiles::
    ld a, $01
    ld [rVBK], a
    ld hl, wUnknownCA02
    ld bc, vTilesE0
    call CopyRows20By10
    ret
