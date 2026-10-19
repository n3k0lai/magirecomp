; Bank 2 at $4ADC. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $576A through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $576A is file $013176A and is still INCBIN.

Stage4C576AUnlessZeroAt4ADC::
    ret z
    ld a, $4C
    ld bc, $576A
    call StagePointerUnlessD0B6Matches
    ret

Stage4C576AUnlessZeroAt4ADCEnd:
