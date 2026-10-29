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
| Thunder (71) | the ring forge (`$8E`, list at 1A:531F); its only `$2E` is in Unused_Script_19_62AA, which no root reaches (cut content) | forge | tested (`mn_forge_ring_test`) |
| Bolt (9) | no `$2E` for id 9 anywhere; obtained through the ring forge (`$8E`, list at 1A:531F, the same list as 71 and 84) | forge | tested (`mn_forge_ring_test`) |

Hint NPCs (1E:48EA Flame, 1B:4631 Thunder, 25:6946 hidden areas) are plain talk
scripts: implemented.

## Other creatures off the main route

- Never summoned by any reachable script: ids 9, 55, 69, 71, 84, placeholders 86/87
  and 88-108. The ring forge covers every id 0-85: 9, 71 and 84 are on the list at
  1A:531F, 55 and 69 on 18:6FD1 and 1B:4BE4. Ids 86-108 are on no forge list and no
  `$2E`: unobtainable placeholders.
- **Ring forge (`$8E`)**: each 8-byte list entry is {id, stock index A, count A, stock
  index B, count B (0 = none), cost lo, hi}. TryAffordOtherChoice (4:`$5A5B`) works
  animite `$A3A5` - cost and stock `$A4A6`[A] - count A (and B when its count is not 0)
  into `$CD4A`-`$CD4F`; any borrow shows the `$5DF5` notice and keeps the window open
  (equal is affordable). CommitOtherChoiceFive (4:`$5CB3`) sets `$CD49` = 1 and `$CD51`
  = id, writes the three totals back and falls into AddSRAMEntryForOperand (4:`$5D19`):
  `$A122`++, the first `$1E` bytes of the bank-4 record for the id are copied to `$CD91`,
  the first free `$25`-byte entry (lead `$FF`) of SRAM bank+1 from `$A025` is filled,
  SpendNewEntryMeasures runs `[$CD50]` - 1 passes and the first `$FF` slot of
  `$A118`-`$A121` gets index + 1. Port: `src/mn/ops/Forge.lua`; tested
  (`mn_forge_ring_test`). The `$CD49` resume after the window is master's.
- **Starter gift (`$2C`)**: `$CD51` = operand 1 (creature id), `$CD50` = operand 2, then
  the same AddSRAMEntryForOperand. Reachable on map 59 at 14:79C6, 14:79E6 and 14:7A06
  (id `$1C`, `$CD50` = 2, 3, 5). It was a no-op in the port; now tested
  (`mn_forge_ring_test`).
- Id 85 is an ordinary encounter (19 summons: 15:6A50, bank-18 maps 259/260): tested.
- Species 131 at 51:5614 is outside the table; it is a walker misread inside map 40
  (data read as code): outlier note, no port change.

## Hidden spots, chests and gives

| What | Trigger | Status |
|---|---|---|
| Hidden spots, maps 101, 105, 108 (`$B0` cells) | Use item id `$2A` (the bank-7 record has no script of its own) from the Start menu item list while standing on the `$B0` cell. SetupCommand4D (bank 6 $6DDF) stores the id at `$C724` and the cell byte under the player (wBank5Ptr `$C190`) at `$C725`, then plants the map fallback from `$95` at `$C714`. The fallbacks 19:48F6 / 19:4BE0 / 19:4D5F test `$C724 == $2A` and `$C725 == $B0`: a hit sets `$A1AE` bit 5 / 6 / 7 and runs 19:490D / 19:4BF7 / 19:4D76; a miss enters 22:4006. Map entry replays the opened state from the bit (19:4995 / 19:4C7F / 19:4DFE) | implemented (`mn_command4d_test`) |
| Chests (247) | `$A4` PlantOffset7ThenStoreFF | tested (`mn_chest_test`) |
| Gives (66) | `$87`/`$88` | tested (`mn_chest_test`, `mn_ops_travel_test`) |
| Thunder gauntlet neighbour | 19:6386 (reachable): story `$16` sets `$A2B2` = 1 and `$A3A3` = 5, loads map 283; 19:6477 stores story `$17` | implemented (generic ops); in docs/mn-story-graph.md (the `$43` story test at 19:638C, map 290 via trigger `$C1` 1A:4B10) |

## Passwords, combos and debug input

- No password entry and no joypad-sequence compare exists in the lifted asm.
  `PollScriptLoopButtons` only toggles `$C9C7` on Start.
- Sound test: bank 7 `$5997` AdvanceSoundIndexOnA and `$59CA`
  SoundIndexButtonsAfterA (A cycles `$C926` 0-`$28` into wSoundIndex, Start queues
  `$10`, Select queues `$0F`, B steps `$C927` 0-`$27` into wSoundSlotA). No call, jump
  or pointer anywhere in the ROM reaches either address: unreferenced (cut) content.
  Not wired into the port.

## Post-game

The post-game is story `$19` / `$1A`, both stored by 15:5F5E on maps 191-195 when the
player chooses to stay. `$A1A5` bit 1 (Orwin not cured) splits it: cured stores `$1A`
(15:604A), not cured stores `$19` (15:6058, the funeral branch). There is no word above
`$1A`. 91 branch targets select on `$19`/`$1A` (`$43`/`$49`/`$4B` on the story word; run
`tools/mn_story_graph.py`): maps 2, 32, 40 and 43-71 (14:50C8 on 61, 14:49B0/49B8,
13:53D9 and 16:4C90 on 2), the 191-197 cluster (15:6C7D-6E49) and 277. They use only ops
the ScriptVM already runs (none of them uses `$29` or `$67`), so the post-game plays
through the generic ops: implemented.

## Diff against docs/mn-story-graph.md and the port

- The story graph lists only main-route flag writers; none of the Hyren maps (37-39,
  166/167/170/171, 192-194, 201-203, 226/277/278/280, 313-315, 341-343) gate the story.
- Port divergences found and fixed on this branch: `$47` picks (every thread),
  `$4E`/`$4F` timing (the rock fall played 10x too long), `$41` table index and phase,
  `$7C`/`$7D` nudge stop, `$9D` wait. See docs/mn-engines.md.
