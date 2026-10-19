; LCDC status interrupt vector. The CPU enters here on a STAT condition.
; LCDStat saves AF and HL, then jumps through the handler pointer at $FF99.

LCDCStatus::
    jp LCDStat
