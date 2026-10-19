; Bank 0 at $2FC0. LcdOffSetup calls this with the word from the $61C3
; table in BC.
;
; BC points at two counted lists. The first count is how many records to
; copy while VRAM bank 0 is selected. The second count, which follows
; those records, is how many to copy while VRAM bank 1 is selected.
; A zero count skips that bank. $2FE5 copies one record and advances BC.
; That routine is still INCBIN. Both stores to rVBK are the 3-byte form.
; rVBK is the name from setup_window.asm.

DEF CopyOneVRAMRecord EQU $2FE5

CopyMapRecords::
    xor a
    ld [rVBK], a
    ld a, [bc]
    inc bc
    and a
    jr z, .vram_bank1

    ld d, a

.bank0_loop:
    push de
    call CopyOneVRAMRecord
    pop de
    dec d
    jr nz, .bank0_loop

.vram_bank1:
    ld a, $01
    ld [rVBK], a
    ld a, [bc]
    inc bc
    and a
    ret z

    ld d, a

.bank1_loop:
    push de
    call CopyOneVRAMRecord
    pop de
    dec d
    jr nz, .bank1_loop
    ret
