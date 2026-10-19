; Copy nineteen bytes from the scaled group address into the list pointer.
;
; ScanGroupBytes stores the scaled offset plus the addend at wGroupScaled
; and points wGroupListPtr at $CD91 before calling here for index 6, with
; ROM bank 7 mapped. The thirteen indexes later read from $CD97 begin six
; bytes into this run. What those first six bytes are is still unknown.
; wGroupScaled and wGroupListPtr are the names from scan_group_bytes.asm.

; Length of the copy. $CD91 plus this reaches one past $CDA3.
DEF GROUP_SCALED_BYTES EQU $13

CopyScaledGroupBytes::
    ld hl, wGroupListPtr
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, [wGroupScaled + 1]
    ld h, a
    ld a, [wGroupScaled]
    ld l, a
    ld d, GROUP_SCALED_BYTES
.byte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .byte

    ret

CopyScaledGroupBytesEnd:
