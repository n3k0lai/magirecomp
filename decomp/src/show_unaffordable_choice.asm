; Bank 4 at $5DF5. TryAffordOtherChoice jumps here when an SRAM cost
; is larger than the saved value. This bank stays mapped. The routine
; does not write rROMB0.
;
; Three strip blocks point $C93D at wListTailDest and store 1 at $C6EB.
; The tile pointer is written at $C6E9 and again at $C941. The map cells
; are $9DA1, $9DC1, and $9DE1. The first tile of each row is stored at
; $C944 and $C946, $8F sits between them at $C945, and the tile just past
; the row is stored at $C947. $C93B points at $4837, $4841, then $484C.
; The pass count is the row length plus one, via `inc a`: $0A, $0B, and
; $08. $C939 points at StepMapStripGlyph. RunWindowStripPasses runs after
; each block.
;
; RefreshFrame then runs until A or B is pressed ($C932 bits 0 and 1).
; One more RefreshFrame runs, and the routine returns.
;
; plant_window_strip, the window addresses, and wButtonsPressed are
; already defined. RunWindowStripPasses, CallBankedHL, RefreshFrame, and
; StepMapStripGlyph are already source.

DEF UNAFFORD_ROW_1_TILE EQU $8EE0
DEF UNAFFORD_ROW_1_MAP EQU $9DA1
DEF UNAFFORD_ROW_1_LO EQU $EE
DEF UNAFFORD_ROW_1_HI EQU $F8
DEF UNAFFORD_ROW_1_TEXT EQU $4837
DEF UNAFFORD_ROW_1_LEN EQU $0A

DEF UNAFFORD_ROW_2_TILE EQU $8F80
DEF UNAFFORD_ROW_2_MAP EQU $9DC1
DEF UNAFFORD_ROW_2_LO EQU $F8
DEF UNAFFORD_ROW_2_HI EQU $03
DEF UNAFFORD_ROW_2_TEXT EQU $4841
DEF UNAFFORD_ROW_2_LEN EQU $0B

DEF UNAFFORD_ROW_3_TILE EQU $9030
DEF UNAFFORD_ROW_3_MAP EQU $9DE1
DEF UNAFFORD_ROW_3_LO EQU $03
DEF UNAFFORD_ROW_3_HI EQU $0B
DEF UNAFFORD_ROW_3_TEXT EQU $484C
DEF UNAFFORD_ROW_3_LEN EQU $08

; Buttons A and B in wButtonsPressed.
DEF UNAFFORD_PRESS_AB EQU $03

ShowUnaffordableChoice::
    plant_window_strip UNAFFORD_ROW_1_TILE, UNAFFORD_ROW_1_MAP, UNAFFORD_ROW_1_LO, UNAFFORD_ROW_1_HI, UNAFFORD_ROW_1_TEXT, UNAFFORD_ROW_1_LEN
    plant_window_strip UNAFFORD_ROW_2_TILE, UNAFFORD_ROW_2_MAP, UNAFFORD_ROW_2_LO, UNAFFORD_ROW_2_HI, UNAFFORD_ROW_2_TEXT, UNAFFORD_ROW_2_LEN
    plant_window_strip UNAFFORD_ROW_3_TILE, UNAFFORD_ROW_3_MAP, UNAFFORD_ROW_3_LO, UNAFFORD_ROW_3_HI, UNAFFORD_ROW_3_TEXT, UNAFFORD_ROW_3_LEN
.waitPress
    call RefreshFrame
    ld a, [wButtonsPressed]
    and UNAFFORD_PRESS_AB
    jr z, .waitPress
    call RefreshFrame
    ret
