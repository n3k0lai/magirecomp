; Script helper at $19D9. Copies the next script byte at BC into
; wUnknownC9D8, then the next script word (or the word at $C9E5 when
; bit 7 of the high byte is set) onto wUnknownC9DA. BC is advanced past
; those three bytes and saved as hScriptPtr.
;
; StoreScriptByteAtC9D8 and CopyNextScriptWordOrC9E5 are already source.
; hScriptPtr is the name from reset.asm. The pointer stores are the
; 3-byte form. Nothing here calls or jumps into an INCBIN.

StageScriptByteWordAndSavePtr::
    call StoreScriptByteAtC9D8
    call CopyNextScriptWordOrC9E5
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ret
