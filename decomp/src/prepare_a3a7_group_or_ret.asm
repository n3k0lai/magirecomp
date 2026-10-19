; Bank 5 at $4B51. Word 2 of D104WordTable. JumpHL enters here for
; [$D104] = 2 and this ret returns through CallWordAt4054ForD104.
;
; WRAM bank 7 is stored at wCurrentWRAMBank and selected with rSVBK.
; wGroupSRAM is set to $A3A7 and wGroupAddend to $5DFF, the same pair
; IndexedSetup hands to the group-byte scan. wGroupScale becomes $22.
; xor a then add a, $0D stores $0D at wUnknownCD81. $4B70, the add, is
; also entered from the still-unlifted tail by jp nc, $4B70.
;
; SRAM bank wSRAMBank is enabled just long enough for CallBankedHL to map
; bank 6 and call $6911. SRAM is then disabled and $0D is subtracted from
; wUnknownCD81. The word at wGroupPointers is loaded into HL. A zero word
; stores $14 in wSoundSlotA and $FE in wChosenSlot, then returns. A
; nonzero word jumps to the next byte, still INCBIN.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, SRAM_ENABLE, and
; wUnknownCD81 are the names from handle_start_press.asm. wGroupPointers
; is the name from write_group_row_digits.asm. wGroupSRAM, wGroupAddend,
; and wGroupScale are the names from scan_group_bytes.asm. wSoundSlotA
; is the name from select_sound_command.asm. wChosenSlot and
; CHOSEN_SLOT_NONE are the names from load_five_sram_entry_digits.asm.
; CallBankedHL is already source.

; Stored in wSoundSlotA when the first group pointer is zero.
DEF GROUP_POINTER_MISS EQU $14

PrepareA3A7GroupOrRet::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $a3a7
    ld hl, wGroupSRAM
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $5dff
    ld hl, wGroupAddend
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $22
    ld [wGroupScale], a
    xor a
.reenterWith0D:
    add a, $0d
    ld [wUnknownCD81], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld hl, $6911
    ld e, $06
    call CallBankedHL
    xor a
    ld [rRAMG], a
    ld hl, wUnknownCD81
    ld a, [hl]
    sub $0d
    ld [hl], a
    ld hl, wGroupPointers
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr nz, .pointerPresent
    ld a, GROUP_POINTER_MISS
    ld [wSoundSlotA], a
    ld a, CHOSEN_SLOT_NONE
    ld [wChosenSlot], a
    ret

.pointerPresent:
