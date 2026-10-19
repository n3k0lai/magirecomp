; RabbageFootClearD120. Bank 7 at $6E7B (file $01EE7B).
;
; Second pointer of RabbageFootIndexedRecord. RunPairIdScripts calls it
; from $CD93. xor a writes $00 to $D120. What that byte counts is still
; unknown.

RabbageFootClearD120::
    xor a
    ld [$D120], a
    ret
