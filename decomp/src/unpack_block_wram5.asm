; Bank 0 at $2DDC. Called with BC pointing at a block in the ROM bank the
; caller mapped. The WRAM bank in wCurrentWRAMBank is saved and restored.
; Bank 5 is stored there and selected with `ldh [rSVBK], a`.
;
; HL takes that source. $C6D2 and $C6D3 are cleared. The first source byte
; is stored at $C6CF. What those three bytes mean is still unknown. The
; shared tail at $2DF4 skips the next two bytes, then UnpackBytes copies
; the packed stream to $D000 in the selected bank. $2E04, still INCBIN,
; maps bank 6, skips only the first byte, and jumps to that tail.
;
; Restoring rSVBK uses the 3-byte `ld [rSVBK], a`. $2E00 is that store
; alone, then the return. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. UnpackBytes is the name from unpack_bytes.asm.

UnpackBlockIntoWRAMBank5::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld h, b
    ld l, c
    xor a
    ld [$C6D2], a
    ld [$C6D3], a
    ld a, [hl+]
    ld [$C6CF], a

SkipTwoThenUnpackAtD000::
    inc hl
    inc hl
    ld de, $D000
    call UnpackBytes
    pop af
    ld [wCurrentWRAMBank], a

WriteSVBKAndReturn::
    ld [rSVBK], a
    ret
