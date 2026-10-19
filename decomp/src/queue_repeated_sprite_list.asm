; Script handler at $1560. The caller is still INCBIN.
;
; The byte at BC is a repeat count. Zero jumps to INITIAL_SCRIPT_HANDLER
; ($0A66). Otherwise the count is stored at $FFA6 with ldh, BC (just past
; that byte) is stored at hScriptPtr with the [hl+] form, and .step is
; planted as hScriptHandler with the 3-byte form. Execution falls into
; .step.
;
; .step reads four script bytes. The first two are stored at $C6D2 and
; $C6D3. The next two are a little-endian pointer, loaded into HL. BC is
; left just past those four bytes. $FFA6 is then decremented.
;
; A remaining count is written back with ldh and QueueSpriteList runs.
; hScriptPtr still names the same four bytes, so the next pass repeats
; them. A count that hits zero stores the advanced BC at hScriptPtr with
; the 3-byte form, runs QueueSpriteList, and plants this entry as
; hScriptHandler so the next pass reads a new count.
;
; What $C6D2 and $C6D3 mean is still unknown. QueueSpriteList does not
; read them. $FFA6 has no name yet. hScriptPtr, hScriptHandler, and
; INITIAL_SCRIPT_HANDLER are the names from reset.asm. QueueSpriteList is
; the routine at $0583.

QueueRepeatedSpriteList::
    ld a, [bc]
    inc bc
    and a
    jp z, INITIAL_SCRIPT_HANDLER

    ldh [$FFA6], a
    ld hl, hScriptPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, LOW(.step)
    ld [hScriptHandler], a
    ld a, HIGH(.step)
    ld [hScriptHandler + 1], a
.step::
    ld h, b
    ld l, c
    ld a, [hl+]
    ld [$C6D2], a
    ld a, [hl+]
    ld [$C6D3], a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld c, l
    ld b, h
    ld l, e
    ld h, d
    ldh a, [$FFA6]
    dec a
    jr z, .last

    ldh [$FFA6], a
    call QueueSpriteList
    ret

.last:
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    call QueueSpriteList
    ld a, LOW(QueueRepeatedSpriteList)
    ld [hScriptHandler], a
    ld a, HIGH(QueueRepeatedSpriteList)
    ld [hScriptHandler + 1], a
    ret
