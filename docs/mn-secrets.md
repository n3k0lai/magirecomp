# Magi-Nation optional content (secrets)

A static inventory of the optional content: Hyrens and other off-route creatures,
hidden spots, chests and gives, random picks, input combos and the unused content
left in the ROM. Each row gives the trigger (script, bank:address), where it is
reached from (map numbers, from the block graph), and its status in the port.
No game text or ROM bytes are reproduced here.

Status words: **tested** (implemented from the asm and covered by a made-up-bytes
test), **implemented**, **outlier** (unresolved; see the Secrets section of
docs/mn-outliers.md). Engines and transitions are in docs/mn-engines.md.

## Reproducing

`tools/mn_secrets.py` builds a block graph of every script reachable from the map
roots (map scripts, A lists, trigger lists, `$05` records, `$45`/`$47`/`$4A`/`$63`/
`$65` edges) and reports, with backward chains to the owning maps:

    python3 tools/mn_secrets.py ROM            # full report
    python3 tools/mn_secrets.py ROM --species 9   # one creature id
    python3 tools/mn_secrets.py ROM --chain 17:4FA5

Totals over reachable scripts: 538 `$2E` creature summons across 82 species,
66 gives (`$87`/`$88`), 247 chests (`$A4`), 69 random picks (`$47`).
Test: `tests/tools/mn_secrets_test.py` (made-up bytes).

## Hyrens

All Hyren encounters are ordinary scripts: `$30` music, `$47` random pick, `$25`
battle map record, `$2E` creature setup, `$27` halt. The port runs them with the
generic ops (tested in `mn_op47_test`, `mn_grass_test`, `mn_battle_engine_test`).
`$47` used to pick record 0 outside slot threads, so the Hyren branches of the
mixed picks never ran; it now follows AddDividerStep exactly.

| Hyren (id) | Script | Maps and chain | Status |
|---|---|---|---|
| Timber (72), Leaf (45) | 2F:4106 | map 278; map 277 via trigger `$D8` 2F:40AA; map 226 via 2F:4165 from trigger `$C0` 13:6E35 | tested (generic ops) |
| Cave (13), Mush (48) | 17:4FA5, 17:4FBF | map 167 via `$05` 17:4F84; maps 166, 171 via 17:4E64 from `$05` 17:4E07 | tested; map 167 entry is an outlier (below) |
| Coral (16), Deep (21) | 21:691F, 21:6933, 21:694D | maps 37-39 via `$05` 21:68FE; warps from maps 34, 35, 38, 39 | tested |
| Flame (27), Magma (46) | 17:4FE0, 17:4FF4 | maps 170 and 280; 280 via trigger `$C6` 2F:4588 | tested |
| Core (18) | 15:6A65, 15:6ADC (13 summons) | maps 192-194, walker 15:6A06 | tested |
| Core (18) | 25:61F9 and siblings | maps 201-203, nested picks 25:603F -> 610E -> 61E4 | tested |
| Core (18) | 23:40A5, grass 23:4070 | maps 313-315 | tested |
| Core (18) | 1B:5391, grass 1B:52CA | maps 341-343 | tested |
| Thunder (71) | only in Unused_Script_19_62AA (a bank-19 gauntlet no root reaches) | none | outlier (unused content) |
| Bolt (9) | no `$2E` for id 9 anywhere in the ROM or the lifted scripts | none | outlier |

Hint NPCs (1E:48EA Flame, 1B:4631 Thunder, 25:6946 hidden areas) are plain talk
scripts: implemented.

## Other creatures off the main route

- Never summoned by any reachable script: ids 9, 55, 69, 71, 84, placeholders 86/87
  and 88-108. Creatures can also be gained through bank-4 `$8E` (CallBank4_5494,
  INCBIN), so "never summoned" is not "unobtainable": outlier.
- Id 85 is an ordinary encounter (19 summons: 15:6A50, bank-18 maps 259/260): tested.
- Species 131 at 51:5614 is outside the table; it is a walker misread inside map 40
  (data read as code): outlier note, no port change.

## Hidden spots, chests and gives

| What | Trigger | Status |
|---|---|---|
| Hidden spot, map 105 (top of the north cave) | `$B0` cell; map-entry fallback 19:4BE0 checks action `$2A` there, sets `$A1AE` bit 6, runs 19:4BFF (replay 19:4C7F) | outlier (action `$2A` not traced) |
| Lone `$B0` cells, maps 108 and 101 | not traced | outlier |
| Chests (247) | `$A4` PlantOffset7ThenStoreFF | tested (`mn_chest_test`) |
| Gives (66) | `$87`/`$88` | tested (`mn_chest_test`, `mn_ops_travel_test`) |
| Thunder gauntlet neighbour | 19:6386 (reachable): story `$16` sets `$A2B2` = 1 and `$A3A3` = 5, loads map 283; 19:6477 stores story `$17` | implemented (generic ops); missing from docs/mn-story-graph.md |

## Passwords, combos and debug input

- No password entry and no joypad-sequence compare exists in the lifted asm.
  `PollScriptLoopButtons` only toggles `$C9C7` on Start.
- Sound test: bank 7 `$5997` AdvanceSoundIndexOnA and `$59CA`
  SoundIndexButtonsAfterA (A cycles `$C926` 0-`$28` into wSoundIndex, Start queues
  `$10`, Select queues `$0F`, B steps `$C927` 0-`$27` into wSoundSlotA). Its caller
  is INCBIN, so how it is entered is unknown: outlier.

## Post-game

Not inventoried in this pass: docs/mn-story-graph.md ends at story `$1A`, and content
gated on later values (or on the save after the credits) was not traced: outlier.

## Diff against docs/mn-story-graph.md and the port

- The story graph lists only main-route flag writers; none of the Hyren maps (37-39,
  166/167/170/171, 192-194, 201-203, 226/277/278/280, 313-315, 341-343) gate the story.
- Port divergences found and fixed on this branch: `$47` picks (every thread),
  `$4E`/`$4F` timing (the rock fall played 10x too long), `$41` table index and phase,
  `$7C`/`$7D` nudge stop, `$9D` wait. See docs/mn-engines.md.
