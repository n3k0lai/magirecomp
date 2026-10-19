; Bank 3 at $76E0. StepFeChoiceByCce3 calls this when $CCE3 is 0.
;
; The ten mark bytes are $CCD6 + 3 through index $0C, which is
; $CCD9-$CCE2. PaintMapAttrsSeedSlot plants those ten as $00.
; CopyChoiceRecordTiles writes $01 at $CCD6 + slot + 3 when a choice
; slot is copied. E starts at 3 and walks those bytes. A byte equal
; to $01 returns A = 1. C is loaded with the last index, $0C, and
; then incremented, so a miss stops when E reaches $0D and returns
; A = 0. The caller treats that zero as "force $CCE3 to 3".
;
; wArmedSlotRecord is the name from paint_map_attrs_seed_slot.asm.
; SLOT_MARK_BIAS and SLOT_MARK_COPIED are the names from
; copy_choice_record_tiles.asm.

; Last index read. The compare uses one past this value.
DEF SCAN_MARK_LAST EQU $0C

ScanArmedSlotMarks::
    ld hl, wArmedSlotRecord
    ld e, SLOT_MARK_BIAS
    ld d, $00
    add hl, de
    ld c, SCAN_MARK_LAST
    inc c
.mark:
    ld a, [hl+]
    cp SLOT_MARK_COPIED
    jr z, .found
    inc e
    ld a, e
    cp c
    jr nz, .mark
    xor a
    ret

.found:
    ld a, SLOT_MARK_COPIED
    ret
