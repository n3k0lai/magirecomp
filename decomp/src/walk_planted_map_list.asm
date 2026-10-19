; Bank 3 at $6C1A. SetupPrefixedBlockChoice calls here after
; PlantOneMapListEntry writes the one-entry list at wOneEntryList.
; This bank stays mapped. Nothing here calls out.
;
; The first byte is the entry count. Each entry is a destination pointer,
; high byte then low byte. LIST_MARK minus the entries still waiting
; equals 1 for the selected entry. Every other entry copies the next
; four list bytes onto that pointer and continues. A remaining count of
; zero returns.
;
; The unconditional jump back to the next entry always runs, so the
; following conditional jump and return are not reached.
;
; The selected entry stores 5 in LIST_MARK, then fills $15 bytes with
; tile $80 starting $0F bytes before the destination, and returns.
; LIST_MARK and wOneEntryList are already named.

DEF SELECTED_MARK EQU $05
DEF TILE_BEFORE EQU $0F
DEF FILL_TILE EQU $80
DEF FILL_COUNT EQU $15

WalkPlantedMapList::
    ld hl, wOneEntryList
    ld a, [hl+]
    ld e, a
.nextEntry:
    dec e
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [LIST_MARK]
    sub e
    cp $01
    jr z, .selected
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, e
    cp $00
    ret z
    jr .nextEntry
    jr nz, .nextEntry
    ret
.selected:
    ld a, SELECTED_MARK
    ld [LIST_MARK], a
    ld e, TILE_BEFORE
    ld a, c
    sub e
    jr nc, .fillStart
    dec b
.fillStart:
    ld h, b
    ld l, a
    ld d, FILL_TILE
    ld a, FILL_COUNT
    ld b, $00
.fill:
    ld [hl], d
    inc hl
    dec a
    cp b
    jr nz, .fill
    ret

WalkPlantedMapListEnd:
