; Write B ascending bytes at HL, starting from A.
;
; DrawCGBNotice calls this address as WriteTileRun. Each pass stores A,
; then adds one to A and advances HL. B is the remaining count. On return
; B is zero, A is one past the last byte stored, and HL points one past
; the last write. A count of zero wraps and fills 256 bytes.

WriteAscendingBytes::
    ld [hl+], a
    inc a
    dec b
    jr nz, WriteAscendingBytes
    ret
