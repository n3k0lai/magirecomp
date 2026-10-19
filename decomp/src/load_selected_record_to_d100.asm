; Bank 5 at $56AF. Called when bit 6 of $D0EE is set, after $CCA7 is
; cleared on that path.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names are from timer_overflow.asm. $D0D4 is cleared.
;
; $CCA7 of 0 or 5 picks a fixed record from [$D0B1] with bit 7 clear.
; 0 and 9 use the record at $5F0E (its text is "Focus"). Any other
; value uses the record at $5EAE (its text is "Fight") and copies
; $D0FF into $D0D4. Any other $CCA7 loads the word at $D0F1 plus twice
; ($CCA7 minus one).
;
; That pointer is stored at $CD8D and $CD8F is pointed at $D100. Bank 5
; at $5E4D copies 16 bytes from the first pointer to the second. A
; nonzero $D0D4 then writes $0B to $D103.
;
; Nonzero $D0FD and $D0FE each copy that id to wScriptId, point
; wScriptBufPtr at wScriptBuf, and call CopyIndexedRecord. The first
; pointer of the copied record is then called in bank 7. A zero $D0FE
; returns. wScriptId, wScriptBuf, and wScriptBufPtr are the names from
; run_pair_id_scripts.asm. CallBankedHL and CopyIndexedRecord are
; already source. $5E4D, $5EAE, and $5F0E are still INCBIN.
;
; File address of the 16-byte copy.

LoadSelectedRecordToD100::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [$D0D4], a
    ld a, [$CCA7]
    cp $00
    jr nz, .indexed

.fromD0B1:
    ld a, [$D0B1]
    res 7, a
    cp $00
    jr z, .focusRecord
    cp $09
    jr z, .focusRecord
    ld hl, $5EAE
    ld a, [$D0FF]
    ld [$D0D4], a
    jr .plantPtrs

.focusRecord:
    ld hl, $5F0E
    jr .plantPtrs

.indexed:
    cp $05
    jr z, .fromD0B1
    dec a
    ld c, a
    ld b, $00
    ld hl, $D0F1
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a

.plantPtrs:
    ld a, h
    ld [$CD8E], a
    ld a, l
    ld [$CD8D], a
    ld bc, $D100
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyPtr16Bytes
    ld e, $05
    call CallBankedHL
    ld a, [$D0D4]
    and a
    jr z, .checkD0FD
    ld a, $0B
    ld [$D103], a

.checkD0FD:
    ld a, [$D0FD]
    and a
    jr z, .checkD0FE
    ld a, [$D0FD]
    ld [wScriptId], a
    ld bc, wScriptBuf
    ld hl, wScriptBufPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedRecord
    ld e, $07
    call CallBankedHL
    ld hl, wScriptBuf
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $07
    call CallBankedHL

.checkD0FE:
    ld a, [$D0FE]
    and a
    ret z
    ld a, [$D0FE]
    ld [wScriptId], a
    ld bc, wScriptBuf
    ld hl, wScriptBufPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedRecord
    ld e, $07
    call CallBankedHL
    ld hl, wScriptBuf
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, $07
    call CallBankedHL
    ret
