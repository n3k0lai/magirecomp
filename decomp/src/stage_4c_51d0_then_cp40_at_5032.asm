; Bank 2 at $5032. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $51D0. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; AddDividerStep then adds a divider-derived step to [$FFA9] and returns
; the new byte in A. cp $40 leaves the carry flag for the next bytes at
; $5040 (RetNcElseCallBank5At4B45): return when A is $40 or more,
; otherwise call bank 5 at $4B45.
;
; StagePointerUnlessD0B6Matches, AddDividerStep, and ScriptStaged51D0
; (bank $4C at $51D0) are already source. The same plant-and-compare
; sequence also lives at $497D, including the bank-5 tail in one routine.

Stage4C51D0ThenCp40At5032::
    ret z
    ld a, $4C
    ld bc, $51D0
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $40
