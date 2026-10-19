; Lower-countdown slot N, with N in A. ServiceLowerCountdownExpiry calls
; this at $3F0E once that slot's 24-bit count has expired. ROM bank $30
; is mapped on entry. $DFA9 is mapped through MapRomBank so the stream
; pointer at $DFCB + N * 2 can be read, then [$DF00] is mapped back.
;
; The pointer addresses a command that shares its first two bytes with
; AddLowerCountdownDelta. This routine skips the low delta byte and
; takes the high nibble of the first byte as a tag. The third byte is
; returned in D. Bit 7 of that byte, and of A, selects the caller's exit:
;
;   Third byte bit 7 clear: A returns 0. BC is the following span. Bit 7
;     of the next byte set means BC is a 15-bit word (high byte masked);
;     bit 7 clear means C is that byte and B is 0. The pointer moves past
;     the span. The caller arms the upper countdown from BC.
;   Third byte bit 7 set and tag 0: D and A both become that byte with
;     bit 7 forced. No span is read. The pointer stays just after the
;     third byte. The caller stores through $3FB0 and returns.
;   Third byte bit 7 set and tag nonzero, except the end mark below:
;     D is the third byte with bit 7 cleared. A is the fourth byte with
;     bit 7 forced. BC is the span that follows that byte. The caller
;     stores through $3FB0, then arms the upper countdown from BC.
;   Third byte $FF and tag $0F: D stays $FF and A stays 0. No span is
;     read. The caller clears this slot's bit in $DFD3.
;
; BC is preserved on the two paths that do not read a span. $DFFA holds
; the value returned in A. $DFFC holds the new pointer high byte while
; the low byte is written back.

DEF wLowerCommandLatch EQU $DFFA
DEF wLowerPointerHigh EQU $DFFC

ReadExpiredLowerCountdown:
    sla a
    ld e, a
    ld d, $00
    ld a, [wCountdownBank]
    call MapRomBank
    xor a
    ld [wLowerCommandLatch], a
    ld hl, wLowerCountdownRecord
    add hl, de
    push hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    inc hl
    swap a
    and $0f
    ld e, a
    ld a, [hl+]
    ld d, a
    bit 7, a
    jr z, .read_span

    cp $ff
    jr z, .maybe_end

.mask_third:
    and $7f
    ld d, a
    ld a, e
    and a
    jr z, .yield_tag

    ld a, [hl+]
    or $80
    ld [wLowerCommandLatch], a
    jr .read_span

.maybe_end:
    ld d, a
    ld a, e
    cp $0f
    ld a, d
    jr nz, .mask_third

    jr .store_pointer

.yield_tag:
    ld a, d
    or $80
    ld d, a
    ld [wLowerCommandLatch], a
    jr .store_pointer

.read_span:
    ld a, [hl+]
    bit 7, a
    jr z, .span_byte

    and $7f
    ld b, a
    ld a, [hl+]
    ld c, a
    jr .store_pointer

.span_byte:
    ld c, a
    ld b, $00

.store_pointer:
    ld a, h
    ld [wLowerPointerHigh], a
    ld a, l
    pop hl
    ld [hl+], a
    ld a, [wLowerPointerHigh]
    ld [hl], a
    ld a, [wCountdownSavedBank]
    push bc
    call MapRomBank
    pop bc
    ld a, [wLowerCommandLatch]
    ret

ReadExpiredLowerCountdownEnd:
