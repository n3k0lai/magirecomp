; Bank 2 at $5BDC. ClearMarksAndWalkSlots calls here with BC holding the
; record pointer just stored at $D079 and HL = $D0D9. Other callers use
; the same entry with their own BC and HL.
;
; Bank 7 is stored in wCurrentWRAMBank and selected with rSVBK, so the
; copy lands in that bank. Both names come from timer_overflow.asm.
; $37 is the record size used when an index is turned into a pointer at
; $D147. D counts those bytes down. Each step reads [BC], writes [HL+],
; and advances BC. The copy returns when D hits zero.

Copy37ByteRecord::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld d, $37
.copy:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copy
    ret
