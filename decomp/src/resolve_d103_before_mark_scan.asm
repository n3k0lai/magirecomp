; Bank 2 at $7366. PickD091MarkIntoD103 calls this before it reads $D0C9.
;
; [$D0C9] is set to 1, so the caller returns unless this clears it.
; [$D103] of $14 or more, and $0B, keep that flag and the index.
;
; $0A treats the word at $D079 as a pointer into the $37-byte records
; that start at $D147. DivideHLByA of that offset by $37 replaces
; [$D103], and the flag stays set.
;
; $11 reads the first byte of the record copy at $D110. A nonzero byte
; stores index 0; zero stores index 9. The flag stays set.
;
; Every other index clears [$D0C9] so the caller continues its scan.
; DivideHLByA is already source.

ResolveD103BeforeMarkScan::
    ld a, $01
    ld [$D0C9], a
    ld a, [$D103]
    cp $14
    ret nc
    cp $0A
    jr nz, .notPointerIndex
    ld hl, $D079
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld bc, $D147
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, $37
    call DivideHLByA
    ld [$D103], a
    ret
.notPointerIndex:
    cp $0B
    ret z
    cp $11
    jr nz, .clearHandled
    ld a, [$D110]
    and a
    jr z, .storeNine
    xor a
    ld [$D103], a
    ret
.storeNine:
    ld a, $09
    ld [$D103], a
    ret
.clearHandled:
    xor a
    ld [$D0C9], a
    ret
