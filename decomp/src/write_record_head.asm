; Bank 1 at $410A. The record pointer lives at $FF8A (low) and $FF8B
; (high), the same word CopyRecordToScratch reads with `ldh`.
; hRecordPointer is defined in copy_record_to_scratch.asm.
;
; $FF8C through $FF95 are the next ten bytes. This stores them, in
; order, through that pointer. What each of those ten bytes means is
; still unknown. The rest of the $1B-byte record is left alone.

DEF hRecordHead EQU hRecordPointer + 2

WriteRecordHead::
    ldh a, [hRecordPointer]
    ld l, a
    ldh a, [hRecordPointer + 1]
    ld h, a
    ldh a, [hRecordHead]
    ld [hl+], a
    ldh a, [hRecordHead + 1]
    ld [hl+], a
    ldh a, [hRecordHead + 2]
    ld [hl+], a
    ldh a, [hRecordHead + 3]
    ld [hl+], a
    ldh a, [hRecordHead + 4]
    ld [hl+], a
    ldh a, [hRecordHead + 5]
    ld [hl+], a
    ldh a, [hRecordHead + 6]
    ld [hl+], a
    ldh a, [hRecordHead + 7]
    ld [hl+], a
    ldh a, [hRecordHead + 8]
    ld [hl+], a
    ldh a, [hRecordHead + 9]
    ld [hl+], a
    ret

WriteRecordHeadEnd:
