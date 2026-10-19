; Initial metatile window. FinishStartup calls here with ROM bank 7 mapped,
; after the script loop and before the LCD turns on.
;
; $491F, still INCBIN, runs first. This routine then reads the map pointer it
; leaves at $C861 and the column and row at $C85F and $C860. The pointer is
; a byte address in WRAM bank 3. $C847 is the byte stride from one map row
; to the next.
;
; The window is 11 columns by 10 rows. Each cell loads the metatile id at
; the pointer, calls $4C53, then calls $4CBB. Both are still INCBIN. $4C53
; turns the column, the row, and the id into a $9800 tilemap address and a
; definition pointer. $4CBB copies that metatile's 2x2 tiles and attributes.
; The column and the pointer advance together. The row advances after each
; line, and the pointer restarts at the line plus $C847.
;
; The id is read with WRAM bank 3 mapped. $4CBB selects bank 2 for the
; definitions. Both bank shadows are written: $C937 with the 3-byte form and
; rSVBK with ldh. rSVBK and wCurrentWRAMBank are the names from
; timer_overflow.asm. rVBK is the name from setup_window.asm.
;
; On the way out, VRAM bank 0 is selected with the 3-byte form and WRAM bank
; 0 is selected. `ld a, a` keeps A at zero between those two stores.

; Bank 7, still INCBIN. Copies one metatile from the pointers above.
DEF CopyMetatile EQU $4CBB

; Map bytes live in this WRAM bank. CopyMetatile switches to bank 2.
DEF WRAM_MAP EQU $03

; Map pointer filled by SetupMapOrigin. Low byte first.
DEF wMapPointer EQU $C861

; Column and row passed to MetatilePointers. Column is first.
DEF wMapColumn EQU $C85F

; Added to the map pointer after each row. Carry from the low byte is kept.
DEF wMapRowStride EQU $C847

DrawMetatileWindow::
    call ClampMapCamera
    ld a, [wMapPointer + 1]
    ld h, a
    ld a, [wMapPointer]
    ld l, a
    ld a, [wMapColumn]
    ld d, a
    ld a, [wMapColumn + 1]
    ld e, a
    ld c, $0a

.row
    push hl
    push de
    ld b, $0b

.column
    push bc
    push de
    push hl
    ld a, WRAM_MAP
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl]
    ld c, a
    call BuildMetatilePointers
    call CopyMetatile
    pop hl
    pop de
    pop bc
    inc d
    inc hl
    dec b
    jp nz, .column

    pop de
    inc e
    pop hl
    ld a, [wMapRowStride]
    add l
    ld l, a
    ld a, $00
    adc h
    ld h, a
    dec c
    jp nz, .row

    xor a
    ld [rVBK], a
    ld a, a
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ret
