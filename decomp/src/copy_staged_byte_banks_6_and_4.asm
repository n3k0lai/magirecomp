; Bank 1 handler planted by PlantBank1Handler4552 at hScriptHandler.
; StageEightScriptBytesCopy has already staged the pointers.
;
; The word at $C6FE is a source pointer in DE. The word at $C700 is a
; destination in HL. The source byte is read while WRAM bank 6 is
; selected and written to HL while bank 5 is selected. It is read again
; while bank 4 is selected and written to the same address while bank 3
; is selected. C holds the byte across the bank switch. $C937 mirrors
; rSVBK.
;
; Control then leaves through jp StagedByteEdgeCheck, the same edge
; test CopyStagedByteIntoBanks5And3 runs after its own copy. That test
; is already source.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; StagedByteEdgeCheck is the name from copy_staged_byte_banks_5_and_3.asm.
; PlantBank1Handler4552 is the name from plant_bank1_handler_4552.asm.
; $C6FE and $C700 have no names yet.

CopyStagedByteFromBanks6And4::
    ld a, [$c6ff]
    ld d, a
    ld a, [$c6fe]
    ld e, a
    ld a, [$c701]
    ld h, a
    ld a, [$c700]
    ld l, a
    ld a, $06
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [de]
    ld c, a
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld [hl], c
    ld a, $04
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [de]
    ld c, a
    ld a, $03
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld [hl], c
    jp StagedByteEdgeCheck

CopyStagedByteFromBanks6And4End:
