; Bank 1 at $4B2D. BC and HL are saved in the script-cell slots from
; opcode_03_continue.asm: C then B at wScriptCellPos, L then H at
; wScriptCellAddr. $19 is stored at $C921. That address is wSoundSlotA
; in select_sound_command.asm, which is included later.
;
; WRAM bank 5 is selected and [HL] is cleared. WRAM bank 3 is then
; selected and [HL] is set to $FC. The bank mirror is left at 3.
; CallBankedHL maps bank 7 and runs $4ADF, still INCBIN, then this
; routine jumps to $5DA2 in this bank, also still INCBIN.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; CallBankedHL is the name from call_hl_in_bank.asm.

; Sound id stored at $C921 before the bank 7 call.
DEF CELL_STAMP_SOUND EQU $19

; WRAM bank where [HL] is cleared, then the bank where [HL] becomes $FC.
DEF CELL_CLEAR_WRAM EQU $05
DEF CELL_MARK_WRAM EQU $03

; Value written at HL once WRAM bank 3 is selected.
DEF CELL_MARK_VALUE EQU $FC

; Bank 7, still INCBIN. Called after both WRAM writes.
DEF StampCellInBank7 EQU $4ADF
DEF STAMP_CELL_BANK EQU $07

StampMapCellInWramBanks::
    ld a, CELL_STAMP_SOUND
    ld [$c921], a
    ld a, b
    ld [wScriptCellPos + 1], a
    ld a, c
    ld [wScriptCellPos], a
    ld a, h
    ld [wScriptCellAddr + 1], a
    ld a, l
    ld [wScriptCellAddr], a
    ld a, CELL_CLEAR_WRAM
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, $00
    ld [hl], a
    ld a, CELL_MARK_WRAM
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, CELL_MARK_VALUE
    ld [hl], a
    ld hl, StampCellInBank7
    ld e, STAMP_CELL_BANK
    call CallBankedHL
    jp PlantHandlerAndHeadWord
