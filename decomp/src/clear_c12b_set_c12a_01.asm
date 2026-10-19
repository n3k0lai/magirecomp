; Bank 1 at $60E7. No jump to this address is labeled in the bank 1
; notes; it sits in the hole after FacingUpFromResume60DE's unconditional
; jump. rROMB0 is left alone.
;
; $C12A is the first byte of the eight-byte pattern written by
; WriteC12APattern. $C12B is the second byte. This stores $00 at $C12B
; and $01 at $C12A. SetC12AAndClearC12B stores $FF at $C12A instead.
; What $01 means here is still unknown.
;
; Control then jumps to ResumePlantedHead60FD, which reloads the record,
; runs its script, and branches on the direction bits.
;
; ResumePlantedHead60FD is the label in resume_planted_head_60fd.asm.
; SetC12AAndClearC12B is the label in set_c12a_clear_c12b.asm.
; WriteC12APattern is the name from write_c12a_pattern.asm.

ClearC12BSetC12A01::
    xor a
    ld [$c12b], a
    ld a, $01
    ld [$c12a], a
    jr ResumePlantedHead60FD

ClearC12BSetC12A01End:
