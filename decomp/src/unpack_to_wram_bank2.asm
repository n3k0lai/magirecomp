; Bank 0 at $2F19. LoadFiveBankedMapSources calls this with BC pointing
; at a packed stream in the bank the caller mapped.
;
; The WRAM bank in wCurrentWRAMBank is saved and restored. Bank 2 is
; stored there and selected with `ldh [rSVBK], a`. HL takes the source
; from BC, DE is $D000, and BC is loaded with $1000 before UnpackBytes.
; UnpackBytes then replaces BC with each command length and writes the
; stream to DE. Restoring rSVBK uses the 3-byte `ld [rSVBK], a`.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; UnpackBytes is the name from unpack_bytes.asm.

DEF WRAM_BANK2 EQU $02
DEF WRAM2_BLOCK EQU $D000
DEF WRAM2_BLOCK_LEN EQU $1000

UnpackToWRAMBank2::
    ld h, b
    ld l, c
    ld a, [wCurrentWRAMBank]
    push af
    ld a, WRAM_BANK2
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld de, WRAM2_BLOCK
    ld bc, WRAM2_BLOCK_LEN
    call UnpackBytes
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ret
