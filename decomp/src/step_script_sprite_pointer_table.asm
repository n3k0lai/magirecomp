; Script handler at $15E8. The caller is still INCBIN.
;
; $FFA7 is cleared. The byte after BC is stored at $FFA6 with ldh, and BC
; stays on the first byte. .step is planted as hScriptHandler with the
; 3-byte form. Execution falls into .step.
;
; .step skips those two header bytes, copies the next two script bytes to
; $C6D2 and $C6D3, then adds $FFA7 to HL. $FFA6 is decremented. A remaining
; count is written back with ldh. A count that hits zero reads the first
; header byte and compares it with $FFA7 + 2. A smaller index is stored
; at $FFA7 and the second header byte is reloaded into $FFA6. An equal
; index copies HL into BC, skips the pointer there, stores that address at
; hScriptPtr (high byte first, 3-byte form), and plants
; INITIAL_SCRIPT_HANDLER.
;
; Either path then loads the little-endian word at HL and calls
; QueueSpriteList.
;
; The record is a table-length byte, a repeat count, two bytes copied to
; $C6D2 and $C6D3, then that many bytes of sprite-list pointers. $FFA7 is
; the table offset and starts at zero. What $C6D2 and $C6D3 mean is still
; unknown. QueueSpriteList does not read them. $FFA6 and $FFA7 have no
; names yet. hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are
; the names from reset.asm. QueueSpriteList is the routine at $0583.

StepScriptSpritePointerTable::
    xor a
    ldh [$FFA7], a
    inc bc
    ld a, [bc]
    dec bc
    ldh [$FFA6], a
    ld a, LOW(.step)
    ld [hScriptHandler], a
    ld a, HIGH(.step)
    ld [hScriptHandler + 1], a
.step::
    ld h, b
    ld l, c
    inc hl
    inc hl
    ld a, [hl+]
    ld [$C6D2], a
    ld a, [hl+]
    ld [$C6D3], a
    ldh a, [$FFA7]
    ld e, a
    ld d, $00
    add hl, de
    ldh a, [$FFA6]
    dec a
    jr z, .countDone

    ldh [$FFA6], a
    jr .queue

.countDone:
    ld a, [bc]
    inc bc
    ld e, a
    ldh a, [$FFA7]
    inc a
    inc a
    cp e
    jr z, .tableDone

    ldh [$FFA7], a
    ld a, [bc]
    ldh [$FFA6], a
    jr .queue

.tableDone:
    ld b, h
    ld c, l
    inc bc
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
.queue:
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call QueueSpriteList
    ret
