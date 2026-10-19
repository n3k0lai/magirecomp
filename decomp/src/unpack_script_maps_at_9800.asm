; Bank 0 at $2D14. CallBankedWordThenResume calls this with BC set to a
; pointer in the bank that caller mapped.
;
; HL takes that pointer. rVBK is set to 1 with the 3-byte form, and
; UnpackBytes writes the first packed stream to the $9800 background map
; (attribute plane). HL is left just past that stream. rVBK is then
; cleared and UnpackBytes writes the next packed stream to the same map
; in VRAM bank 0 (tile plane). rVBK is the name from setup_window.asm.
; UnpackBytes is the name from unpack_bytes.asm.

UnpackScriptMapsAt9800::
    ld h, b
    ld l, c
    ld a, $01
    ld [rVBK], a
    ld de, $9800
    call UnpackBytes
    xor a
    ld [rVBK], a
    ld de, $9800
    call UnpackBytes
    ret
