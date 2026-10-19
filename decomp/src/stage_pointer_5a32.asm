; Bank 2 at $4BD0. The three bytes just before this hole, still INCBIN,
; are `ret z` / `ld a, $4C`. This tail loads the pointer and stages it.
;
; A is the bank ($4C) and BC is $5A32. StagePointerUnlessD0B6Matches
; returns immediately when [$D0B6] equals [$D103]; otherwise it plants
; that bank and pointer.

StagePointer5A32::
    ld bc, $5A32
    call StagePointerUnlessD0B6Matches
    ret
