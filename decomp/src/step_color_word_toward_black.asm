; Bank 7 at $46C6. StepColorWords stores this address when the step in DE
; is $0000 or $8000 and enters it through JumpHL. BC is one little-endian
; GBC color word (0bbbbbgg gggrrrrr).
;
; SplitRgbFromColorWord leaves red in A, green in E, and blue in D. $467E
; decrements each channel that is still above zero, once for each count at
; $C830, then refills that count from wEntryRecord ($C9DC). $459A packs the
; three channels back into BC. Both of those calls are still INCBIN.

DEF StepChannelsTowardZero EQU $467E
DEF PackRgbIntoColorWord EQU $459A

StepColorWordTowardBlack::
    call SplitRgbFromColorWord
    call StepChannelsTowardZero
    call PackRgbIntoColorWord
    ret
