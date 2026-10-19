; Bank 4 at $6AFA. CopyBCPlantHandlerCall6AFA calls this after BC is
; copied to hScriptPtr, $0A66 is planted as hScriptHandler, and bank 4
; is mapped. Callers have already stored the step limit at $C9FA and a
; word at $C9F4. This routine does not read those, and it does not
; write rROMB0.
;
; $C9F9 is set to $FF and $C9FB to $7A. The word at $C9F2 is set to
; $6ABF (low byte first), the step routine still in this bank. $C9F6
; is stored with `ld a, $00` and $C9F7 with $90, so that word is $9000.
; HL is $5C9D and E is $07; CallBankedHL maps that bank, calls HL, and
; maps bank 4 again. $C9F8 is then $01. The word at $C9F0 is $6CB4.
; $C9EC is $A8. `xor a` clears $C9EB and $C9EE.
;
; $C9EC, $C9EB, $C9EE, and the word at $C9F0 are the names used by
; StepPlantedRecord. CallBankedHL is the name from call_hl_in_bank.asm.
; What $C9F2, $C9F6, $C9F8, $C9F9, and $C9FB do is still unknown.

; Step routine stored little-endian at $C9F2. Still in this bank.
DEF ROW_MASK_STEP EQU $6ABF

; Word stored at $C9F6. Low byte is an explicit `ld a, $00`.
DEF ROW_MASK_VRAM EQU $9000

; Bank 7 routine passed to CallBankedHL. Still INCBIN.
DEF ROW_MASK_BANK7_FN EQU $5C9D

; ROM bank in E for that call.
DEF ROW_MASK_BANK EQU $07

; Little-endian word stored at $C9F0 after the banked call.
DEF ROW_MASK_RECORD EQU $6CB4

; Byte stored at $C9EC. StepPlantedRecord reads this as an index limit.
DEF ROW_MASK_LIMIT EQU $A8

SeedRowMaskAndRecord::
    ld a, $FF
    ld [$C9F9], a
    ld a, $7A
    ld [$C9FB], a
    ld a, LOW(ROW_MASK_STEP)
    ld [$C9F2], a
    ld a, HIGH(ROW_MASK_STEP)
    ld [$C9F3], a
    ld a, LOW(ROW_MASK_VRAM)
    ld [$C9F6], a
    ld a, HIGH(ROW_MASK_VRAM)
    ld [$C9F7], a
    ld hl, ROW_MASK_BANK7_FN
    ld e, ROW_MASK_BANK
    call CallBankedHL
    ld a, $01
    ld [$C9F8], a
    ld a, LOW(ROW_MASK_RECORD)
    ld [$C9F0], a
    ld a, HIGH(ROW_MASK_RECORD)
    ld [$C9F1], a
    ld a, ROW_MASK_LIMIT
    ld [$C9EC], a
    xor a
    ld [$C9EB], a
    ld [$C9EE], a
    ret
