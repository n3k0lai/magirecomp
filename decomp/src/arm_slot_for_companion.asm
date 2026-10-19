; Arm the slot whose companion byte is A, if one matches.

ArmSlotForCompanion::
    call FindSlotForCompanion
    jp nz, ArmChannelAfterCountdown
    ret
