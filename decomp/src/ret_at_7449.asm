; RetAt7449. Bank 2 at $7449.
;
; A lone `ret` between Load5EFERecordThenGroupDispatch and
; PlantFocusThenCopyD0D9ByOperand. The previous routine already
; returned, so execution does not fall through. Opcode29 is `jp $7449`
; and does not switch banks, so this byte runs when bank 2 is mapped.

RetAt7449::
    ret
