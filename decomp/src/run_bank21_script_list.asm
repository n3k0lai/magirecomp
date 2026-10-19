; Bank 0 at $2C97. CallScriptPtrThenMapScriptBank calls this with HL set
; to a word it just read and BC one byte past that word. BC is not used.
;
; The HRAM script record is written back through hScriptDest first. Bank
; $21 is then mapped. The byte at HL is a count, saved at $C999. Zero skips
; the list. Otherwise HL, now the first entry, is saved at $C99A/$C99B
; (low, then high).
;
; Each entry is four bytes. A leading $01 is followed by the bank and
; little-endian pointer of the third script record at $C714. The handler
; there becomes INITIAL_SCRIPT_HANDLER ($0A66). The record is loaded, run,
; and stored, then wCallback runs in wCallbackBank. That repeats while
; $C716, the pointer high byte, stays nonzero. Any other leading byte skips
; the next three bytes. The count in C is saved across each pass because
; the script calls reuse BC.
;
; .handler_low_in_a is $2CD0. The $01 path falls in with A already $66.
; Whether anything calls that address is still unknown.
;
; After the count is spent, the record at wScriptRecord is loaded into HRAM
; and this returns. The caller then maps hScriptBank.
;
; CopyScriptBytes, LoadScriptBytes, MapScriptBankAndCall, and JumpHL are
; the routines at $290A, $2928, $0A3A, and $0789. wCurrentROMBank, rROMB0,
; and INITIAL_SCRIPT_HANDLER are the names from reset.asm. wScriptRecord
; is the name from finish_startup.asm. wCallback and wCallbackBank are the
; names from default_state.asm. BANK_BYTE_SOURCE is the name from
; read_bank21_byte.asm. $C714 is wThirdScriptRecord in setup_command_4d.asm.
; $C999 and $C99A have no names yet.

RunBank21ScriptList::
    push hl
    call CopyScriptBytes
    ld a, BANK_BYTE_SOURCE
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop hl
    ld a, [hl+]
    ld [$c999], a
    and a
    jp z, .reload_primary

    ld c, a
    ld a, h
    ld [$c99b], a
    ld a, l
    ld [$c99a], a
.next_entry:
    ld a, BANK_BYTE_SOURCE
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [hl+]
    cp $01
    jr nz, .skip_entry

    ld a, [hl+]
    ld [$c714], a
    ld a, [hl+]
    ld [$c715], a
    ld a, [hl+]
    ld [$c716], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
.handler_low_in_a:
    ld [$c717], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [$c718], a
    push hl
    push bc
.run_record:
    ld hl, $c714
    call LoadScriptBytes
    call MapScriptBankAndCall
    call CopyScriptBytes
    ld a, [wCallbackBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wCallback + 1]
    ld h, a
    ld a, [wCallback]
    ld l, a
    call JumpHL
    ld a, [$c716]
    and a
    jr nz, .run_record

    pop bc
    pop hl
    dec c
    jr nz, .next_entry

    jr .reload_primary

.skip_entry:
    inc hl
    inc hl
    inc hl
    dec c
    jr nz, .next_entry

.reload_primary:
    ld hl, wScriptRecord
    call LoadScriptBytes
    ret
