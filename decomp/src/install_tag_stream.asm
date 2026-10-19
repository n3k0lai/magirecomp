; OpenChannelForTag jumps or calls here at $4EDE. ROM bank $30 stays
; mapped. HL points at the tag record. B is a priority. C is a channel
; index; bit 7 may be set and is cleared here.
;
; The indexed byte at $DF9D is the priority already installed. When B
; is below that byte this restores HL, returns A = 0, and returns Z.
; Otherwise the new priority replaces it, the record pointer is stored
; as the stream word at $DF7E, and the words at $DF86 and $DF92 and the
; bytes at $DF8E and $DFA1 are cleared. rlca forces Z clear so the
; caller can tell a successful install from the reject path. A stays 0.

DEF wInstalledPriority EQU $DF9D
DEF wStreamLoopWord EQU $DF86
DEF wStreamCountdown EQU $DF92
DEF wStreamCounter EQU $DF8E
DEF wStreamCompanion EQU $DFA1

InstallTagStream:
    push hl
    ld a, b
    res 7, c
    ld b, $00
    ld hl, wInstalledPriority
    add hl, bc
    cp [hl]
    jr nc, .store

    pop hl
    xor a
    ret

.store:
    ld [hl], a
    pop hl
    ld a, l
    ld d, h
    sla c
    ld hl, wSoundStreamPointers
    add hl, bc
    ld [hl+], a
    ld [hl], d
    xor a
    ld hl, wStreamLoopWord
    add hl, bc
    ld [hl+], a
    ld [hl], a
    ld hl, wStreamCountdown
    add hl, bc
    ld [hl+], a
    ld [hl], a
    srl c
    ld hl, wStreamCounter
    add hl, bc
    ld [hl], a
    ld hl, wStreamCompanion
    add hl, bc
    ld [hl], a
    rlca
    ret
