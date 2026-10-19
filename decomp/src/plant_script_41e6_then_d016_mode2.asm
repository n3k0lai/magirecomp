; Bank 2 at $5CC1. The block after EnterD016Mode2. It plants the
; five-byte script record $4C $E6 $41 $66 $0A at $C71B: bank $4C,
; pointer $41E6, handler $0A66 (DispatchScriptOpcode). Bank 5 at
; $5A1A (WaitUntilC71DClears) spins until the stored pointer high
; byte is zero, then this tails into EnterD016Mode2.
;
; CallBankedHL, WaitUntilC71DClears, and EnterD016Mode2 are already
; source. The planted script at bank $4C $41E6 is still INCBIN.

PlantScript41E6ThenD016Mode2::
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $E6
    ld [hl+], a
    ld a, $41
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    jr EnterD016Mode2
