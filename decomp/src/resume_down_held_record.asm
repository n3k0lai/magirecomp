; Bank 1 at $59B5. PlantDownFromDirectionRecord stores this address as
; the record-head word. rROMB0 is left alone.
;
; ReloadRecordRunScriptPointCell runs first. On an even
; hMainLoopCounter (bit 0 clear) the button test is skipped and control
; jumps to $59DC, still INCBIN. That tail is the shared apply path.
; On an odd pass, A is the $c9a3 byte, the copy of wButtonsHeld written
; by FinishFrame. Bit 7 is down. Down held jumps to $59C9, still INCBIN,
; which tests left and right before the same apply path. Down clear
; jumps to PlantDirectionDispatchHead.
;
; hMainLoopCounter is the name from main_loop.asm. wButtonsHeld is the
; name from read_joypad.asm.

ResumeDownHeldRecord::
    call ReloadRecordRunScriptPointCell
    ldh a, [hMainLoopCounter]
    and $01
    jr z, DownHeldApply
    ld a, [$c9a3]
    bit 7, a
    jp nz, DownHeldLeftOrRight
    jp PlantDirectionDispatchHead
