; Bank 7 at $72F0. IndexedIdRecords5D index 1 stores this address as
; the word in BC. The bytes are a routine.
;
; CallBankedHL runs bank 5 SetD0B4UnlessD113Is0C. AddDividerStep then
; adds a divider-derived step to hDividerAccum ($FFA9) and returns the
; new byte in A. cp $E6 sets the flags for the caller. ret nc leaves
; when that byte is $E6 or more; the following ret covers the rest.
; Both exits return here, and both keep the flags from that compare.
;
; SetD0B4UnlessD113Is0C, CallBankedHL, AddDividerStep, and
; hDividerAccum are already source.

CallSetD0B4ThenDividerCpE6::
    ld hl, SetD0B4UnlessD113Is0C
    ld e, $05
    call CallBankedHL
    call AddDividerStep
    cp $E6
    ret nc
    ret

CallSetD0B4ThenDividerCpE6End:
