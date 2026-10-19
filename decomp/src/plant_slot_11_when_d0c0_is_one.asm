; Bank 5 at $579D. DispatchD0B0Script calls here through CallBankedHL
; with bank 5 when [$D103] is below $14, after copying [$CCA7] into
; $D103 and $D0C1. $D0C0 was cleared at the start of that caller.
;
; WRAM bank 7 is selected, so the $D0C0 and $D0C1 reads use that bank.
; A zero [$D0C0] returns. A value other than 1 returns as well. When
; [$D0C0] is 1, A is the slot [$D0C1], D is $11, and BC is $7438.
; StoreIndexedSlotRecord writes D, then that word, then $66 and $0A
; into the slot. This routine does not write rROMB0.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; StoreIndexedSlotRecord is already source.

PlantSlot11WhenD0C0IsOne::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D0C0]
    and a
    ret z
    cp $01
    jr nz, .return
    ld a, [$D0C1]
    ld d, $11
    ld bc, $7438
    call StoreIndexedSlotRecord
    ret

.return:
    ret

PlantSlot11WhenD0C0IsOneEnd:
