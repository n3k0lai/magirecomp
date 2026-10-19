; Bank 4 at $4105. Same pointer pair as CopyEntryRecordPrefix: the source
; word at $CD8D and the destination word at $CD8F. Copies all $2D bytes
; of that entry record (ENTRY_RECORD_STRIDE) and returns. It does not
; switch banks. The record table at $415B stays INCBIN.

CopyWholeEntryRecord::
    ld hl, $CD8D
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8F
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld d, ENTRY_RECORD_STRIDE
.copyByte:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyByte
    ret

CopyWholeEntryRecordEnd:
