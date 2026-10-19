; ClaimFirstMeasureThreshold. Bank 2 at $5657.
;
; Called at the end of SpendMeasureHundred with the record in HL. $D38A
; holds the uncapped measure that routine just stored.
;
; Four bytes at record+$20 through record+$23 are thresholds, or $FF when
; that slot is already claimed. The first slot that is not $FF and is at
; most $D38A is written as $FF. DE is then $0018, $001A, $001C, or $001E
; for those four slots. The original record pointer and that DE are passed
; to $5B71, bit 7 of $D389 is set, and this returns.
;
; If every remaining threshold is above $D38A, or every slot is already
; $FF, the record pointer is restored and this returns with $D389 unchanged.
; What $5B71 does with DE is still unknown.

DEF THRESHOLD_CLAIMED EQU $FF

ClaimFirstMeasureThreshold::
    push hl
    ld de, $0020
    add hl, de
    ld a, THRESHOLD_CLAIMED
    cp [hl]
    jr z, .slot21

    ld a, [$D38A]
    cp [hl]
    jr c, .miss

    ld a, THRESHOLD_CLAIMED
    ld [hl], a
    ld de, $0018
    jr .claimed

.slot21:
    pop hl
    push hl
    ld de, $0021
    add hl, de
    ld a, THRESHOLD_CLAIMED
    cp [hl]
    jr z, .slot22

    ld a, [$D38A]
    cp [hl]
    jr c, .miss

    ld a, THRESHOLD_CLAIMED
    ld [hl], a
    ld de, $001A
    jr .claimed

.slot22:
    pop hl
    push hl
    ld de, $0022
    add hl, de
    ld a, THRESHOLD_CLAIMED
    cp [hl]
    jr z, .slot23

    ld a, [$D38A]
    cp [hl]
    jr c, .miss

    ld a, THRESHOLD_CLAIMED
    ld [hl], a
    ld de, $001C
    jr .claimed

.slot23:
    pop hl
    push hl
    ld de, $0023
    add hl, de
    ld a, THRESHOLD_CLAIMED
    cp [hl]
    jr z, .miss

    ld a, [$D38A]
    cp [hl]
    jr c, .miss

    ld a, THRESHOLD_CLAIMED
    ld [hl], a
    ld de, $001E

.claimed:
    pop hl
    call $5B71
    ld a, [$D389]
    set 7, a
    ld [$D389], a
    ret

.miss:
    pop hl
    ret
