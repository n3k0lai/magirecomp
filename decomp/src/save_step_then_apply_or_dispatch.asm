; Bank 5 at $682D, called through CallBankedHL with bank 5 from $56FC.
;
; WRAM bank 5 is stored in wCurrentWRAMBank and selected with rSVBK.
; The signed step at wClearedOnRecordLoad ($C6D2) and the next byte
; ($C6D3) are copied to $C6D0 and $C6D1. Both zero returns. If those
; two step bytes share any set bit, $02 is stored at $C6D6.
;
; $6884 classifies the step against the fine position. A result of $08
; adds the step with ApplyFineXDelta and ApplyFineYDelta and returns.
; Any other class indexes the word table at $651E, calls that word
; through JumpHL, adds C to the byte at $C6D5 (eight times the class
; before the call; C was twice the class), and calls the word at $652E
; indexed by that sum.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wClearedOnRecordLoad is the name from load_record_head.asm.
; ApplyFineXDelta and ApplyFineYDelta are the routines at $67B1 and $67E7.
; JumpHL is the trampoline at $0789. $6884, $651E, and $652E are still
; INCBIN. This routine does not write rROMB0.

SaveStepThenApplyOrDispatch::
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wClearedOnRecordLoad]
    ld [$c6d0], a
    ld b, a
    ld a, [wClearedOnRecordLoad + 1]
    ld [$c6d1], a
    or b
    ret z
    ld a, [wClearedOnRecordLoad + 1]
    and b
    jr z, .classify
    ld a, $02
    ld [$c6d6], a

.classify:
    call $6884
    cp $08
    jr nz, .dispatch
    call ApplyFineXDelta
    call ApplyFineYDelta
    ret

.dispatch:
    ld hl, $651e
    add a, a
    ld c, a
    add a, a
    add a, a
    ld [$c6d5], a
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    ld hl, $c6d5
    ld a, [hl]
    add c
    ld [hl], a
    ld hl, $652e
    add a, a
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    ret

SaveStepThenApplyOrDispatchEnd:
