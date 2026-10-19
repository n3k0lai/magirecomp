; Copy a 20-by-10 tilemap for the setup index in $CC47.
;
; IndexedSetup calls this before the indexed tails. This bank stays mapped.
; VRAM bank 0 is selected, so the writes are tile ids. $CC47 times two
; selects a pointer in the table at $51C1, still INCBIN. That pointer is
; the source. Ten rows of twenty bytes are written at $9C20. Each row is
; one BG-map line: after twenty stores, twelve bytes are added so the next
; row starts $20 bytes later. A zero row count returns.
;
; rVBK is the name from setup_window.asm. The store is the 3-byte form.
; wUnknownCC47 is the name from handle_start_press.asm, included later,
; so this file uses the address.

DEF MAP_COLS EQU $14
DEF MAP_ROWS EQU $0A
; $20 map stride minus the twenty bytes the column loop already advanced.
DEF MAP_ROW_SKIP EQU $000C
DEF vIndexedMap EQU $9C20
; Word table of sources. Still INCBIN in this bank.

CopyIndexedMap::
    xor a
    ld [rVBK], a
    ld a, [$CC47]
    add a
    ld c, a
    ld b, $00
    ld hl, IndexedMapSources
    add hl, bc
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, vIndexedMap
    ld d, MAP_ROWS
.nextRow:
    ld e, MAP_COLS
.col:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec e
    jr nz, .col
    dec d
    jr z, .done
    push de
    ld de, MAP_ROW_SKIP
    add hl, de
    pop de
    jr .nextRow
.done:
    ret
