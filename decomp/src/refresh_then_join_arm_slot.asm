; Bank 3 at $5BBA. ResolveArmedListChoice jumps here after choice $0C
; fills the ten SRAM bytes at $A118 with $FF and disables SRAM. The
; return address was popped first, so this entry does not return.
;
; RefreshFrame redraws, then TurnOffLCD blanks the picture. Control
; joins LoadSRAMMarkArmSlot at $5B41, which reads the SRAM mark and
; arms the window slot. This bank stays mapped: RefreshFrame restores
; rROMB0, and TurnOffLCD leaves it alone.

RefreshThenJoinArmSlot::
    call RefreshFrame
    call TurnOffLCD
    jp LoadSRAMMarkArmSlot
