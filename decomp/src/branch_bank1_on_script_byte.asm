; Plant INITIAL_SCRIPT_HANDLER ($0A66) and branch in bank 1 on one script byte.
;
; The handler stores and the pointer stores are ldh. The byte at BC is
; tested with `and a`, then BC advances and is saved at hScriptPtr. The
; loads that follow leave that zero flag alone. Bank 1 is stored to
; wCurrentROMBank and rROMB0. A zero byte jumps to $466D. Any other byte
; jumps to $46B2. Both targets are still INCBIN. Their file addresses
; are $00466D and $0046B2. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names from
; reset.asm.

BranchBank1OnScriptByte::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, [bc]
    inc bc
    and a
    ld a, b
    ldh [hScriptPtr + 1], a
    ld a, c
    ldh [hScriptPtr], a
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp z, FillSRAMAfterZeroScriptByte
    jp FillSRAMAfterNonzeroScriptByte
