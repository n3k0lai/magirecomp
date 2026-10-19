; Bank 4 at $71A6. InstallScriptRecordLoopBank4 calls this on every
; pass of the bank 4 loop, after the script record is installed.
; Bank 4 is already mapped. This routine does not write rROMB0.
;
; [$C9C6] must be nonzero or the call returns at once. Bit 1 of
; wButtonsPressed is B just pressed; that path calls $71CE and
; returns. Bit 3 is Start just pressed. When Start is not newly
; down the call returns. Otherwise [$C9C7] flips: zero becomes 1,
; and any other value becomes 0. The `cp $00` is the bytes in the ROM.
;
; wButtonsPressed is the name from main_loop.asm. What $C9C6, $C9C7,
; and $71CE mean is still unknown.

; Nonzero lets this pass read the joypad edge. Role still unknown.
DEF wScriptLoopGate EQU $C9C6

; Toggled when Start was just pressed. Role still unknown.
DEF wScriptLoopToggle EQU $C9C7

PollScriptLoopButtons::
    ld a, [wScriptLoopGate]
    and a
    ret z
    ld a, [wButtonsPressed]
    bit 1, a
    jr z, .check_start
    call HandleScriptLoopB
    ret
.check_start:
    ld a, [wButtonsPressed]
    bit 3, a
    ret z
    ld a, [wScriptLoopToggle]
    cp $00
    jr nz, .clear
    ld a, $01
    ld [wScriptLoopToggle], a
    ret
.clear:
    xor a
    ld [wScriptLoopToggle], a
    ret
