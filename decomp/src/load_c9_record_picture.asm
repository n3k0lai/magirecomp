; Bank 0 at $3493. ApplyC9E4TableEntry calls this after $6FC5 has
; copied a record into $C9CD–$C9D2 and $C9D5–$C9DB.
;
; The saved ROM bank is restored on the way out. rVBK starts at 0.
; Two packed streams are unpacked into VRAM bank 0: $400 bytes at
; $8800 from the pointer at $C9CD in the bank at $C9CF, then $400
; bytes at $8C00 from $C9DA in the bank at $C9D8. $34C5 is the
; `ld l, a` of that second pointer. VRAM bank 1 is selected ($34D1
; is that store) and the first $10 bytes at $8800 are filled with 0.
;
; $2DAA, still INCBIN, unpacks a source into WRAM bank 6 and copies
; E columns by D rows to both VRAM banks. This uses it twice, 32 by
; 4: $9800 from $C9D0 in the bank at $C9D2, then $9880 from $C9DC in
; the bank at $C9D9. ClampAddedByte then adds a bias to each of the
; $80 bytes just written, saturating at $FF. VRAM bank 0 gets $80 at
; $9800 and $C0 at $9880. VRAM bank 1 gets $06 on both strips.
;
; $35CC, still INCBIN, is called with BC pointing at $C9D5 in the
; bank at $C9D7. The word at that same address is stored at $C9E5
; (low) and $C9E6 (high), the pair StoreIndexedPtrPlus11 calls
; wIndexedPtrField. CallBankedHL then runs bank 7 at $5C7E.
;
; The `ld a, $00` / `ld e, a` and `ld a, imm` / `ld e, a` pairs are
; the bytes in the ROM. FillBytes and ClampAddedByte read E.
; wCurrentROMBank and rROMB0 are the names from reset.asm. rVBK is
; the name from setup_window.asm. UnpackBytes, FillBytes,
; ClampAddedByte, and CallBankedHL are the names from those files.

; Bank and little-endian pointer of the packed block copied to $8800.
DEF wGfx8800Ptr EQU $C9CD
DEF wGfx8800Bank EQU $C9CF

; Bank and little-endian pointer of the first map source.
DEF wMap9800Ptr EQU $C9D0
DEF wMap9800Bank EQU $C9D2

; Bank and little-endian pointer passed to $35CC, then dereferenced.
DEF wPairSourcePtr EQU $C9D5
DEF wPairSourceBank EQU $C9D7

; Bank and little-endian pointer of the packed block copied to $8C00.
DEF wGfx8C00Ptr EQU $C9DA
DEF wGfx8C00Bank EQU $C9D8

; Bank and little-endian pointer of the second map source.
DEF wMap9880Bank EQU $C9D9
DEF wMap9880Ptr EQU $C9DC

; Low byte of the word loaded from wPairSourcePtr. High byte is +1.
DEF wPictureIndexedPtr EQU $C9E5

LoadC9RecordPicture::
    ld a, [wCurrentROMBank]
    push af
    xor a
    ld [rVBK], a
    ld a, [wGfx8800Bank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wGfx8800Ptr + 1]
    ld h, a
    ld a, [wGfx8800Ptr]
    ld l, a
    ld de, $8800
    ld bc, $0400
    call UnpackBytes
    ld a, [wGfx8C00Bank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wGfx8C00Ptr + 1]
    ld h, a
    ld a, [wGfx8C00Ptr]
; $34C5. A is the low byte of the second graphics pointer.
.secondGfxLow:
    ld l, a
    ld de, $8C00
    ld bc, $0400
    call UnpackBytes
    ld a, $01
; $34D1. A is the VRAM bank to select.
.vramBankInA:
    ld [rVBK], a
    ld hl, $8800
    ld bc, $0010
    ld a, $00
    ld e, a
    call FillBytes
    ld a, [wMap9800Bank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, $9800
    ld e, $20
    ld d, $04
    ld a, [wMap9800Ptr + 1]
    ld b, a
    ld a, [wMap9800Ptr]
    ld c, a
    call $2DAA
    ld a, [wMap9880Bank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, $9880
    ld e, $20
    ld d, $04
    ld a, [wMap9880Ptr + 1]
    ld b, a
    ld a, [wMap9880Ptr]
    ld c, a
    call $2DAA
    xor a
    ld [rVBK], a
    ld hl, $9800
    ld bc, $0080
    ld d, $FF
    ld a, $80
    ld e, a
    call ClampAddedByte
    ld hl, $9880
    ld bc, $0080
    ld d, $FF
    ld a, $C0
    ld e, a
    call ClampAddedByte
    ld a, $01
    ld [rVBK], a
    ld hl, $9800
    ld bc, $0080
    ld d, $FF
    ld a, $06
    ld e, a
    call ClampAddedByte
    ld hl, $9880
    ld bc, $0080
    ld d, $FF
    ld a, $06
    ld e, a
    call ClampAddedByte
    ld a, [wPairSourceBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wPairSourcePtr + 1]
    ld b, a
    ld a, [wPairSourcePtr]
    ld c, a
    call $35CC
    ld a, [wPairSourcePtr + 1]
    ld h, a
    ld a, [wPairSourcePtr]
    ld l, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    ld [wPictureIndexedPtr + 1], a
    ld a, l
    ld [wPictureIndexedPtr], a
    ld hl, $5C7E
    ld e, $07
    call CallBankedHL
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
