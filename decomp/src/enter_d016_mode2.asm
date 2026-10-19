; Bank 2 at $5CBC. RefreshSlotForLowD103 jumps here when [$D103] is $0A
; or at least $0C. A = 2 selects the DispatchNonzeroD016 path that stores
; 2 in wSoundIndex ($C920) before that routine continues into startup.
; The block after this jump is a different writer; it tails back here.

EnterD016Mode2::
    ld a, $02
    jp DispatchNonzeroD016
