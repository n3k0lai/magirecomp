; Bank 2 at $762B. PlantFocusThenCopyD0D9ByOperand, the SummonX and
; item paths, and CopyD393RecordThenDispatch call here before they
; write their own records.
;
; [$D392] is the record index. IndexTimes37PlusD147 returns
; HL = $D147 + index * $37. That pointer is moved to BC and HL is set
; to $D0D9, so Copy37ByteRecord copies the slot into the staging record.
; [$D0B1] is then set to $FF and this returns.
;
; IndexTimes37PlusD147 and Copy37ByteRecord are already source.

CopyD392RecordIntoD0D9::
    ld a, [$D392]
    call IndexTimes37PlusD147
    ld b, h
    ld c, l
    ld hl, $D0D9
    call Copy37ByteRecord
    ld a, $FF
    ld [$D0B1], a
    ret
