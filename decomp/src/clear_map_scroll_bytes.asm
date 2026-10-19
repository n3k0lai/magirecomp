; Bank 4 at $63D9. Opcode25Bank4 and the routine at $6439 both call this.
;
; A is zeroed into the row- and column-load countdowns and latches, the
; horizontal and vertical scroll deltas, and five more WRAM bytes. $C9AF and
; $C9B0 are the values later copied to the camera X/Y and to rSCX/rSCY.
; $C9AE, $C831, and $C9AD are still unnamed. $C9B3-$C9BA are then filled
; with $F0. The meaning of that eight-byte block is still unknown.
;
; wRowLoadCount and wRowLoadLatch are the names from load_scrolled_row.asm.
; wColumnLoadLatch is the name from opcode_03_continue.asm. $C891 is the
; column-load countdown those routines read. $C843 and $C844 are the scroll
; deltas cleared by FinishFrame.

ClearMapScrollBytes::
    xor a
    ld [wRowLoadCount], a
    ld [$C891], a
    ld [wRowLoadLatch], a
    ld [wColumnLoadLatch], a
    ld [$C843], a
    ld [$C844], a
    ld [$C9AF], a
    ld [$C9B0], a
    ld [$C9AE], a
    ld [$C831], a
    ld [$C9AD], a
    ld a, $F0
    ld [$C9B3], a
    ld [$C9B4], a
    ld [$C9B5], a
    ld [$C9B6], a
    ld [$C9B7], a
    ld [$C9B8], a
    ld [$C9B9], a
    ld [$C9BA], a
    ret
