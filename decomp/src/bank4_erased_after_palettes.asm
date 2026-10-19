; Bank 4 at $4038. Erased $FF bytes after the seven RGB555 palettes
; at $4000. One unused palette slot would end at $403F; the fill
; continues through $4077, where the following zero bytes begin.
; Nothing here calls or jumps.

Bank4ErasedAfterPalettes::
    ds 64, $FF ; unused bytes $4038-$4077, each $FF
