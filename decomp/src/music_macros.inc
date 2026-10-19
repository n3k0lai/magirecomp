; Song macros for banks $32-$3C. Format: scripts/own/music-format.md.
; Readers: InstallSoundIndex, SeedCountdownFromTable, AdvanceCountdownRecord,
; StepIndexedCountdown, LoadLowerCountdownStream, ReadExpiredLowerCountdown,
; AddLowerCountdownDelta, ReadIndexedCountdownByte.

IF !DEF(MUSIC_MACROS_INC)
DEF MUSIC_MACROS_INC EQU 1

; big-endian word
MACRO bigw
    db HIGH(\1), LOW(\1)
ENDM

; Track record: wait `delta` ticks (high 16 bits of the 24-bit count),
; then start pattern `pattern` on this track's lower slot.
MACRO trk_play
    bigw \1
    db \2
ENDM
; Track end ($FF). The four bytes after it have the loop record's shape
; and are not read.
MACRO trk_end
    bigw \1
    db $FF
    bigw \2
    bigw \3
ENDM
; Track loop ($FE): wait `delta`, then jump to track start + `addend`
; and add `delta2` to the count.
MACRO trk_loop
    bigw \1
    db $FE
    bigw \2
    bigw \3
ENDM

; Pattern events. The first two bytes are tag (high nibble) and a 12-bit
; delta added to the slot's count before the event is read.
MACRO ev_head
    db ((\1) << 4) | HIGH(\2), LOW(\2)
ENDM
; note with a 1-byte (< $80) or 2-byte length
MACRO ev_note
    ev_head \1, \2
    db \3
    IF (\4) < $80
        db \4
    ELSE
        bigw (\4) | $8000
    ENDC
ENDM
MACRO ev_note_long
    ev_head \1, \2
    db \3
    bigw (\4) | $8000
ENDM
; note with a program change (program through the song's program map)
MACRO ev_note_prog
    ev_head \1, \2
    db (\3) | $80, \4
    IF (\5) < $80
        db \5
    ELSE
        bigw (\5) | $8000
    ENDC
ENDM
MACRO ev_note_prog_long
    ev_head \1, \2
    db (\3) | $80, \4
    bigw (\5) | $8000
ENDM
; program change only (tag 0)
MACRO ev_prog
    ev_head 0, \1
    db (\2) | $80
ENDM
; end of pattern (tag $F, $FF)
MACRO ev_end
    ev_head $F, \1
    db $FF
ENDM

ENDC
