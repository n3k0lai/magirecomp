; Bank 7 at $4575. ArmPanelCallback plants this as wCallback after a
; panel write sets $C831. PresentInstalledScriptEntries also calls it
; through CallBankedHL once $4837 returns. Bank 7 is already mapped.
;
; CopyC7ABToBGPalettes writes the $40 bytes at SavedBlockC7AB to the
; background palette port. CopyC7EBToOBJPalettes writes the eight object
; palettes that follow that block. wCallback is then set to IdleCallback
; ($29A4, low byte first). wCallbackBank is left alone.
;
; wCallback and IdleCallback are the names from default_state.asm.
; PanelRefreshCallback in arm_panel_callback.asm is this address.

RefreshSavedPalettes::
    call CopyC7ABToBGPalettes
    call CopyC7EBToOBJPalettes
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
