; Bank 2 at $4653. FinishOpcode2D calls here after ApplyIndexedIdRecord
; when [$D0AF] is nonzero. Another caller in this bank calls it too.
;
; [$D068] indexes the $2D-byte records at $415B in bank 4. That pointer is
; stored at $CD8D, $CD8F is pointed at $CD91, and CopyEntryRecordPrefix
; copies the first $1E bytes of the record to $CD91. It leaves the word at
; $CD8F pointing at $CD91. This bank is unchanged around that call.
;
; Those $CD91 bytes are unpacked into $D110:
;   $D110 = 1, $D111 = 0, $D112 = [$D068], $D113 = prefix[0]
;   $D114-$D11A = 0
;   $D11B-$D124 = prefix[5] through prefix[14]
;   $D125 = 0, $D126 = prefix[15], $D127 = prefix[16]
;   prefix[17] and prefix[18] are skipped
;   $D128-$D133 = prefix[19] through prefix[30]
;   $D134-$D136 = 0
; Prefix bytes are numbered from 0. The copy is $1E bytes, so prefix[30]
; is the byte just past it, at $CDAF.
;
; A is zero. `set 0, a` / `res 1, a` stores 1 at $D389 (bit 0 set, bit 1
; clear), the same pair SpendNewEntryMeasures uses. SpendMeasureHundred
; then runs on $D110 once per [$D069]. A count of 0 wraps and runs 256
; times. With bit 0 set, those passes leave the measure word at record+5
; unchanged.
;
; [$D06A] is then stored at both $D118 and $D11A, overwriting two of the
; zeros. The next five instructions load [$D126] and OR it with [$D125].
; Both results are discarded before [$D103] is loaded.
;
; [$D103] * $37 + $D147 is stored little-endian at $D07B. That is the
; slot pointer FinishOpcode2D copies this $D110 record onto.
;
; MulCByB, CallBankedHL, CopyEntryRecordPrefix, and SpendMeasureHundred
; are already source.

FillD110FromIndexedEntry::
    ld a, [$D068]
    ld b, a
    ld c, $2D
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
    ld hl, CopyEntryRecordPrefix
    ld e, $04
    call CallBankedHL
    ld hl, $CD8F
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D110
    ld a, $01
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, [$D068]
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
REPT 4
    inc bc
ENDR
    xor a
REPT 7
    ld [hl+], a
ENDR
    ld d, $0A
.copyTen:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyTen
    xor a
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
REPT 3
    inc bc
ENDR
    ld d, $0C
.copyTwelve:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyTwelve
    xor a
REPT 3
    ld [hl+], a
ENDR
    set 0, a
    res 1, a
    ld [$D389], a
    ld a, [$D069]
.spend:
    ld hl, $D110
    push af
    call SpendMeasureHundred
    pop af
    dec a
    jr nz, .spend
    ld a, [$D06A]
    ld [$D118], a
    ld [$D11A], a
    ld a, [$D126]
    ld b, a
    ld hl, $D125
    or [hl]
    ld a, [hl]
    ld a, [$D103]
    ld b, a
    ld c, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ld a, h
    ld [$D07C], a
    ld a, l
    ld [$D07B], a
    ret
