; Script step at $1946. BC is the script pointer. Seven bytes follow:
; a repeat count, then the six fields CopyGlyph reads.
;
; The count is stored at $FFA6 with ldh. The next byte is wCallbackBank.
; The next word is wGlyphSrc, the word after that is wGlyphDest, and the
; last byte is wGlyphVRAMBank. BC, now past those bytes, is saved at
; hScriptPtr. Those pointer stores are the 3-byte form.
;
; hScriptHandler is planted at .step, also with the 3-byte form, and that
; step runs once before the return. It writes CopyGlyph ($2949) at
; wCallback. $FFA6 is then decremented with ldh. A remaining count is
; stored and the handler stays on .step, which only rewrites wCallback
; and counts down. A count that reaches zero points hScriptHandler at
; INITIAL_SCRIPT_HANDLER ($0A66).
;
; What calls the planted handler, and what the count means beside this
; countdown, is still unknown. $FFA6 has no name yet.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. wCallback and wCallbackBank are the names from
; default_state.asm. wGlyphSrc, wGlyphDest, wGlyphVRAMBank, and CopyGlyph
; are the names from draw_cgb_notice.asm.

ArmCopyGlyphFromScript::
    ld a, [bc]
    inc bc
    ldh [$ffa6], a
    ld a, [bc]
    ld [wCallbackBank], a
    inc bc
    ld a, [bc]
    ld [wGlyphSrc], a
    inc bc
    ld a, [bc]
    ld [wGlyphSrc + 1], a
    inc bc
    ld a, [bc]
    ld [wGlyphDest], a
    inc bc
    ld a, [bc]
    ld [wGlyphDest + 1], a
    inc bc
    ld a, [bc]
    ld [wGlyphVRAMBank], a
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(.step)
    ld [hScriptHandler], a
    ld a, HIGH(.step)
    ld [hScriptHandler + 1], a

.step::
    ld a, LOW(CopyGlyph)
    ld [wCallback], a
    ld a, HIGH(CopyGlyph)
    ld [wCallback + 1], a
    ldh a, [$ffa6]
    dec a
    jr z, .resumeScript

    ldh [$ffa6], a
    ret

.resumeScript::
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
