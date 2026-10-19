; Bank 1 at $5B9C. PlantRightRecordAndBank stores this address as
; hScriptPtr (low at $FFA2, high at $FFA3). The bytes from the record
; head at $5B6E up to here are still INCBIN. rROMB0 is left alone.
;
; A is the pressed-button copy FinishFrame writes to $C9A4 from
; wButtonsPressed. Bit 0 is A. A newly pressed calls $5BA7, still
; INCBIN. That call reads hRecordHead, keeps the low two bits, and
; jumps to one of four bank-1 entries. Control then jumps to
; CommitScriptRecord.
;
; hScriptPtr is the name from reset.asm. hRecordHead is the name from
; write_record_head.asm. wButtonsPressed is the name from main_loop.asm.
; The button bits are the names from read_joypad.asm.

ResumeRightScriptOnA::
    ld a, [$c9a4]
    bit 0, a
    call nz, $5ba7
    jp CommitScriptRecord
