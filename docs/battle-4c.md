# Bank $4C battle scripts: first decoding pass

Status: catalogued. The move, Fight and spell animations run in the port as
the game's own code (see "Animations in the port" below). Source: the decomp's
`src/battle_scripts_4c.asm` (one script stream, $4000-$5D2C) plus a ROM scan.

## How a battle uses bank $4C
- The battle engine itself is native code in **bank 2 ($47D1-$5188)**. It enters
  bank $4C through **81 call sites** (`ld a,$4C / ld bc,ptr`), planting a
  script record (bank, ptr, handler $0A66) that our existing script VM can run.
  Messages are planted at $C71B, the same talk record the overworld uses, so
  `$9F` strips, `$9A` waits and `$42` parks already work.
- **Screen setup**: `Script4C_4023` loads the OBJ palettes (21:5CC0, the same
  table the overworld uses), fills record $C2CD, spawns object slots $0D, $0E and
  $02-$0B with `$05` (handlers 4A6B/5F04, mostly with the null anim 22:4004),
  places them with `$08` (cell plus fine offsets), wakes them with `$0B`, centres
  the camera on 05,05 (`$84`) and fades in from white (`$6F $0F,$7FFF`).
  `Script4C_4000` is the short variant (palettes, wake, centre).
- **Effects** (most entries) are short object scripts: anim changes (`$14`/`$15`/`$16`),
  countdowns, tile copies (`$6B`), and parks.
- The battle background layout and HUD are drawn by bank-2 native code, not by
  bank $4C. That is the next thing to decode, and it needs a real battle state
  from PyBoy.

## Animations in the port
- Every animation the battle engine stages goes through
  StagePointerUnlessD0B6Matches (02:472E: bank in A, script in BC; it returns
  early when `$D0B6` = `$D103`, stores `$C9CA`/`$C9CC`, `$C9E0` = `$D0DB`,
  `$C9E1` = `$D112`) and RunStagedPointerScript (04:71ED, called at 02:4760).
  All callers pass bank `$4C` except the spell, which passes the group
  record's `+$1F` bank and `+$20/$21` pointer (CopyD107GroupThenScript4A40).
- `mn.fx.Gen.base` runs the Glade battle to its first staging call and keeps
  that machine. Each request (`Gen.cutinFrames`) clones it, sets A/BC, `$D0B6`,
  `$D103`, `$D0DB`, `$D112` and `$C9E4`, and streams frames until the return at
  02:4763. `Battle:playAnim` shows them one per frame and feeds the player's B
  and Start to the game's joypad (HandleScriptLoopB skips).
- Summons run CountdownPanelCallbacks (04:61EB, entered as CallBankedHL does,
  `$C938` = 4) with `$C9D8` = species and `$C9D9` = slot - 1: a palette frame,
  then 20 card tiles copied by `$2949`, one a frame (21 frames). The card's
  BG cells give the picture `Battle` keeps for the slot.
- Checked: the Fight cut-in generated from the base's own staging values is the
  captured Glade clip on all 114 overlapping frames (`mn_battle_anims_test`).

## Counts
{'effect': 130, 'setup': 2, 'message': 83}, 215 entries total.

## Catalogue (entry, kind, op count, bank-2 call sites, first text)
| Entry | Kind | Ops | Calls | Text |
|---|---|---|---|---|
| Script4C_4000 | effect | 16 | 0 |  |
| Script4C_4022 | effect | 1 | 0 |  |
| Script4C_4023 | setup | 42 | 0 |  |
| Script4C_4166 | effect | 3 | 0 |  |
| Script4C_416D | message | 3 | 0 | is immune to |
| Script4C_4184 | message | 3 | 0 | can't heal its |
| Script4C_419D | message | 3 | 0 | has all possible status now. |
| Script4C_41C1 | message | 3 | 0 | has  now. |
| Script4C_41D3 | message | 3 | 0 | is confused! |
| YouCrashedBattleEngineScript41E6 | message | 3 | 0 | You crashed the Battle engin… |
| Script4C_4235 | message | 3 | 0 | is eliminated. |
| IsDefendingScript424B | message | 3 | 0 | is defending. |
| Script4C_425F | message | 3 | 0 | deflates itself. |
| Script4C_4276 | message | 3 | 0 | tries to divert the attack. |
| Script4C_4299 | message | 3 | 0 | drains |
| Script4C_42A8 | message | 3 | 0 | resists the attack. |
| Script4C_42C3 | message | 3 | 0 | is weak against the attack. |
| Script4C_42E6 | effect | 1 | 0 |  |
| Script4C_42E7 | message | 3 | 0 | erupted! All its allies are … |
| Script4C_4320 | message | 3 | 0 | is erupting! |
| Script4C_4333 | message | 4 | 0 | is sentenced. |
| Script4C_434B | message | 3 | 0 | over-exerted itself. |
| Script4C_4366 | message | 3 | 0 | fights |
| NameFocusesScript4376 | message | 3 | 0 | focuses. |
| TonyGainsEnergyScript4386 | message | 4 | 0 | Tony gains  energy by focusi… |
| Script4C_43B0 | message | 3 | 0 | is completely healed! |
| Script4C_43CD | message | 3 | 0 | got hiccups! |
| Script4C_43E2 | message | 3 | 0 | You got  Animite! |
| Script4C_43F9 | message | 3 | 0 | found! |
| Script4C_4406 | message | 3 | 0 | healed for  . |
| Script4C_441C | message | 3 | 0 | hiccups! |
| Script4C_442B | message | 3 | 0 | had its hiccups cured! |
| Script4C_4448 | message | 3 | 0 | is hidden! |
| Script4C_445A | message | 3 | 0 | terminates |
| NameUsesScript446D | message | 3 | 0 | uses |
| Script4C_447A | message | 4 | 0 | is my judge. |
| Script4C_4491 | message | 4 | 0 | is guilty. |
| Script4C_44A6 | message | 3 | 0 | Skill is up  permanently! It… |
| Script4C_44D9 | message | 3 | 0 | Defense is up  permanently! … |
| Script4C_450E | message | 3 | 0 | Resist is up  permanently! I… |
| Script4C_4542 | message | 3 | 0 | Speed is up  permanently! It… |
| Script4C_4575 | message | 3 | 0 | Strength is up  permanently!… |
| Script4C_45AB | message | 3 | 0 | Tony was defeated. |
| DefenseIsDownScript45C2 | message | 3 | 0 | Defense is down  ! |
| ResistIsDownScript45DC | message | 3 | 0 | Resist is down  ! |
| SkillIsDownScript45F5 | message | 3 | 0 | Skill is down  ! |
| SpeedIsDownScript460D | message | 3 | 0 | Speed is down  ! |
| Script4C_4625 | message | 3 | 0 | Strength is down  ! |
| Script4C_4640 | message | 3 | 0 | Luck is down  permanently! |
| Script4C_4663 | message | 3 | 0 | Luck is up  permanently! |
| Script4C_4684 | message | 3 | 0 | is now level  Energy is  . S… |
| Script4C_46FC | message | 4 | 0 | is now level  Energy is  . S… |
| Script4C_478D | message | 3 | 0 | is now level  Energy is  . |
| Script4C_47AF | message | 3 | 0 | mirror is gone! |
| Script4C_47C5 | message | 3 | 0 | reflects the maneuver! |
| Script4C_47E2 | message | 3 | 0 | mirror is weakening! |
| Script4C_47FD | message | 3 | 0 | missed! |
| Script4C_480B | message | 3 | 0 | hits  for   damage. |
| Script4C_4826 | message | 3 | 0 | had its plague cured. |
| Script4C_4842 | message | 3 | 0 | was hurt by the plague. |
| Script4C_4860 | message | 3 | 0 | was eliminated by the plague… |
| Script4C_4884 | message | 4 | 0 | Tony gains  energy for the d… |
| DefenseIsUpScript48B1 | message | 3 | 0 | Defense is up ! |
| LuckIsUpScript48C9 | message | 3 | 0 | Luck is up ! |
| Script4C_48DE | message | 3 | 0 | Resist is up ! |
| SpeedIsUpScript48F5 | message | 3 | 0 | Speed is up ! |
| SkillIsUpScript490B | message | 3 | 0 | Skill is up ! |
| Script4C_4921 | message | 3 | 0 | Strength is up ! |
| Script4C_493A | message | 3 | 0 | has all its stats raised per… |
| Script4C_4967 | message | 3 | 0 | Skill is up  permanently! |
| Script4C_4989 | message | 3 | 0 | Defense is up  permanently! |
| Script4C_49AD | message | 3 | 0 | Resist is up  permanently! |
| Script4C_49D0 | message | 3 | 0 | Speed is up  permanently! |
| Script4C_49F2 | message | 3 | 0 | Strength is up  permanently! |
| Script4C_4A17 | message | 3 | 0 | Tony escapes. |
| TonyCantEscapeScript4A29 | message | 3 | 0 | Tony can't escape! |
| CastsScript4A40 | message | 3 | 0 | casts |
| Script4C_4A4E | message | 3 | 0 | has all non permanent  statu… |
| Script4C_4A7C | message | 3 | 0 | has  no longer. |
| Script4C_4A94 | message | 3 | 0 | has its status affected myst… |
| Script4C_4AC1 | message | 3 | 0 | is stone and  can't act! |
| WasSummonedScript4AE0 | message | 3 | 0 | was summoned. |
| WasSummonedScript4AF5 | message | 3 | 0 | was summoned. |
| AppearsScript4B0A | message | 3 | 0 | appears. |
| Script4C_4B1A | message | 3 | 0 | uses  on a group |
| Script4C_4B32 | message | 3 | 0 | uses  on |
| Script4C_4B44 | message | 3 | 0 | uses  on itself |
| Script4C_4B5B | message | 3 | 0 | Tony wins! |
| Script4C_4B6A | effect | 2 | 0 |  |
| Script4C_4B72 | effect | 1 | 0 |  |
| Script4C_4B73 | effect | 1 | 0 |  |
| Script4C_4B74 | effect | 1 | 0 |  |
| Script4C_4B75 | effect | 1 | 0 |  |
| Script4C_4B76 | effect | 1 | 0 |  |
| Script4C_4B77 | effect | 1 | 0 |  |
| Script4C_4B78 | effect | 1 | 0 |  |
| Script4C_4B79 | effect | 8 | 1 |  |
| Script4C_4BA7 | effect | 17 | 0 |  |
| Script4BCC | effect | 12 | 1 |  |
| Script4C_4C1E | effect | 22 | 0 |  |
| Script4C_4C4F | effect | 8 | 0 |  |
| Script4C_4C5E | effect | 3 | 1 |  |
| Script4C_4C65 | effect | 10 | 0 |  |
| Script4C7E | effect | 6 | 1 |  |
| Script4C_4C9A | effect | 13 | 0 |  |
| Script4CB8 | effect | 8 | 2 |  |
| Script4C_4CE6 | effect | 17 | 0 |  |
| Script4C_4D0C | effect | 4 | 0 |  |
| Script4C_4D1C | effect | 9 | 0 |  |
| Script4C_4D30 | effect | 3 | 0 |  |
| Script4C_4D35 | effect | 3 | 2 |  |
| Script4C_4D3C | effect | 11 | 0 |  |
| Script4D5C | effect | 3 | 3 |  |
| Script4C_4D63 | effect | 11 | 0 |  |
| Script4C_4D81 | effect | 3 | 0 |  |
| FillC31ECopyGlyphsScript4D87 | effect | 6 | 2 |  |
| Script4C_4DA3 | effect | 14 | 0 |  |
| Script4C_4DC6 | effect | 8 | 3 |  |
| Script4C_4DF4 | effect | 28 | 0 |  |
| FillC354CopyGlyphsScript4E4B | effect | 6 | 1 |  |
| Script4C_4E67 | effect | 11 | 0 |  |
| Script4E80 | effect | 8 | 4 |  |
| Script4C_4EAE | effect | 23 | 0 |  |
| Script4C_4EE1 | effect | 6 | 2 |  |
| Script4C_4EFD | effect | 11 | 0 |  |
| Script4F18 | effect | 7 | 3 |  |
| Script4C_4F3C | effect | 15 | 0 |  |
| Script4F64 | effect | 9 | 2 |  |
| Script4C_4F9B | effect | 23 | 0 |  |
| Script4C_4FCC | effect | 2 | 0 |  |
| Script4C_4FD0 | effect | 3 | 0 |  |
| Script4FD5 | effect | 11 | 1 |  |
| Script4C_501E | effect | 20 | 0 |  |
| Script4C_504D | effect | 4 | 0 |  |
| Script4C_505A | effect | 11 | 1 |  |
| Script4C_50A3 | effect | 39 | 0 |  |
| Script4C_5102 | effect | 3 | 0 |  |
| Script5109 | effect | 16 | 2 |  |
| Script4C_517E | effect | 38 | 0 |  |
| ScriptStaged51D0 | effect | 6 | 3 |  |
| Script4C_51EC | effect | 11 | 0 |  |
| Script5205 | effect | 3 | 2 |  |
| Script4C_520C | effect | 11 | 0 |  |
| Script5225 | effect | 4 | 1 |  |
| Script4C_5230 | effect | 9 | 0 |  |
| Script5245 | effect | 9 | 1 |  |
| Script4C_527C | effect | 21 | 0 |  |
| Script4C_52A9 | effect | 3 | 0 |  |
| Script52AE | effect | 6 | 1 |  |
| Script4C_52CA | effect | 14 | 0 |  |
| Script4C_52E9 | effect | 6 | 0 |  |
| Script4C_5305 | effect | 12 | 0 |  |
| Script4C_5320 | effect | 7 | 3 |  |
| Script4C_5345 | effect | 12 | 0 |  |
| Script5360 | effect | 8 | 1 |  |
| Script4C_538D | effect | 16 | 0 |  |
| Script53B3 | effect | 6 | 2 |  |
| Script4C_53CF | effect | 14 | 0 |  |
| Script53EE | effect | 6 | 1 |  |
| Script4C_540A | effect | 14 | 0 |  |
| Script5429 | effect | 14 | 1 |  |
| Script4C_548E | effect | 56 | 0 |  |
| Script4C_5555 | effect | 5 | 0 |  |
| Script4C_5568 | effect | 8 | 0 |  |
| Script4C_557B | effect | 6 | 0 |  |
| Script4C_5597 | effect | 14 | 0 |  |
| Script55BD | effect | 8 | 1 |  |
| Script4C_55EA | effect | 15 | 0 |  |
| Script560E | effect | 5 | 2 |  |
| Script4C_5628 | effect | 10 | 0 |  |
| Script4C_5640 | effect | 7 | 1 |  |
| Script4C_566C | effect | 20 | 0 |  |
| Script5698 | effect | 5 | 2 |  |
| Script4C_56B2 | effect | 12 | 0 |  |
| Script4C_56CF | effect | 4 | 0 |  |
| Script56D6 | effect | 9 | 1 |  |
| Script4C_5714 | effect | 33 | 0 |  |
| Script576A | effect | 8 | 1 |  |
| Script4C_579F | effect | 20 | 0 |  |
| Script4C_57CB | effect | 2 | 0 |  |
| Script57D0 | effect | 5 | 4 |  |
| Script4C_57EA | effect | 12 | 0 |  |
| Script5805 | effect | 5 | 2 |  |
| Script4C_581F | effect | 25 | 0 |  |
| Script5854 | effect | 5 | 4 |  |
| Script4C_586E | effect | 12 | 0 |  |
| Script5889 | effect | 5 | 1 |  |
| Script4C_58A3 | effect | 17 | 0 |  |
| Script58CD | effect | 5 | 1 |  |
| Script4C_58E7 | effect | 16 | 0 |  |
| Script4C_590A | effect | 1 | 0 |  |
| Script590B | effect | 5 | 1 |  |
| Script4C_5925 | effect | 32 | 0 |  |
| Script596F | effect | 7 | 2 |  |
| Script4C_599B | effect | 21 | 0 |  |
| Script59D2 | effect | 8 | 1 |  |
| Script4C_5A07 | effect | 18 | 0 |  |
| Script5A32 | effect | 7 | 5 |  |
| Script4C_5A5E | effect | 14 | 0 |  |
| Script4C_5A7D | effect | 5 | 0 |  |
| Script4C_5A97 | effect | 16 | 0 |  |
| Script4C_5ABF | effect | 6 | 0 |  |
| Script4C_5ADC | effect | 14 | 0 |  |
| Script5B01 | effect | 5 | 1 |  |
| Script4C_5B1B | effect | 13 | 0 |  |
| Script4C_5B38 | effect | 5 | 0 |  |
| Script4C_5B52 | effect | 14 | 0 |  |
| Script5B77 | setup | 5 | 1 |  |
| Script4C_5B97 | effect | 15 | 0 |  |
| Script4C_5BBE | effect | 2 | 0 |  |
| Script4C_5BC4 | effect | 10 | 1 |  |
| Script4C_5C0B | effect | 41 | 0 |  |
| Script5C67 | effect | 9 | 1 |  |
| Script4C_5C9E | effect | 42 | 0 |  |
| Script4C_5D29 | effect | 2 | 0 |  |
