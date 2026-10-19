; Bank 4 at $72ED. PresentInstalledScriptEntries calls this after
; clearing $C9C5, $C9C8, and $C831. Bank 4 is already mapped. This
; routine does not write rROMB0 and does not call out.
;
; A is cleared, then thirteen bytes are stored as zero: $C9BC, $C9C2,
; $C9C4, $C9C0, $C9C1, wScriptLoopToggle ($C9C7), $C9EC, $C9EB, $C9EF,
; $C9EE, $C9FB, $C9FA, and $C9F9. $C9BD is set to $58 and $C9C3 to $20.
; The word at $C9F0 is set to $6C60 (low byte first). $C9F2 through
; $C9F5 are set to $F9, $6A, $F9, $6D. $C9F6 is set with `ld a, $00`,
; $C9F7 to $90, and $C9F8 to $04.
;
; ApplyC9BCScrollThenFrame later masks $C9BC into wCameraPixelX and
; uses $C9C0–$C9C4 and wScriptLoopToggle. ResumeScriptDispatch and
; PlantRecord30 use $C9EC, $C9EB, $C9EE, $C9EF, and the word at $C9F0.
; wScriptLoopToggle is the name from poll_script_loop_buttons.asm.
; What $C9BC–$C9C4, $C9BD, $C9F2–$C9FB, and the seeded constants mean
; is still unknown.

; Byte stored at $C9BD. Role still unknown.
DEF SEEDED_C9BD EQU $58

; Byte stored at $C9C3. Role still unknown.
DEF SEEDED_C9C3 EQU $20

; Little-endian word stored at $C9F0. Same slot PlantRecord30 writes.
DEF SEEDED_RECORD_PTR EQU $6C60

SeedScriptScrollAndRecord::
    xor a
    ld [$C9BC], a
    ld [$C9C2], a
    ld [$C9C4], a
    ld [$C9C0], a
    ld [$C9C1], a
    ld [wScriptLoopToggle], a
    ld [$C9EC], a
    ld [$C9EB], a
    ld [$C9EF], a
    ld [$C9EE], a
    ld [$C9FB], a
    ld [$C9FA], a
    ld [$C9F9], a
    ld a, SEEDED_C9BD
    ld [$C9BD], a
    ld a, SEEDED_C9C3
    ld [$C9C3], a
    ld a, LOW(SEEDED_RECORD_PTR)
    ld [$C9F0], a
    ld a, HIGH(SEEDED_RECORD_PTR)
    ld [$C9F1], a
    ld a, $F9
    ld [$C9F2], a
    ld a, $6A
    ld [$C9F3], a
    ld a, $F9
    ld [$C9F4], a
    ld a, $6D
    ld [$C9F5], a
    ld a, $00
    ld [$C9F6], a
    ld a, $90
    ld [$C9F7], a
    ld a, $04
    ld [$C9F8], a
    ret
