; RetAt5C1C. Bank 2 at $5C1C.
;
; A lone `ret` between SpendD110MeasureHundred and
; ReturnAfterD110SramOff. The previous routine already returned, so
; execution does not fall through. LoadD110Record calls the next byte,
; $5C1D, after it writes zero to rRAMG.

RetAt5C1C::
    ret
