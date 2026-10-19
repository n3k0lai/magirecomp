; Bank 2 setup Opcode25Bank4 calls through CallBankedHL, then jumps to Reset.
;
; WRAM bank 7 is mapped and mirrored in wCurrentWRAMBank. The word at $D06D
; is cleared, and $294 bytes at $D0D9 are filled with zero. $5C5C enables
; SRAM and copies a block: first from $A000 into $D147, later from $CD91
; into $D336. Between those calls, [$D391] * $2D + $415B is stored at
; $CD8D, $CD91 is stored at $CD8F, and bank 4's $411A runs.
;
; $D09A is 0 when [$D339] is $0E, and 1 otherwise. [$D338] is copied to
; $D0C2. $D0C0 is set to 0 and $D0C1 to $0C, then bank 5's $57BA runs.
; $D15C, $D34B, $D016, and $D06C are cleared. $D0CD is set to $FF. Eight
; bytes at $D092, $18 bytes at $D36E, and ten bytes at $D07D are filled
; with zero. Eight bytes at $D0B8 are filled with $FF. $51C2 is stored at
; $D35D. $5E5E sets $D3C2 and waits in FinishFrame until that byte is zero.
; $51C2 is stored at $D16E. $6BE7 and $66DD run. Control leaves with a jump
; to $6591, which loops while [$D0D5] is nonzero.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; FillBytes, MulCByB, and CallBankedHL are already source. FinishFrame is
; the name from finish_frame.asm. $5C5C, $411A, $57BA, $5E5E, $6BE7,
; $66DD, and $6591 are still INCBIN.

InitWram7BeforeReset::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $0000
    ld hl, $D06D
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D0D9
    ld bc, $0294
    ld a, $00
    ld e, a
    call FillBytes
    ld bc, $A000
    ld hl, $D147
    call $5C5C
    ld a, $01
    ld [$D091], a
    ld a, [$D391]
    ld c, a
    ld b, $2D
    call MulCByB
    ld bc, $415B
    add hl, bc
    ld a, h
    ld [$CD8E], a
    ld a, l
    ld [$CD8D], a
    ld bc, $CD91
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $411A
    ld e, $04
    call CallBankedHL
    ld bc, $CD91
    ld hl, $D336
    call $5C5C
    ld a, [$D339]
    cp $0E
    jr z, .recordIs0E
    ld a, $01
    jr .storeFlag
.recordIs0E:
    xor a
.storeFlag:
    ld [$D09A], a
    ld a, [$D338]
    ld [$D0C2], a
    ld a, $00
    ld [$D0C0], a
    ld a, $0C
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    xor a
    ld [$D15C], a
    ld [$D34B], a
    ld [$D016], a
    ld [$D06C], a
    ld a, $FF
    ld [$D0CD], a
    ld hl, $D092
    ld bc, $0008
    ld a, $00
    ld e, a
    call FillBytes
    ld hl, $D36E
    ld bc, $0018
    ld a, $00
    ld e, a
    call FillBytes
    ld hl, $D07D
    ld bc, $000A
    ld a, $00
    ld e, a
    call FillBytes
    ld hl, $D0B8
    ld bc, $0008
    ld a, $FF
    ld e, a
    call FillBytes
    ld bc, $51C2
    ld hl, $D35D
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $5E5E
    ld bc, $51C2
    ld hl, $D16E
    ld a, c
    ld [hl+], a
    ld [hl], b
    call $6BE7
    call $66DD
    jp $6591
