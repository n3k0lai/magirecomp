; Bank 2 at $5272. The next uncovered byte after CopyD107GroupThenScript4A40.
;
; Bank 5 at $405C runs first. That entry is still INCBIN, one byte past
; D104WordTable. [$D385], the step adjustment RaiseStoredMeasure subtracts,
; is incremented. The word at $D107 is the SRAM entry pointer. LoadD110Record
; copies that entry into $D110. $D125 is cleared, then RunPairIdScripts runs
; the pair ids the copy left at $D134 and $D135. [$D126] is OR-ed into $D125.
;
; [$D076] is 1 and [$D077] is 0, so WriteIndexedNamesAndCount prints the
; zero alternate count. [$D103] minus one selects a word at $D36E (wDestList
; in dispatch_nonzero_d016.asm) and stores the $D107 pointer there. The same
; index selects a byte at $D376, which receives [$D06F] (wAdjustedEntry in
; paint_entry_digits_and_choose.asm). That byte then indexes $D37A
; (wEntryMask) and stores 2, the mask paint_indexed_entry_names.asm treats
; as the alternate column.
;
; StoreSlotPairs0214 runs with A = [$D103]. [$D112], the second name id, is
; stored at $C9D8 and [$D103] minus one at $C9D9. CountdownPanelCallbacks in
; bank 4 runs from those two bytes. [$D103] times $37, added to $D147, is
; stored little-endian at $D07B. That is the $37-byte record for this slot.
; [$D071] is set to 1. WriteIndexedNamesAndCount builds the name text.
; $49 $C9 is stored at $C93D so that word points at $C949.
;
; The five-byte script at $C71B is $4C $E0 $4A $66 $0A: bank $4C, pointer
; $4AE0, handler DispatchScriptOpcode. The routine then returns.
;
; LoadD110Record, RunPairIdScripts, StoreSlotPairs0214, MulCByB,
; CountdownPanelCallbacks, CallBankedHL, WriteIndexedNamesAndCount, and
; DispatchScriptOpcode are already source. Bank 5 at $405C and bank $4C
; at $4AE0 are still INCBIN. Their file addresses are $01405C and $0130AE0.

LoadD107EntryThenScript4AE0::
    ld hl, $405C
    ld e, $05
    call CallBankedHL
    ld hl, $D385
    inc [hl]
    ld hl, $D107
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $D110
    call LoadD110Record
    xor a
    ld [$D125], a
    ld hl, RunPairIdScripts
    ld e, $05
    call CallBankedHL
    ld a, [$D126]
    ld hl, $D125
    or [hl]
    ld [hl], a
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    ld a, [$D103]
    dec a
    add a, a
    ld c, a
    ld b, $00
    ld hl, $D36E
    add hl, bc
    ld bc, $D107
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [$D103]
    dec a
    ld c, a
    ld b, $00
    ld hl, $D376
    add hl, bc
    ld a, [$D06F]
    ld [hl], a
    ld c, a
    ld b, $00
    ld hl, $D37A
    add hl, bc
    ld a, $02
    ld [hl], a
    ld a, [$D103]
    call StoreSlotPairs0214
    ld a, [$D103]
    dec a
    ld b, a
    ld a, [$D112]
    ld [$C9D8], a
    ld a, b
    ld [$C9D9], a
    ld hl, CountdownPanelCallbacks
    ld e, $04
    call CallBankedHL
    ld a, [$D103]
    ld b, a
    ld c, $37
    call MulCByB
    ld bc, $D147
    add hl, bc
    ld a, h
    ld [$D07C], a
    ld a, l
    ld [$D07B], a
    ld a, $01
    ld [$D071], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $E0
    ld [hl+], a
    ld a, $4A
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ret
