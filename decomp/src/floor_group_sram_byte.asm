; Bank 7 arg-table index 7. DispatchBank7Arg enters here with the index
; from $C9FD in E and D cleared. $C9FE is the amount subtracted later.
;
; HL becomes GroupSRAMOrigin plus that index, the same SRAM count
; ClampGroupSRAMByte raises. Control leaves through the tail at $74A6,
; still INCBIN in this bank. That tail maps the SRAM bank at wSRAMBank,
; subtracts $C9FE from the byte at HL, and stores the result floored at
; zero.
;
; GroupSRAMOrigin is the name from clamp_group_sram.asm. wSRAMBank is the
; name from handle_start_press.asm.

; Shared floor-at-zero tail. Still INCBIN.
DEF FloorSRAMByteAtHL EQU $74A6

FloorGroupSRAMByte::
    ld hl, GroupSRAMOrigin
    add hl, de
    jp FloorSRAMByteAtHL
