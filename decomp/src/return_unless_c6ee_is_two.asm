; Gate at $24EC. Opcode $9B and the other script handlers that call here
; continue only when [wUnknownC6EE] is 2.
;
; Otherwise BC is rewound one byte and saved as hScriptPtr (high byte
; first). hScriptHandler becomes Opcode9D ($23D2). pop af drops this
; frame so ret goes to the caller's caller.
;
; wUnknownC6EE is the name from setup_window.asm.
; hScriptPtr and hScriptHandler are the names from reset.asm.

ReturnUnlessC6EEIsTwo::
    ld a, [wUnknownC6EE]
    cp $02
    jr z, .return

    dec bc
    ld a, b
    ldh [hScriptPtr + 1], a
    ld a, c
    ldh [hScriptPtr], a
    ld a, LOW(Opcode9D)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode9D)
    ld [hScriptHandler + 1], a
    pop af
    ret

.return:
    ret
