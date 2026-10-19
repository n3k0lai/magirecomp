; Taken when BranchBank1OnScriptByte sees a zero script byte.
;
; SRAM bank wSRAMBank is selected with `add a, $00`, then SRAM is enabled.
; FillBytes writes $00 across $068B bytes at $A019, then $FF across $000A
; bytes at $A118. SRAM bank wSRAMBank + 1 is selected and $1E10 bytes at
; $A025 are filled with $FF. SRAM is disabled. $4799 in bank 2 runs through
; CallBankedHL, which maps that bank and restores this one.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are defined later in
; handle_start_press.asm, so the addresses are written here. rRAMG is the
; name from reset.asm. FillBytes is the name from fill_bytes.asm.
; CallBankedHL is the name from call_hl_in_bank.asm. $4799 in bank 2 is
; still INCBIN. Its file address is $008799.

; Bank 2, still INCBIN. Called after the SRAM fills.
DEF Bank2_4799 EQU $4799

FillSRAMAfterZeroScriptByte::
    ld a, [$c727]
    add $00
    ld [$4000], a
    ld a, $0a
    ld [rRAMG], a
    ld hl, $a019
    ld bc, $068b
    ld e, $00
    call FillBytes
    ld hl, $a118
    ld bc, $000a
    ld a, $ff
    ld e, a
    call FillBytes
    ld a, [$c727]
    add $01
    ld [$4000], a
    ld hl, $a025
    ld bc, $1e10
    ld a, $ff
    ld e, a
    call FillBytes
    xor a
    ld [rRAMG], a
    ld hl, Bank2_4799
    ld e, $02
    call CallBankedHL
    ret
