; Copy three script bytes from BC into $C9FC and call bank 7 at $7465.
;
; Same shape as CopyThreeBytesCallBank7, which calls $7350 instead. BC is
; the script pointer left by DispatchScriptOpcode. The three bytes land at
; $C9FC through $C9FE with the auto-increment form. What those fields mean
; is still unknown. BC is saved across the call.
;
; $1FDA is the second and third stores. $1FE0 is the bank switch and the
; call. mgbdis names both because other banks contain those addresses, and
; those sites look like data. Whether either is a real entry is unknown.
;
; Bank 7 is stored to wCurrentROMBank and rROMB0, then $7465 runs.
; hScriptBank is written back with the 3-byte load. Control leaves through
; jp DispatchScriptOpcode.
;
; wBank7ArgC9FC is the name from copy_three_c9fc_bank7.asm.
; wCurrentROMBank, rROMB0, and hScriptBank are the names from reset.asm.

CopyThreeBytesCall7465::
    ld hl, wBank7ArgC9FC
    ld a, [bc]
    ld [hl+], a
    inc bc

CopyThreeBytesCall7465Second::
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc

CopyThreeBytesCall7465Tail::
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call DispatchBank7ArgFromIndex7
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop bc
    jp DispatchScriptOpcode
