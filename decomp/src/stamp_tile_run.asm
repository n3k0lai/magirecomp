; Stamp C consecutive tile ids onto a map, starting at HL with id A.
; DE is the stride between cells. Each store uses the next id.
; The start-screen map fill calls this for each horizontal tile run.
StampTileRun::
.loop
    ld [hl], a
    add hl, de
    inc a
    dec c
    jr nz, .loop
    ret
