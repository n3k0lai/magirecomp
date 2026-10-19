; Copy three bytes from BC into $C9FC, call bank 7 at $7350, and return
; to the opcode dispatcher.
;
; BC is the script pointer left by DispatchScriptOpcode. The three bytes
; land at $C9FC through $C9FE with the auto-increment form. What those
; fields mean is still unknown. BC is saved across the call, so the bank 7
; routine sees the pointer only if it reads the stack.
;
; Bank 7 is stored to wCurrentROMBank and rROMB0, then $7350 runs. hScriptBank
; is written back with the 3-byte load, the same way as the other bank
; restores. Control leaves through jp DispatchScriptOpcode.
;
; wCurrentROMBank, rROMB0, and hScriptBank are the names from reset.asm.

; Three-byte block filled from the script pointer. Its role is still unknown.
DEF wBank7ArgC9FC EQU $C9FC

; Bank 7, still INCBIN. CPU address while bank 7 is mapped.
DEF CopyThreeBank7 EQU $7350

CopyThreeBytesCallBank7::
    ld hl, wBank7ArgC9FC
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call CopyThreeBank7
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop bc
    jp DispatchScriptOpcode
