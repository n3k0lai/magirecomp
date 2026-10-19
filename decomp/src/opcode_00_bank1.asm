; Bank 1 continuation of script opcode $00. Opcode00 maps this bank and
; jumps here.
;
; The word at $C9A1 is copied to $C18E. Its low byte is an offset and its
; high byte is a row. MulCByB multiplies that row by wMapRowStride. The
; product plus $D000 plus the low byte is stored at wBank5Ptr. SetupCommand4D
; reads that pointer with WRAM bank 5 mapped. What the two source bytes
; name is still unknown.
;
; $FF is stored at $C6DE. That byte's role is still unknown; SetupDefaultState
; writes the same value. hScriptHandler is then pointed at
; DispatchScriptOpcode with the 3-byte form, and this returns to
; MapScriptBankAndCall.
;
; wMapRowStride is the name from draw_metatile_window.asm. wBank5Ptr is the
; name from setup_command_4d.asm. hScriptHandler is the name from reset.asm.

; Low byte is added. High byte is the row multiplied by the map stride.
DEF wUnknownC9A1 EQU $C9A1

; Copy of that word. What reads it is still unknown.
DEF wUnknownC18E EQU $C18E

; Start of the switchable WRAM window. The high byte is $D0.
DEF WRAM_WINDOW EQU $D000

Opcode00InBank1::
    ld a, [wUnknownC9A1]
    ld [wUnknownC18E], a
    ld a, [wUnknownC9A1 + 1]
    ld [wUnknownC18E + 1], a
    ld b, a
    ld a, [wMapRowStride]
    ld c, a
    call MulCByB
    ld d, HIGH(WRAM_WINDOW)
    ld a, [wUnknownC9A1]
    ld e, a
    add hl, de
    ld a, h
    ld [wBank5Ptr + 1], a
    ld a, l
    ld [wBank5Ptr], a
    ld a, $ff
    ld [$c6de], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
