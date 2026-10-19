; Bank 4 at $6ABF. SeedRowMaskAndRecord stores this address at $C9F2
; as the step routine. This routine does not write rROMB0.
;
; $C9FA is the index limit planted before that setup. $C9F9 is the index,
; seeded to $FF. $C9FB is a countdown, seeded to $7A and reloaded to $80
; here. The word at $C9F6 is a VRAM address, seeded to $9000.
;
; If the index already equals the limit, return. Otherwise decrement the
; countdown. When it reaches zero, reload $80 and increment the index. If
; the index then equals the limit, return without stepping. Otherwise call
; $6A5E (still in this bank), then add $10 to the VRAM word. A high byte
; of $98 is stored as $90, so the pointer stays in $9000-$97FF.

; Countdown stored at $C9FB after it reaches zero.
DEF ROW_STEP_RELOAD EQU $80

; Bytes added to the word at $C9F6. One 2bpp tile.
DEF ROW_STEP_STRIDE EQU $10

; High byte just past the $9000 tile bank, and the high byte it wraps to.
DEF ROW_STEP_VRAM_PAST EQU $98
DEF ROW_STEP_VRAM_BASE EQU $90

StepRowMaskVram::
    ld a, [$C9FA]
    ld l, a
    ld a, [$C9F9]
    cp l
    ret z
    ld a, [$C9FB]
    dec a
    ld [$C9FB], a
    jr nz, .copy
    ld a, ROW_STEP_RELOAD
    ld [$C9FB], a
    ld a, [$C9F9]
    inc a
    ld [$C9F9], a
    cp l
    ret z
.copy:
    call ApplyIndexedRowMask
    ld a, [$C9F6]
    add a, ROW_STEP_STRIDE
    ld [$C9F6], a
    ld a, [$C9F7]
    adc a, $00
    cp ROW_STEP_VRAM_PAST
    jr nz, .store_high
    ld a, ROW_STEP_VRAM_BASE
.store_high:
    ld [$C9F7], a
    ret
