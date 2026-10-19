; Continuation at $19E8. MapBank7Call41CB jumps here after the bank 7
; call returns and BC is popped. Other tails in the following INCBIN also
; jump here.
;
; $C6E4 is wCallback and $C6E6 is its bank, the names from default_state.asm.
; Both are set to $4575 in bank 7. That routine is still INCBIN. Its file
; address is $01C575. What it does is still unknown.
;
; $FFA7 is a countdown. While it is above 1, this stores the decremented
; value and returns. When the decrement reaches zero, $CCA6 is cleared, BC
; is saved as hScriptPtr, and hScriptHandler becomes INITIAL_SCRIPT_HANDLER
; ($0A66). Those names are from reset.asm. The pointer and handler stores
; are the 3-byte form.
;
; $1A00 is also an entry: A is stored at $CCA6, then this falls through.
; $1A08 is an entry with A already the low byte of the script pointer.

; Bank 7 callback planted at wCallback. Still INCBIN.
DEF BANK_CALLBACK_4575 EQU $07
DEF Bank7Callback4575 EQU $4575

StepBank7CallbackCountdown::
    ld a, BANK_CALLBACK_4575
    ld [wCallbackBank], a
    ld a, LOW(Bank7Callback4575)
    ld [wCallback], a
    ld a, HIGH(Bank7Callback4575)
    ld [wCallback + 1], a
    ldh a, [$ffa7]
    dec a
    jr z, .countdownDone

    ldh [$ffa7], a
    ret

.countdownDone:
    xor a

StoreAAtCCA6ThenPlantHandler::
    ld [$cca6], a
    ld a, b
    ld [$ffa3], a
    ld a, c

PlantInitialHandlerFromLowPtr::
    ld [$ffa2], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [$ffa4], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [$ffa5], a
    ret
