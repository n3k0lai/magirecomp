; WriteD110RecordBody. RaiseEntriesBelow100 calls this with HL = $D110
; and BC pointing at the SRAM entry (the address saved at $D0CF, or
; sEntryBase). The matching load at $5C1E writes two leading bytes at HL
; before it copies the body in from BC. This stores only that body back.
;
; WRAM bank 7 is mapped. SRAM bank wSRAMBank + 1 is selected and enabled.
; HL advances by 2, then $25 bytes are copied from [HL+] to [BC]. SRAM is
; disabled. The copy length is the same body size the loader uses.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm.

DEF RECORD_BODY_LENGTH EQU $25

WriteD110RecordBody::
    ld de, $0002
    add hl, de
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld d, RECORD_BODY_LENGTH
.copyByte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyByte
    xor a
    ld [rRAMG], a
    ret
