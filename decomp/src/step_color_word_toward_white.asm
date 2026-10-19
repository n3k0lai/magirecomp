; Bank 7 at $46DA. StepColorWords stores this address when the step in DE
; is $7FFF or $FFFF and enters it through JumpHL. BC is one little-endian
; GBC color word (0bbbbbgg gggrrrrr).
;
; SplitRgbFromColorWord leaves red in A, green in E, and blue in D. $46A1
; increments each channel that is still below $1F, once for each count at
; $C830, then refills that count from wEntryRecord ($C9DC). $459A packs the
; three channels back into BC. $46A1 is still INCBIN.

DEF StepChannelsTowardWhite EQU $46A1

StepColorWordTowardWhite::
    call SplitRgbFromColorWord
    call StepChannelsTowardWhite
    call PackRgbIntoColorWord
    ret
