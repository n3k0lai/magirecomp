; Bank 4's $704B. Called from StageC9E4ThenCall704B after one script
; byte is stored at $C9E4. TableWordForC9E4 turns that index into the
; pointer at wEntryRecordField ($C9DE/$C9DF). $6FC5 (still INCBIN) reads
; that pointer and copies the record into $C9CD–$C9D2, $C9D5–$C9DB, and
; $C9BE/$C9BF. Bank 0 at $3493 (still INCBIN) then uses those fields.
; ROM bank 4 is already mapped; this routine does not touch rROMB0.

ApplyC9E4TableEntry::
    call TableWordForC9E4
    call $6FC5
    call $3493
    ret
