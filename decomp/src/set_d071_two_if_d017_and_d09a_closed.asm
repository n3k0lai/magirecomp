; Bank 2 at $504A. A zero [$D017], or a nonzero [$D09A], jumps to
; $505C, still in the hole. Both the other way stores 2 at [$D071]
; and returns. Zero at $D09A is the closed mark used by the $D016 paths.

SetD071TwoIfD017AndD09AClosed::
    ld a, [$D017]
    and a
    jr z, $505C
    ld a, [$D09A]
    and a
    jr nz, $505C
    ld a, $02
    ld [$D071], a
    ret
