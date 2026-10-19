; Unused zero fill in bank 7 at CPU $750C (file $01F50C).
; Bank7UnusedAt74CC covers the first 64 bytes of the gap that starts at
; $01F4CC. From there through $01FFFF every byte is $00, and nothing in
; this bank jumps here. This slice is the next 64 bytes. The rest stays INCBIN.

Bank7UnusedAt750C::
    ds 64  ; zero fill through CPU $754B
