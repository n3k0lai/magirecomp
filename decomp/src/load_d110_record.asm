; LoadD110Record. RaiseEntriesBelow100 calls here with HL = $D110 when a
; measure is below 100. BC is the SRAM source: the pointer saved at
; $D0CF, or sEntryBase on the final pass.
;
; WRAM bank 7 is mapped. SRAM bank wSRAMBank + 1 is selected and enabled.
; The first byte written is 1 when [$D017] is nonzero and 0 when it is
; zero. The next byte is 0. Then $25 bytes are copied from BC. SRAM is
; disabled. $5C1D, still the ret in the hole just before this entry, is
; called and returns at once. The two bytes at $D119 are then copied onto
; $D117, and BC is left at $D11B.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm.

DEF D110_PAYLOAD EQU $25

LoadD110Record::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [$D017]
    and a
    jr z, .zeroFlag
    ld a, $01
    jr .storeFlag
.zeroFlag:
    xor a
.storeFlag:
    ld [hl+], a
    xor a
    ld [hl+], a
    ld d, D110_PAYLOAD
.copyByte:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyByte
    xor a
    ld [rRAMG], a
    call $5C1D
    ld hl, $D117
    ld bc, $D119
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ret
