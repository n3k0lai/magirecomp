; Bank 2 at $5040. The cp $40 is the byte before this range, still in
; the hole. Return when that compare did not borrow (A is $40 or more).
; Otherwise call bank 5 at $4B45 through CallBankedHL and return.
; CallBankedHL is already source.

RetNcElseCallBank5At4B45::
    ret nc
    ld hl, $4B45
    ld e, $05
    call CallBankedHL
    ret
