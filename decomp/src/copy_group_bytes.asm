; Copy $22 bytes for group indexes 3 and 4.
;
; ScanGroupBytes stores the source word at wGroupScaled ($CD8D) and points
; wGroupListPtr ($CD8F) at $CD91, then calls this in bank 7. The $22 bytes
; land at that list. The later block copy for these indexes reads from
; $CD9D, which sits inside the span. Nothing else in this routine is used.

DEF GROUP_BYTE_COUNT EQU $22

CopyGroupBytes::
    ld hl, wGroupListPtr
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, wGroupScaled
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, GROUP_BYTE_COUNT
.copy:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy

    ret

CopyGroupBytesEnd:
