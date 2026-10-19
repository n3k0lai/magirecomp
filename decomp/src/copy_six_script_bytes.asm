; Skip three bytes at HL, copy six script bytes from BC, and dispatch.
;
; One caller still in INCBIN looks up a record with LookupScriptIndexPointer
; and jumps here, so the six bytes land at record offset 3. Another sets HL
; to $FF8C and jumps here, so they land at $FF8F through $FF94: hObjectFineX,
; hObjectFineY, hObjectCellX, hObjectCellY, and the little-endian word at
; $FF93. What the record fields mean is still unknown. hObjectFineX and the
; three bytes after it are the names from queue_sprite_list.asm.
;
; $0E0C adds whatever DE already holds, then copies six bytes. $0E0D copies
; six bytes at the HL the caller already chose. $0E12 has already stored two
; bytes and left BC on the second source byte; it skips that byte and copies
; four more. $0E14 and $0E17 store A, then three and two further script bytes.
; $0E1B skips the source byte BC still points at and copies one more. Those
; callers are still INCBIN. Every path leaves through jp DispatchScriptOpcode.
; BC is left on the following opcode.

CopySixScriptBytesFromOffset3::
    ld de, $0003
CopySixScriptBytesAdd::
    add hl, de
CopySixScriptBytes::
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
CopySixScriptBytesFromThird::
    inc bc
    ld a, [bc]
CopySixScriptBytesStoreAThenThree::
    ld [hl+], a
    inc bc
    ld a, [bc]
CopySixScriptBytesStoreAThenTwo::
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
CopySixScriptBytesSkipAndCopyOne::
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    jp DispatchScriptOpcode
