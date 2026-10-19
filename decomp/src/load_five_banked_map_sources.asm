; Bank 0 at $2E15. Called with BC pointing at five (pointer, bank) records
; while a script bank is mapped. Each record is a low byte, a high byte,
; and a ROM bank. The previous bank is saved around each call and written
; back to wCurrentROMBank and rROMB0.
;
; The five calls, in order:
;   $2EC3  still INCBIN: fill $C72B, then two calls in bank 7
;   $2FC0  CopyMapRecords, both VRAM banks
;   $2F19  still INCBIN: copy $1000 bytes to $D000 in WRAM bank 2
;   $2F37  still INCBIN: unpack a header while WRAM bank 3 is mapped
;   $2DDC  still INCBIN: unpack into WRAM bank 5 at $D000
;
; $2E2D is the fall-through after the first call, and also a direct entry:
; BC and the previous bank are already on the stack. $2E3F enters with HL
; holding the next pointer, BC on its bank byte, and the previous bank
; already pushed. $2E47 enters with that bank already mapped. $2E4F
; restores the bank in A. $2E52 is only the rROMB0 half of that restore,
; then the last three records.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm. The bank stores
; are the 3-byte form. CopyMapRecords is the name from copy_map_records.asm.

DEF UnpackHeaderWRAMBank3 EQU $2F37

LoadFiveBankedMapSources::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call FillC72BFromBCThenBank7

ResumeBankedMapSources::
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af

MapBankThenCopyMapRecords::
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc

CopyMapRecordsThenContinue::
    push bc
    ld c, l
    ld b, h
    call CopyMapRecords
    pop bc
    pop af

RestoreROMBankThenContinue::
    ld [wCurrentROMBank], a

RestoreROMB0ThenThreeBlocks::
    ld [rROMB0], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call UnpackToWRAMBank2
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call UnpackHeaderWRAMBank3
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wCurrentROMBank]
    push af
    ld a, [bc]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    inc bc
    push bc
    ld c, l
    ld b, h
    call UnpackBlockIntoWRAMBank5
    pop bc
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret

LoadFiveBankedMapSourcesEnd:
