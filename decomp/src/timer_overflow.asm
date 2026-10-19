; Timer overflow. The vector at $0050 jumps here.
;
; Registers and both bank shadows are saved. ROM bank $30 and WRAM bank 1 are
; mapped, then the pointer at wSoundCommand is called. Bank 7 writes that
; pointer; its targets are the commands at $0659-$074F, and they expect bank
; $30 to be mapped. A command may switch the ROM bank, so bank $30 is selected
; again before the driver tick at UpdateSound. That tick returns at once
; unless $DF02 holds $F5, the value stored when the driver is set up.
; wSoundCommand and the $DF00 block both live in WRAM bank 1.
;
; Selecting WRAM bank 1 is ldh. Restoring the saved bank is the 3-byte form.
; rROMB0 and wCurrentROMBank are the names from reset.asm.

DEF rSVBK EQU $FF70

; Shadow of rSVBK.
DEF wCurrentWRAMBank EQU $C937

; Little-endian command pointer in WRAM bank 1.
DEF wSoundCommand EQU $C91B

DEF BANK_SOUND EQU $30
DEF WRAM_SOUND EQU $01

; Bank 0, still INCBIN. The body is jp hl, so calling it enters the pointer.
DEF CallHL EQU $0789

; Bank $30, still INCBIN. CPU address while that bank is mapped.
DEF UpdateSound EQU $4356

TimerOverflow::
    push af
    push bc
    push de
    push hl
    ld a, [wCurrentROMBank]
    push af
    ld a, [wCurrentWRAMBank]
    push af
    ld a, BANK_SOUND
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, WRAM_SOUND
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wSoundCommand + 1]
    ld h, a
    ld a, [wSoundCommand]
    ld l, a
    call CallHL
    ld a, BANK_SOUND
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call UpdateSound
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop hl
    pop de
    pop bc
    pop af
    reti
