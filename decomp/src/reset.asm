; Reset entry. The header at $0100 jumps here with the boot ROM's model id in A
; ($11 on a Game Boy Color).

DEF rRAMG EQU $0000
DEF rROMB0 EQU $2000
DEF rROMB1 EQU $3000
DEF rTMA EQU $FF06
DEF rTAC EQU $FF07
DEF rRP EQU $FF56

; Timer on, 4096 Hz. The clock-select bits are 0, so this is the whole TAC value.
DEF TACF_START EQU $04

DEF wWRAM EQU $C000
DEF wStackTop EQU $CED8
DEF wCurrentROMBank EQU $C938

; 1 after a CGB boot, 0 otherwise. Both accesses below are the 3-byte form.
DEF hCGB EQU $FFFE

; Script the later dispatcher runs: bank $22, pointer $418E, handler $0A66.
; $0A66 reads an opcode from that pointer and jumps through a table in bank 1.
DEF hScriptBank EQU $FFA1
DEF hScriptPtr EQU $FFA2
DEF hScriptHandler EQU $FFA4

DEF INITIAL_SCRIPT_BANK EQU $22
DEF INITIAL_SCRIPT_PTR EQU $418E
DEF INITIAL_SCRIPT_HANDLER EQU $0A66

; Bytes kept free under the stack. The clear stops at $CED8 - $100.
DEF STACK_GAP EQU $100

; Bank 0, still INCBIN.
DEF FillMemory EQU $07B2
DEF InitDefaultState EQU $082D
DEF ContinueStartup EQU $2158

; ROM bank 7, still INCBIN. CPU addresses while that bank is mapped.
DEF BANK_INIT EQU $07
DEF SwitchToDoubleSpeed EQU $5A4F
DEF CopyOAMDMARoutine EQU $5AA9
DEF LoadSave EQU $4087

Reset::
; `and a` sets flags from A, then `cp` replaces them. The compare picks the path.
    and a
    cp $11
    ld a, $00
    jr nz, .not_cgb
    inc a
.not_cgb:
    ld [hCGB], a
    ld sp, wStackTop
; Wait for vblank and turn the LCD off when the boot ROM left it on.
    call TurnOffLCD
    ld a, [hCGB]
    and a
    jp z, NonCGBLockup
; Infrared off, cartridge SRAM disabled, MBC5 bank bit 8 clear.
    xor a
    ld [rRP], a
    ld [rRAMG], a
    ld [rROMB1], a
; Overflow every 65 ticks. The double-speed switch below doubles that rate.
    ld a, $bf
    ld [rTMA], a
    ld a, TACF_START
    ld [rTAC], a
; Map bank 7 and mirror it. A callee may switch banks, so each call sets it again.
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call SwitchToDoubleSpeed
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
; Copy the 10-byte $C000 OAM DMA stub onto HRAM at $FF80.
    call CopyOAMDMARoutine
; Encoded as a jump, but the target is the next byte.
    jp .clear_wram

.clear_wram:
    ld hl, wWRAM
    ld bc, wStackTop - STACK_GAP - wWRAM
; FillMemory writes E for BC bytes. A is unused by the callee.
    ld a, $00
    ld e, a
    call FillMemory
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
; Select WRAM bank 1 and write the $C91B-$C92A block. Its role is still unknown.
    call InitSoundState
; Hides sprites and stores default pointers. The individual fields are still unknown.
    call InitDefaultState
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
; If the SRAM signature matches bank 7, copy the save into WRAM. Otherwise wipe it.
    call LoadSave
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, INITIAL_SCRIPT_BANK
    ldh [hScriptBank], a
; These two stores are the 3-byte form. The handler bytes above are ldh.
    ld a, LOW(INITIAL_SCRIPT_PTR)
    ld [hScriptPtr], a
    ld a, HIGH(INITIAL_SCRIPT_PTR)
    ld [hScriptPtr + 1], a
    jp ContinueStartup
