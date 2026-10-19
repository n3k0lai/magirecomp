; Store $02 $14 twice in the slot A selects, then return.
;
; A is the slot index, [$D0B6] at the three callers in the slot walk.
; $38DE, still INCBIN, returns HL at $C1C9 plus A times $1B. This skips
; the first three slot bytes, stores $02 $14, skips five more, and stores
; $02 $14 again. Those are the same pair StoreScriptPair0214 writes into
; a script record. What the skipped slot fields mean is still unknown.
; BC is $0005 on return. HL ends one byte past the second $14.
;
; $38DA is the second store of $14. A caller that enters there already
; has HL on that byte.

StoreSlotPairs0214::
    call $38DE
    inc hl
    inc hl
    inc hl
    ld a, $02
    ld [hl+], a
    ld a, $14
    ld [hl+], a
    ld bc, $0005
    add hl, bc
    ld a, $02
    ld [hl+], a

StoreSlotSecond14::
    ld a, $14
    ld [hl+], a
    ret
