; Jump to the address in HL.
;
; Callers reach this with call, so the return address is already on the
; stack. jp hl enters the pointer, and that routine's ret returns to the
; caller. The timer overflow handler and the banked call at $0773 both
; enter a pointer this way. timer_overflow.asm names this address CallHL.

JumpHL::
    jp hl
