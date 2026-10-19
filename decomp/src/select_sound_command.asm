; Pick the sound command the timer overflow calls through wSoundCommand.
; Bank 7 is mapped. The commands themselves sit in ROM0 at $0659-$074F and
; expect ROM bank $30 (see TimerOverflow). Each taken path stores one of
; those addresses and returns.
;
; $C91F is a request. Bit 1 and any leftover nonzero value both select $06FC;
; bit 1 also writes $FF to $C920. Bit 2 selects $0709. Every taken request
; clears $C91F. The second bit-1 test below is unreachable: the first test
; already branched here only when that bit was clear, and it branches again.
;
; With no request, a nonzero $C91E selects $0670. $C921 or $C922, if not
; $FF, select $070D or $071D. A nonzero $C924 with bit 1 set is decremented
; and selects $072D; without that bit, $C92A must be zero to select $074F.
; Otherwise $C92A bit 0 selects $0684 and writes $FF to $C920, bit 1 selects
; $06C1, and any other set bit selects $06F4. The idle command is $066F.

DEF wSoundActive EQU $C91E
DEF wSoundRequest EQU $C91F
DEF wSoundIndex EQU $C920
DEF wSoundSlotA EQU $C921
DEF wSoundSlotB EQU $C922
DEF wSoundCountdown EQU $C924
DEF wSoundSelect EQU $C92A

DEF SOUND_IDLE EQU $066F
DEF SOUND_ACTIVE EQU $0670
DEF SOUND_SELECT_BIT0 EQU $0684
DEF SOUND_SELECT_BIT1 EQU $06C1
DEF SOUND_SELECT_OTHER EQU $06F4
DEF SOUND_REQUEST_BIT1 EQU $06FC
DEF SOUND_REQUEST_BIT1_DEAD EQU $0705
DEF SOUND_REQUEST_BIT2 EQU $0709
DEF SOUND_SLOT_A EQU $070D
DEF SOUND_SLOT_B EQU $071D
DEF SOUND_COUNTDOWN EQU $072D
DEF SOUND_COUNTDOWN_IDLE EQU $074F

SelectSoundCommand:
    ld a, [wSoundRequest]
    and a
    jr z, .no_request

    ld a, [wSoundRequest]
    and $02
    jr z, .request_bit1_clear

    xor a
    ld [wSoundRequest], a
    ld a, $FF
    ld [wSoundIndex], a
    ld a, LOW(SOUND_REQUEST_BIT1)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_REQUEST_BIT1)
    ld [wSoundCommand + 1], a
    ret

.request_bit1_clear:
    ld a, [wSoundRequest]
    and $02
    jr z, .request_bit2

    xor a
    ld [wSoundRequest], a
    ld a, LOW(SOUND_REQUEST_BIT1_DEAD)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_REQUEST_BIT1_DEAD)
    ld [wSoundCommand + 1], a
    ret

.request_bit2:
    ld a, [wSoundRequest]
    and $04
    jr z, .request_other

    xor a
    ld [wSoundRequest], a
    ld a, LOW(SOUND_REQUEST_BIT2)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_REQUEST_BIT2)
    ld [wSoundCommand + 1], a
    ret

.request_other:
    xor a
    ld [wSoundRequest], a
    ld a, LOW(SOUND_REQUEST_BIT1)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_REQUEST_BIT1)
    ld [wSoundCommand + 1], a
    ret

.no_request:
    ld a, [wSoundActive]
    and a
    jr z, .check_slot_a

    ld a, LOW(SOUND_ACTIVE)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_ACTIVE)
    ld [wSoundCommand + 1], a
    ret

.check_slot_a:
    ld a, [wSoundSlotA]
    cp $FF
    jr z, .check_slot_b

    ld a, LOW(SOUND_SLOT_A)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_SLOT_A)
    ld [wSoundCommand + 1], a
    ret

.check_slot_b:
    ld a, [wSoundSlotB]
    cp $FF
    jr z, .check_countdown

    ld a, LOW(SOUND_SLOT_B)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_SLOT_B)
    ld [wSoundCommand + 1], a
    ret

.check_countdown:
    ld a, [wSoundCountdown]
    and a
    jr z, .check_select

    bit 1, a
    jr z, .countdown_other

    dec a
    ld [wSoundCountdown], a
    ld a, LOW(SOUND_COUNTDOWN)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_COUNTDOWN)
    ld [wSoundCommand + 1], a
    ret

.countdown_other:
    ld a, [wSoundSelect]
    and a
    jr nz, .check_select

    ld a, LOW(SOUND_COUNTDOWN_IDLE)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_COUNTDOWN_IDLE)
    ld [wSoundCommand + 1], a
    ret

.check_select:
    ld a, [wSoundSelect]
    and a
    jr z, .idle

    ld a, [wSoundSelect]
    and $01
    jr z, .select_bit1

    ld a, $FF
    ld [wSoundIndex], a
    ld a, LOW(SOUND_SELECT_BIT0)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_SELECT_BIT0)
    ld [wSoundCommand + 1], a
    ret

.select_bit1:
    ld a, [wSoundSelect]
    and $02
    jr z, .select_other

    ld a, LOW(SOUND_SELECT_BIT1)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_SELECT_BIT1)
    ld [wSoundCommand + 1], a
    ret

.select_other:
    ld a, LOW(SOUND_SELECT_OTHER)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_SELECT_OTHER)
    ld [wSoundCommand + 1], a
    ret

.idle:
    ld a, LOW(SOUND_IDLE)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_IDLE)
    ld [wSoundCommand + 1], a
    ret

SelectSoundCommandEnd:
