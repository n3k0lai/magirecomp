; Bank 7 at $729D. The first uncovered byte after CunningBlowGroupRecord.
;
; [$D076] (wNameCountFlag) is set to 1 and [$D077] (wNameCountAlt) becomes
; [$CD93], so WriteIndexedNamesAndCount prints that byte. CallBankedHL
; runs bank 5 WriteIndexedNamesAndCount, then this returns.
;
; wNameCountFlag and wNameCountAlt are the names from
; write_indexed_names_and_count.asm. WriteIndexedNamesAndCount and
; CallBankedHL are already source.

StageCd93AsNameCount::
    ld a, $01
    ld [$D076], a
    ld a, [$CD93]
    ld [$D077], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ret

StageCd93AsNameCountEnd:
