; Fill the five group pointers from nonzero SRAM bytes.
;
; ScanGroupBytes calls this with SRAM already enabled. $CD81 picks the walk.
; $06 and $0D wipe the ten bytes at wGroupPointers, set the phase byte to
; $02, and walk forward from the SRAM address at wGroupSRAM. $0B, $12, and
; $17 walk backward from the first pointer, storing hits from the fifth
; slot toward the first. Every other index walks forward from the fifth
; pointer. A phase of $01 skips that forward walk, and a phase of $02 skips
; the backward walk. Both skips clear wGroupCopyGate.
;
; A nonzero byte is stored as a pointer and the cursor advances. A zero is
; skipped. The forward walk stops after wGroupSRAM + $FE. The backward walk
; stops at the SRAM address itself. Each stored backward hit then moves the
; cursor back four bytes, so the slots fill downward. Filling all five
; slots returns with the gate still set. Hitting the end early sets the
; phase ($01 forward, $02 backward). If the cursor never moved, the gate
; is cleared. If the forward walk stored some slots, the rest are padded
; with the SRAM address.
;
; wGroupPointers, wGroupSRAM, and wGroupCopyGate are the names from
; write_group_row_digits.asm and scan_group_bytes.asm. wUnknownCD81 is the
; name from handle_start_press.asm. The two's-complement subtract is how
; this ROM compares a pointer with a fixed address.

DEF wGroupScanPhase EQU $CC86

; $01: a forward walk already reached the limit. $02: a backward walk
; already reached the SRAM address, also the value preset by $06 and $0D.
DEF PHASE_FORWARD_DONE EQU $01
DEF PHASE_BACK_DONE EQU $02

; Indexes that wipe the list and walk forward from the SRAM base.
DEF INDEX_FWD_CLEAR EQU $06
DEF INDEX_FWD_CLEAR_B EQU $0D

; Indexes that walk backward from the first stored pointer.
DEF INDEX_BACK_A EQU $0B
DEF INDEX_BACK_B EQU $12
DEF INDEX_BACK_C EQU $17

; Ten bytes: five pointers. Last address visited by a forward walk.
DEF GROUP_POINTER_BYTES EQU $0A
DEF GROUP_SCAN_LIMIT EQU $00FE

; After a backward store, +2 then -4 lands on the previous slot.
; wGroupPointers + 2 is where HL sits once the first slot has been written.
DEF GROUP_SLOT_REWIND EQU $FFFC

FillGroupPointers::
    ld a, $01
    ld [wGroupCopyGate], a
    ld a, [wUnknownCD81]
    cp INDEX_FWD_CLEAR_B
    jr z, .clearAndScan

    cp INDEX_FWD_CLEAR
    jr z, .clearAndScan

    jr .pickDirection

.clearAndScan
    ld hl, wGroupPointers
    ld a, PHASE_BACK_DONE
    ld [wGroupScanPhase], a
    ld c, GROUP_POINTER_BYTES
    xor a

.clearByte
    ld [hl+], a
    dec c
    jr nz, .clearByte

    ld hl, wGroupSRAM
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    dec bc
    ld hl, wGroupPointers
    jr .scanForward

.pickDirection
    ld a, [wUnknownCD81]
    cp INDEX_BACK_C
    jp z, .scanBackward

    cp INDEX_BACK_A
    jp z, .scanBackward

    cp INDEX_BACK_B
    jp z, .scanBackward

    ld hl, wGroupPointers + 8
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, [wGroupScanPhase]
    cp PHASE_FORWARD_DONE
    jr nz, .beginForward

    xor a
    ld [wGroupCopyGate], a
    ret

.beginForward
    xor a
    ld [wGroupScanPhase], a
    ld hl, wGroupPointers

.scanForward
    inc bc
    ld a, [bc]
    cp $00
    jr z, .forwardEmpty

    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld de, wGroupSRAM
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    push hl
    add hl, de
    ld a, h
    or l
    pop hl
    ret z

.forwardEmpty
    push hl
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld de, GROUP_SCAN_LIMIT
    add hl, de
    ld a, l
    cpl
    ld l, a
    ld a, h
    cpl
    ld h, a
    inc hl
    add hl, bc
    ld a, h
    or l
    pop hl
    jr nz, .scanForward

    ld a, PHASE_FORWARD_DONE
    ld [wGroupScanPhase], a
    push hl
    ld de, wGroupPointers
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld a, h
    or l
    pop hl
    jr nz, .padForward

    xor a
    ld [wGroupCopyGate], a
    ret

.padForward
    push hl
    ld de, wGroupSRAM
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld a, h
    or l
    pop hl
    ret z

    ld a, [wGroupSRAM + 1]
    ld b, a
    ld a, [wGroupSRAM]
    ld c, a
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    jr .padForward

.scanBackward
    ld a, [wGroupScanPhase]
    cp PHASE_BACK_DONE
    jr nz, .beginBackward

    xor a
    ld [wGroupCopyGate], a
    ret

.beginBackward
    xor a
    ld [wGroupScanPhase], a
    ld hl, wGroupPointers
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, wGroupPointers + 8

.backStep
    dec bc
    ld a, [bc]
    cp $00
    jr z, .backwardEmpty

    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld de, wGroupPointers + 2
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    push hl
    add hl, de
    ld a, h
    or l
    pop hl
    ld de, GROUP_SLOT_REWIND
    add hl, de
    ret z

.backwardEmpty
    push hl
    ld hl, wGroupSRAM
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, l
    cpl
    ld l, a
    ld a, h
    cpl
    ld h, a
    inc hl
    add hl, bc
    ld a, h
    or l
    pop hl
    jr nz, .backStep

    ld a, PHASE_BACK_DONE
    ld [wGroupScanPhase], a
    push hl
    ld de, wGroupPointers + 8
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    add hl, de
    ld a, h
    or l
    pop hl
    ret nz

    xor a
    ld [wGroupCopyGate], a
    ret
