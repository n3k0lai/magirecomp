; Bank 3 at $6AE6. PlantOneMapListEntry, PlantLatchedSlotDigits, and
; SpendPrefixedBlockRecord call here after the digit list is planted
; at $CCEC. This routine does not write rROMB0.
;
; wCallbackBank becomes 3 and wCallback becomes WalkPlantedMapList for
; one RefreshFrame. That routine copies the planted list onto the map.
; IdleCallback is stored at wCallback again before the return. The
; callback bank stays 3.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. WalkPlantedMapList and RefreshFrame are already
; source.

RefreshFramePlantedMapList::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(WalkPlantedMapList)
    ld [wCallback], a
    ld a, HIGH(WalkPlantedMapList)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret

RefreshFramePlantedMapListEnd:
