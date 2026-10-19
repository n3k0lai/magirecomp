; Bank 0 at $2F37. LoadFiveBankedMapSources calls this with BC pointing
; at a packed map while that map's ROM bank is mapped.
;
; The WRAM bank in wCurrentWRAMBank is saved and restored. Bank 3 is stored
; there and selected with `ldh [rSVBK], a`. $2F40 is that select alone, and
; $2F4B is the clear that follows the map column and row. Both addresses are
; conditional-jump targets from bank $2F; those sites sit in data.
;
; A is zero for the clears. $C85F and $C860 are the map column and row.
; $C85D and $C85E are the fine positions. $C86A and $C892 are the row and
; column load latches. $C869 and $C891 are the row and column countdowns.
; $C843 and $C844 are the pixel deltas. $C842 is set to $44: bit 2 and bit 6,
; the flags that refuse a left or up step past the origin.
;
; The next seven source bytes are a header. Byte 0 is the map row stride at
; $C847. Bytes 1 and 2 are the word at $C849. Byte 3 is the camera column
; limit and byte 4 is the camera row limit. That row limit plus $0A is stored
; at wCameraByteC848. Two bytes are skipped, then UnpackBytes writes the
; packed stream to $D000. Restoring rSVBK uses the 3-byte `ld [rSVBK], a`.
;
; $C84B and the next byte are cleared. Eight words then follow, each the
; running sum of the stride, so the table holds 1 through 8 times $C847.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wCameraColumnLimit, wCameraRowLimit, and wCameraByteC848 are the names
; from seed_camera_loop.asm. UnpackBytes is the name from unpack_bytes.asm.
; The stride, fine positions, limits, and flags are the ones read by
; StepHorizontalScroll and StepVerticalScroll.

DEF WRAM_BANK3 EQU $03
DEF WRAM3_BLOCK EQU $D000
DEF MAP_EDGE_FLAGS EQU $44
DEF STRIDE_TABLE_STEPS EQU $08

UnpackMapHeaderIntoWRAMBank3::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, WRAM_BANK3
    ld [wCurrentWRAMBank], a

SelectWRAMBank3::
    ldh [rSVBK], a
    ld h, b
    ld l, c
    xor a
    ld [$C85F], a
    ld [$C860], a

ClearCameraScroll::
    ld [$C85D], a
    ld [$C85E], a
    ld [$C86A], a
    ld [$C892], a
    ld [$C869], a
    ld [$C891], a
    ld [$C843], a
    ld [$C844], a
    ld a, MAP_EDGE_FLAGS
    ld [$C842], a
    ld a, [hl+]
    ld [$C847], a
    ld a, [hl+]
    ld [$C849], a
    ld a, [hl+]
    ld [$C84A], a
    ld a, [hl+]
    ld [wCameraColumnLimit], a
    ld a, [hl+]
    ld [wCameraRowLimit], a
    add $0A
    ld [wCameraByteC848], a
    inc hl
    inc hl
    ld de, WRAM3_BLOCK
    call UnpackBytes
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ld hl, $C84B
    xor a
    ld [hl+], a
    ld [hl+], a
    ld a, [$C847]
    ld b, a
    ld c, STRIDE_TABLE_STEPS
    ld de, $0000

StoreNextStrideMultiple:
    ld a, b
    add e
    ld e, a
    ld [hl+], a
    ld a, $00
    adc d
    ld d, a
    ld [hl+], a
    dec c
    jr nz, StoreNextStrideMultiple

    ret
