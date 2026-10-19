; Sample the joypad. VBlank calls this as ReadJoypad. That name is the EQU
; in vblank_handler.asm, so the entry label here is different.
;
; D keeps the previous sample at $C931. Every rP1 access is the 3-byte form.
; $20 selects the d-pad and is read twice; those four bits move to the high
; nibble. $10 selects the buttons and is read six times. After complement, a
; set bit is pressed: low nibble A, B, Select, Start; high nibble Right,
; Left, Up, Down. wButtonsPressed is the name from main_loop.asm.
;
; The new sample is stored at $C931. When A, B, Select, and Start are all
; down, control jumps to $015B, Reset's `ld sp, wStackTop`. Otherwise bits
; that changed are split: wButtonsPressed is newly down, and $C933 is newly
; up. $30 on rP1 releases both select lines.

; rP1 is the name from switch_to_double_speed.asm.
; $20 reads the d-pad, $10 the buttons, $30 neither group.
DEF P1F_GET_DPAD EQU $20
DEF P1F_GET_BTN EQU $10
DEF P1F_GET_NONE EQU $30

; Buttons held. $C932 is wButtonsPressed. $C933 is buttons just released.
DEF wButtonsHeld EQU $C931
DEF wButtonsReleased EQU $C933

; All four low-nibble buttons: A, B, Select, and Start.
DEF BUTTONS_ALL EQU $0F

; Inside Reset, after the model id is stored. Still source, not INCBIN.
DEF ResetAtStack EQU $015B

ReadJoypadSample::
    ld a, [wButtonsHeld]
    ld d, a
    ld a, P1F_GET_DPAD
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and BUTTONS_ALL
    swap a
    ld b, a
    ld a, P1F_GET_BTN
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and BUTTONS_ALL
    or b
    ld [wButtonsHeld], a
    ld c, a
    and BUTTONS_ALL
    cp BUTTONS_ALL
    jr nz, .edges
    jp ResetAtStack
.edges:
    ld a, c
    xor d
    ld e, a
    and c
    ld [wButtonsPressed], a
    ld a, c
    cpl
    and e
    ld [wButtonsReleased], a
    ld a, P1F_GET_NONE
    ld [rP1], a
    ret
