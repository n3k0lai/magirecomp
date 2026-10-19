; Bank 7 at $46D0. StepColorWords stores this address when DE is neither
; black ($0000/$8000) nor white ($7FFF/$FFFF) and enters it through JumpHL.
; BC is one little-endian GBC color word (0bbbbbgg gggrrrrr).
;
; SplitRgbFromColorWord leaves red in A, green in E, and blue in D. $4633
; steps each channel one toward the bytes StepColorWords saved at $C82D,
; $C82C, and $C82B, once for each count at $C830, then refills that count
; from wEntryRecord ($C9DC). $459A packs the three channels back into BC.
; Both of those calls are still INCBIN.

DEF StepChannelsTowardSaved EQU $4633

StepColorWordTowardSaved::
    call SplitRgbFromColorWord
    call StepChannelsTowardSaved
    call PackRgbIntoColorWord
    ret
