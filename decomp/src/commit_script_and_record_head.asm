; Bank 1 at $5D9B. Idle-script paths in this bank jump here after they
; plant hScriptHandler, hScriptPtr, and the record-head word.
;
; CopyScriptBytes writes the seven HRAM script bytes at $FFA1-$FFA7
; through hScriptDest. WriteRecordHead then stores the ten head bytes
; at $FF8C-$FF95 through hRecordPointer. Both callees are already source.
;
; Callers name this entry CommitScriptAndRecordHead, the EQU in
; plant_handler_and_head_word.asm. That name is already a symbol, so
; this label is CommitScriptRecord.

CommitScriptRecord::
    call CopyScriptBytes
    call WriteRecordHead
    ret
