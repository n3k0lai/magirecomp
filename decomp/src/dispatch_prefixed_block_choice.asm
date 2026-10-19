; Bank 3 at $65D9. SetupPrefixedBlockChoice jumps here after it arms
; the slot and turns the LCD on.
;
; Each pass stores $FF at $CCA7, calls RefreshChoiceCursor in this bank,
; and runs RefreshFrame. $FF means the choice is still open. $CD81 is
; the slot index and $CCC9 is the index latched on the previous pass.
; A match loops immediately. A new index in $03-$0A jumps to $6C5C.
; Any other new index plants $6C9E in bank 3 at wCallback, runs
; RefreshFrame, restores IdleCallback at $29A4, and loops.
;
; $FE jumps to $6CA8. $0B jumps to $6653. $0C jumps to $667E. $00 and
; $01 jump to $6B7A. $02 jumps to $7637. Any other value reads $CCCB:
; zero jumps to $6A4D, and a nonzero mode jumps to $6930.
;
; CallBankedHL, RefreshChoiceCursor, RefreshFrame, IdleCallback,
; wCallback, and wCallbackBank are already named. $6653, $667E, $6930,
; $6A4D, $6B7A, $6C5C, $6C9E, and $6CA8 are still INCBIN. $7637 is the
; name from dispatch_armed_choice.asm. CHOICE_STILL_WAITING, CHOICE_FE,
; CHOICE_0B, CHOICE_0C, CHOICE_00, CHOICE_01, CHOICE_02, and BANK3_CHOICE
; are the names from that file. CHOICE_MODE is the name from
; setup_prefixed_block_choice.asm. wUnknownCD81 is the name from
; handle_start_press.asm.

; Still INCBIN. Planted at wCallback for a slot index outside that range.
DEF Bank3_6C9E EQU $6C9E

; First and last index the $6C5C scan accepts.
DEF SLOT_SCAN_FIRST EQU $03
DEF SLOT_SCAN_LIMIT EQU $0B

; Previous slot index. place_window_copy_map.asm uses this byte as the
; rows left to copy. This loop latches the slot it last displayed.
DEF wLatchedSlot EQU $CCC9

DispatchPrefixedBlockChoice::
    ld a, CHOICE_STILL_WAITING
    ld [$CCA7], a
    ld hl, RefreshChoiceCursor
    ld e, BANK3_CHOICE
    call CallBankedHL
    call RefreshFrame
    ld a, [$CCA7]
    cp CHOICE_STILL_WAITING
    jr z, .stillWaiting

    cp CHOICE_FE
    jp z, StepPrefixedBlockChoiceFE

    cp CHOICE_0B
    jp z, StepPrefixedBlockChoice0B

    cp CHOICE_0C
    jp z, StepPrefixedBlockChoice0C

    cp CHOICE_00
    jp z, StepPrefixedBlockChoice00

    cp CHOICE_01
    jp z, StepPrefixedBlockChoice00

    cp CHOICE_02
    jp z, Bank3_7637

    ld a, [CHOICE_MODE]
    cp CHOICE_00
    jp z, SpendPrefixedBlockRecord

    jp AddPrefixedChoiceWord

.stillWaiting
    ld a, [wUnknownCD81]
    ld c, a
    ld a, [wLatchedSlot]
    cp c
    jp z, DispatchPrefixedBlockChoice

    ld a, c
    ld [wLatchedSlot], a
    ld b, SLOT_SCAN_LIMIT
    ld a, SLOT_SCAN_FIRST

.scanSlot
    cp c
    jp z, PlantLatchedSlotDigits

    inc a
    cp b
    jr nz, .scanSlot

    ld a, BANK3_CHOICE
    ld [wCallbackBank], a
    ld a, LOW(Bank3_6C9E)
    ld [wCallback], a
    ld a, HIGH(Bank3_6C9E)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    jp DispatchPrefixedBlockChoice
