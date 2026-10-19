; Copy the 10-byte OAM DMA stub below onto HRAM at $FF80.
;
; Reset calls this as CopyOAMDMARoutine. That name is the EQU in reset.asm,
; so the entry label here is different. The stub runs from HRAM: it DMAs the
; $C000 sprite buffer and burns 40 cycles while the transfer finishes.

; HRAM destination. $FF80 is the usual home of the OAM DMA routine.
DEF hOAMDMA EQU $FF80

; DMA register. Writing the high byte of the source starts a 160-byte transfer.
DEF rDMA EQU $FF46

; High byte of the $C000 OAM buffer, and the wait count after the DMA write.
DEF OAM_BUFFER_HIGH EQU $C0
DEF DMA_WAIT EQU $28

CopyOAMDMAToHRAM::
    ld c, LOW(hOAMDMA)
    ld b, OAMDMAStubEnd - OAMDMAStub
    ld hl, OAMDMAStub
.copy
    ld a, [hli]
    ldh [c], a
    inc c
    dec b
    jr nz, .copy
    ret

; Bytes copied to $FF80. Executed there, not at this ROM address.
OAMDMAStub:
    ld a, OAM_BUFFER_HIGH
    ldh [rDMA], a
    ld a, DMA_WAIT
.wait
    dec a
    jr nz, .wait
    ret
OAMDMAStubEnd:
