; Tail of every main-loop pass. GameLoop calls here after the optional bank 6 hook.
;
; The WRAM bank at $C937 and the ROM bank are saved and restored. $C937 is
; wCurrentWRAMBank and $FF70 is rSVBK; both names are defined later, in
; timer_overflow.asm. Restoring $FF70 is the 3-byte form. The saved value is
; also written back to $C937.
;
; ROM bank 7 is mapped and $4CF5 and $5198 run. What those calls do is still
; unknown. $C843 and $C844 are cleared, then $28E5 runs. Four seven-byte
; script records, at $C706, $C70D, $C714, and $C71B, are loaded, handled, and
; stored back. $C706 is wScriptRecord, defined later in finish_startup.asm.
;
; When $C6EE is zero, the button bytes at $C931-$C933 are copied to $C9A3.
; Otherwise those three bytes are cleared. $C931 is the buttons held,
; wButtonsPressed the ones just pressed, and $C933 the ones just released.
; $FFAA is then copied to $FFAB and cleared. Default state had set both to 3.
;
; ROM bank 1's $407D runs, then $0625, then bank 7's $5897. Those three calls
; are still unknown. hVBlankFlags is set to 7, and $09A0 sets bit 7 and waits
; until that bit clears.
;
; .wram_bank_in_a is $08BE. Bank $70 calls it with the WRAM bank already in A.
; .banks_saved is $08C3. Banks $6F and $76 jump here with both banks already
; pushed. .from_third is $08F0. Bank $50 jumps here to store the HRAM record
; and run $C714 and $C71B. .store_and_run_last is $08FC. Bank $4B calls it.
; .run_last is $08FF. Bank $58 jumps here to run only the record at $C71B.
; .store_and_finish is $0908. Bank $65 calls it to store the HRAM record and
; continue. .clear_buttons is $0912. Bank $24 jumps here to write A three
; times at $C9A3; the fall-through reaches it with A clear. .restore_rom_bank
; is $0951. Bank $3B jumps here with the ROM bank in A and the WRAM bank
; still on the stack.
;
; wCurrentROMBank, rROMB0, and BANK_INIT are the names from reset.asm.
; hVBlankFlags is the name from draw_cgb_notice.asm. wButtonsPressed is the
; name from main_loop.asm. LoadScriptBytes, MapScriptBankAndCall, and
; CopyScriptBytes are the routines at $2928, $0A3A, and $290A.

FinishFrame::
    ld a, [$c937]
.wram_bank_in_a:
    push af
    ld a, [wCurrentROMBank]
    push af
.banks_saved:
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $4cf5
    call $5198
    xor a
    ld [$c843], a
    ld [$c844], a
    call $28e5
    ld hl, $c706
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    ld hl, $c70d
    call LoadScriptBytes
    call MapScriptBankAndCall
.from_third:
    call CopyScriptBytes
    ld hl, $c714
    call LoadScriptBytes
    call MapScriptBankAndCall
.store_and_run_last:
    call CopyScriptBytes
.run_last:
    ld hl, $c71b
    call LoadScriptBytes
    call MapScriptBankAndCall
.store_and_finish:
    call CopyScriptBytes
    ld a, [$c6ee]
    and a
    jr z, .copy_buttons
    xor a
.clear_buttons:
    ld hl, $c9a3
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    jr .after_buttons
.copy_buttons:
    ld hl, $c9a3
    ld a, [$c931]
    ld [hl+], a
    ld a, [wButtonsPressed]
    ld [hl+], a
    ld a, [$c933]
    ld [hl+], a
.after_buttons:
    ld hl, $ffaa
    ld a, [hl+]
    ld [hl-], a
    xor a
    ld [hl], a
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $407d
    call $0625
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $5897
    ld a, $07
    ldh [hVBlankFlags], a
    call $09a0
    pop af
.restore_rom_bank:
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop af
    ld [$c937], a
    ld [$ff70], a
    ret
