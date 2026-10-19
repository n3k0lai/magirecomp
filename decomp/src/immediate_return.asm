; Bank 1 at $47B8. The previous routine, BlankWindowCornerBlock, already
; returns at $47B7. This byte is a second ret. Nothing in the lifted
; source stores this address, so what calls it is still unknown.

ImmediateReturn::
    ret
