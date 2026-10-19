; Loop the start-button hook jumps to. It does not return to GameLoop.
;
; Each pass hides leftover sprites. When $CC4B is 1, the LCD turns off,
; $61F1 and $5F0A run in this bank, and the LCD turns back on. Bank 3's
; $4100 runs. If Right or Left is down and $CD81 is $1C or $1D, the
; just-pressed mask is replaced with $04, the Select bit. Bank 3's $41E3
; runs, RefreshFrame runs, and control jumps back here.
;
; HideLeftoverSprites, TurnOffLCD, TurnOnLCDIfOff, CallBankedHL, and
; RefreshFrame are already source. wButtonsPressed is the name from
; main_loop.asm. wUnknownCD81 and Bank6_61F1 are the names from
; handle_start_press.asm. The button layout is the one in read_joypad.asm.
; `cp $01` is the two-byte compare. `set 2, a` after `xor a` leaves A as $04.

; Nonzero-as-1 selects the LCD-off calls. Role still unknown.
DEF wUnknownCC4B EQU $CC4B

DEF BANK_AFTER_START EQU $03
DEF Far_4100 EQU $4100
DEF Far_41E3 EQU $41E3

; $CD81 values that rewrite the button mask. $1E is the first value past them.
DEF CD81_REWRITE_LO EQU $1C
DEF CD81_REWRITE_HI EQU $1E

; Bit 4 is Right and bit 5 is Left. Bit 2 is Select.
DEF JOY_RIGHT EQU 4
DEF JOY_LEFT EQU 5
DEF JOY_SELECT EQU 2

AfterStartLoop::
    call HideLeftoverSprites
    ld a, [wUnknownCC4B]
    cp $01
    jr nz, .bank3_4100
    call TurnOffLCD
    call Bank6_61F1
    call StampSetupAttributes
    call TurnOnLCDIfOff
.bank3_4100:
    ld hl, Far_4100
    ld e, BANK_AFTER_START
    call CallBankedHL
    ld a, [wButtonsPressed]
    bit JOY_RIGHT, a
    jr nz, .maybe_rewrite
    bit JOY_LEFT, a
    jr z, .bank3_41e3
.maybe_rewrite:
    ld a, [wUnknownCD81]
    cp CD81_REWRITE_LO
    jr c, .bank3_41e3
    cp CD81_REWRITE_HI
    jr nc, .bank3_41e3
    xor a
    set JOY_SELECT, a
    ld [wButtonsPressed], a
.bank3_41e3:
    ld hl, Far_41E3
    ld e, BANK_AFTER_START
    call CallBankedHL
    call RefreshFrame
    jp AfterStartLoop
