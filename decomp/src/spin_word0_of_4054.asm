; Word 0 of the bank 5 pointer table at $4054 ($5909, $4F54, $4B51, $5553, …).
; CallWordAt4054ForD104 loads that word into HL and calls JumpHL, so this
; is the destination when [$D104] is 0. The only instruction is jr to this
; label, so the CPU spins here. $590B, the next byte, is a different routine.

SpinWord0Of4054::
    jr SpinWord0Of4054
