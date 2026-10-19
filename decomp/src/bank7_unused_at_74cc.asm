; Unused zero fill in bank 7 at CPU $74CC (file $01F4CC).
; FloorAMinusCDisableSRAM returns at file $01F4CB. From $01F4CC through
; $01FFFF every byte is $00, and nothing in this bank jumps here.
; This slice is the first 64 bytes of that gap. The rest stays INCBIN.

Bank7UnusedAt74CC::
    ds 64  ; zero fill through CPU $750B
