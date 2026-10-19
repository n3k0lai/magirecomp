; Bank 4 at $628F. LcdOffSetup calls this while $C9BB is zero, after
; CopyVRAMBank1Tiles and before the copies at $6277 and $624E.
;
; CopyHLToDE copies $40 bytes from $C7AB to $CC02. What those two blocks
; hold is still unknown. A later routine in this bank, still INCBIN,
; copies $CC02 back to $C7AB.

CopyC7ABToCC02::
    ld hl, $C7AB
    ld de, $CC02
    ld bc, $0040
    call CopyHLToDE
    ret
