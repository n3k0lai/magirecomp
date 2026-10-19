; Handler planted by opcode $9C at $23A7.
;
; BC is the live script pointer and is saved across the call. Bank 3 at
; $4141 runs through CallBankedHL. That routine is what writes [$CCA7]:
; opcode $9C left $FF there, and $FF means the slot is still open.
;
; [$CCA7] is held in L. BC is restored, and $FF returns with this handler
; still planted. Any other value is a slot index. The index is tripled
; with two `add a, l` steps, zero-extended, and added to BC. That sum is
; stored as hScriptPtr, high byte then low, in the three-byte form.
; hScriptHandler becomes EnterScriptFromLookup ($1465), and this returns.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.
; CallBankedHL is the name from call_hl_in_bank.asm. EnterScriptFromLookup
; is the name from enter_script_from_lookup.asm. $CCA7 has no name on
; this path. Bank 3 at $4141 is still INCBIN; its file address is $00C141.

; Bank 3, still INCBIN. CPU address while that bank is mapped.
DEF Bank3PollArmedSlot EQU $4141

CommitArmedSlotChoice::
    push bc
    ld hl, Bank3PollArmedSlot
    ld e, $03
    call CallBankedHL
    ld a, [$CCA7]
    ld l, a
    cp $FF
    pop bc
    ret z
    ld a, l
    add a, l
    add a, l
    ld l, a
    ld h, $00
    add hl, bc
    ld a, h
    ld [hScriptPtr + 1], a
    ld a, l
    ld [hScriptPtr], a
    ld a, LOW(EnterScriptFromLookup)
    ld [hScriptHandler], a
    ld a, HIGH(EnterScriptFromLookup)
    ld [hScriptHandler + 1], a
    ret
