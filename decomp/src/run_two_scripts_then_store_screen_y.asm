; Bank 1 at $5F04, the first byte after CopyFarStampIntoRecord.
;
; RunTwoScriptsFromRecord loads the record at hRecordPointer, runs its
; two script records, and writes the head back. CallBankedHL inside that
; routine maps bank 5 and restores the bank it found. This then stores
; $C8 at hSpriteScreenY ($FF97) and returns. What the constant marks is
; still unknown: the same HRAM byte is a screen Y in QueueSpriteList and
; a slot threshold in WalkPointerSlots.
;
; hSpriteScreenY is the name from queue_sprite_list.asm.
; RunTwoScriptsFromRecord is the name from run_two_scripts_from_record.asm.

RunTwoScriptsThenStoreScreenY::
    call RunTwoScriptsFromRecord
    ld a, $c8
    ldh [hSpriteScreenY], a
    ret
