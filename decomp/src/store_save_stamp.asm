; StoreSaveStamp. WipeSaveBanks calls this after selecting SRAM bank 0, then
; again after selecting SRAM bank 2. SRAM is already enabled.
;
; Writes $22, $8E, $41 just past the forward stamp, then copies the sixteen
; ROM bytes at $4000 to $A002 and those same bytes in reverse to $BFF0.
; $4000 is both the RAM-bank register and the stamp while this bank is mapped.
;
; sSaveStamp, sSaveStampTail, SAVE_STAMP_LEN, and ROM_STAMP are the names from
; check_save_signature.asm. The label cannot be WriteSaveStamp: wipe_save_banks.asm
; already defines that address.

StoreSaveStamp:
    ld a, $22
    ld [sSaveStamp + SAVE_STAMP_LEN], a
    ld a, $8e
    ld [sSaveStamp + SAVE_STAMP_LEN + 1], a
    ld a, $41
    ld [sSaveStamp + SAVE_STAMP_LEN + 2], a
    ld d, SAVE_STAMP_LEN
    ld bc, sSaveStamp
    ld hl, ROM_STAMP

.forward:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .forward

    ld d, SAVE_STAMP_LEN
    ld bc, sSaveStampTail
    dec hl

.reverse:
    ld a, [hl-]
    ld [bc], a
    inc bc
    dec d
    jr nz, .reverse

    ret
