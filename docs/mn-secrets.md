# Magi-Nation optional content (secrets)

Static inventory of the optional content: Hyren encounters and the chains that
reach them, flag-gated gives and chests, map 167, the map-40 trigger lists,
and the post-game story `$19` / `$1A` split. Each row is an address in the
lifted scripts, the maps that arm it, the precondition the ops actually test,
and the port status. No game text is reproduced.

Status words: **tested** (the op is implemented from the asm and covered by a
made-up-bytes test), **implemented** (the generic handler runs this chain; this
pass found no behaviour to change, so there is no new engine test), **outlier**
(unresolved; see the Secrets section of docs/mn-outliers.md).

The port runs these chains with the generic handlers. No `src/mn` behaviour
changed on this pass.

## Reproducing

`tools/mn_secrets.py` builds a block graph from every `$65 lo hi 4F` root. A
block runs until it returns. `$27` returns: the next ROM byte is the next
record, not a fall-through (`opcode_27.asm`). `$94` ends the frame and the
next byte is still this script. `$31` contributes both triples: after a battle,
`ContinueStartup` runs the first on any result but a loss and the second on a
loss (`ScriptVM` `duelTail`). Edges are far targets (`45` `43` `49` `4B` `9C`
`47` `8E` `A0`-`A3` `31`), `46` jumps, `32` grass, `05` record scripts, `64`
trigger lists and `69` A lists.

    python3 tools/mn_secrets.py ROM
    python3 tools/mn_secrets.py ROM --species 9,13,16,18,21,27,45,46,48,71,72
    python3 tools/mn_secrets.py ROM --chain 17:4FA5

`tests/tools/mn_secrets_test.py` is made-up bytes: a summon after `$94` is
reached, a summon after `$27` is not, and both `$31` triples are reached
through an `op31` edge. A chain union from `Graph.maps` is depth-limited and
includes upstream `$65` roots. The map columns below are the `$65` of the
script that plants the encounter, read from the asm, unless a cell says
"union".

## How an encounter fires

A wandering `$05` with handler `$65A4` does not run its tail itself.
`PlantTailScriptHeadWhenCellMatches` plants head `$64D1` when the record cell
matches the player cell. The port (`Overworld`, the encounter loop) does the
same check the chains use: handler `$65A4`, the object not dormant, Tony's
cell matches (during a ride, the cell he boarded from), and no text or script
is up. It then plants `$4A6B` and runs the record's behaviour script. The asm
also requires `$FFAB` bit 1, `$C6EE` == 0 and a zero third-script high; the
player head latches bit 1 every frame, so the latch was left as it is.

`$47` picks `(divider & $0F) mod count` (`mn_op47_test`). `$2E` is slot,
species, three parameter bytes, then `$27` ends the stream. A `$31` planted
earlier is where the battle returns. Grass is `$32` (the third script). Tables
that start with `$30 $ED $56` enter the bank-7 wipe and do not return into
the tail head.

## Hyrens

Species ids are the `$2E` species byte. Bolt is 9, Cave 13, Coral 16, Core 18,
Deep 21, Flame 27, Leaf 45, Magma 46, Mush 48, Thunder 71, Timber 72. Every
battle row below uses slot 9.

| What | Address | Maps | Preconditions | Port |
|---|---|---|---|---|
| Cave, Mush table | 17:4F84 `$47` of 3: 17:4F98, 17:4FB2, 17:4FC6 | 167 | Tail of the slot `$20` wanderer planted by 17:4D90. Cave `$2E` at 17:4FA5 and 17:4FBF (species 13). Mush `$2E` at 17:4FB9 and 17:4FD3 (species 48). The other `$2E`s in those records are not Hyrens | tested (`mn_op47_test`, `mn_battle_engine_test`) |
| Door into map 167 | 17:5081 | 166, 171, 172 (two entries, 17:52CE and 17:5340), 173, 175, 177, 178, 179 | Slot `$1E` at cell 10,9, tile `$26`, first script 17:5081, tail 17:4D6C. `$11` must match collision `$81`. `$47` of 10: nine records are 17:50C1 (countdown, no `$65A4`); 17:50A9 plants head `$65A4`, runs one slot sequence, then plants `$4A6B`. While the head is `$65A4` and the cells match, tail 17:4D6C `$45`s to 17:4D90, which `$65`s map 167 (`$49C9`) and arms 17:4F84. 17:4E64 is a different table (species `$3A`, `$29`, `$26`) and is not this door | implemented |
| Coral, Deep table | 21:68FE `$47` of 3: 21:6912, 21:692C, 21:6940 | 37 (21:77BA), 38 (21:7821), 39 (21:7897) | Two slots (`$20` and `$1F`), head `$63CE`, cell 10,9, first 22:40DA, tail 21:68FE. Deep `$2E` at 21:691F and 21:6939 (species 21). Coral `$2E` at 21:6933 and 21:694D (species 16). Map 36 (21:7781) is the previous entry in the same file and does not plant this tail. 21:6822 (map 35, flag `$A1A8` mask `$04`) summons species `$53`, `$3D`, `$38`, `$4F` only | tested |
| Flame, Magma table | 17:4FE0 `$47` of 3: 17:4FF4, 17:500E, 17:5022 | 170 (17:4DC4) | Slot `$20`, head `$63CE`, cell 10,9, first 22:40DA, tail 17:4FE0. Flame `$2E` at 17:5001 and 17:501B (species 27). Magma `$2E` at 17:5015 and 17:502F (species 46). 2F:4588 is an upstream `$45` into 17:4DC4 (pair `$17,$0E`), not a second table | tested |
| Timber, Leaf table | 2F:4106 `$47` of 3: 2F:411A, 2F:4134, 2F:4148 | 278 (2F:40C0) | Slot `$20`, tail 2F:4106. Timber `$2E` at 2F:4127 and 2F:4141 (species 72). Leaf `$2E` at 2F:413B and 2F:4155 (species 45). 2F:40AA enters this script (pair `$01,$19`) | tested |
| Core grass | 23:4070 `$47` of 7: 23:4090, 23:40AC, 23:40C1, 23:40CF, 23:40E4, 23:40F9, 23:4115 | 313-340 | `$32` third script, operand pointing at 23:4070, in the bank-23 entries `4327` and `4B5D` and the bank-24 entries `6790`, `6BE8`, `6F54`, `6F87`, `7390`, `7EA5`. Core `$2E` at 23:40A5, 23:40C8, 23:40D6 and 23:40DD (species 18). Unused entries 24:6902 (map 329) and 24:7360 (map 334) plant the same `$32`; the decomp marks both unused (no lifted reader). On map 332, 24:6F87 plants it only while `$A125` mask `$02` is clear, and otherwise enters 23:4DD5, whose map-325 entry plants the same table. 24:6FEE plants it when that mask is set (kind 10, the inverse test) | tested (`mn_grass_test`, `mn_op47_test`) |
| Core, map 203 | 25:61C4 `$47` of 7, tail of both wander slots in 25:6653 | 203 | Core `$2E` at 25:61F9, 25:621C, 25:622A and 25:6231 (species `$12`). 25:6269's species byte is `$18` (species 24), then `$27`, and it is not Core. Unused 25:627E is Core and is not a record of this `$47`. The tails of maps 198, 201 and 202 do not contain species `$12` | tested |
| Core wander | 15:6A06 record 15:6A5E, `$2E` at 15:6A65 | 192 (15:6C36), 193 (15:6C8F), 194 (15:6CE6), 195 (15:6E01) | Each entry `$43`s kind 16 (two words differ) of the story word against `$18`. A hit `$45`s to 22:4192 and does not plant the slots. While the story word is `$18`, slots `$20` and `$1F` tail 15:6A06 | tested |
| Core park pick | 15:69D8 | 191 | Map-191 entry 15:6B0F `$45`s to 15:6923 (`$2B`, then the text falls into 15:697C). 15:697C runs 15:69C2 four times. 15:69C2 is a `$47` of 4: species `$18`, Core species `$12` at 15:69D8, species `$14`, species `$11`. 15:69D8 ends `$42`. It is not a `$25`/`$27` battle. No other script's bank/pointer targets 15:69BD or 15:69C2 | implemented |
| Core, one scripted fight | `$2E` at 1B:5391, script 1B:5377 | 346 (1B:5C83, `$65` `$5446`) | 1B:5C83's `$64` installs list 21:5AB8 (count 4). The fourth entry is kind 1 (moving up) → 1B:5B7B. While `$A126` mask `$04` is clear, 1B:5B7B sets that bit and `$45`s to 1B:5D85; if the bit is set it `$45`s to 22:4004. The text at 1B:5D85 falls through to 1B:5D9C, which plants `$31` win 1B:5DC2 / loss 22:40CE and `$45`s to battle 1B:534F (species `$08`, then `$11`). `$09` plants the slot script and returns (`opcode_09.asm`), so 1B:5DC2 still reaches its own `$31` (win 1B:5C8B / loss 22:40CE) and `$94`. Slot 0's script 1B:5E1A `$45`s to 1B:5377. The `$2E` at 1B:5391 is species `$12`, then `$27`. A win continues at 1B:5C8B (the rest of the map-346 entry). The bit makes this step-up run once | implemented (`$09`, `$31`, `$27` / `duelTail`) |
| Bolt (9) | forge list 1A:531E, id byte at 1A:5360 | forge | No reachable `$2E` of species 9. The `$8E` list has count `$0A` and length word `$0051`. Bolt's id is on it | tested (`mn_forge_ring_test`) |
| Thunder (71) | forge list 1A:531E, id byte at 1A:5368 | forge | No reachable `$2E`. The only `$2E` of species 71 is in Unused_Script_19_62AA, which no root reaches | tested; the battle is outlier 1 |

`$8E` entry layout, the `$CD50` pass count, and the `$2C` starter gift (map 59,
14:79C6 / 14:79E6 / 14:7A06) are unchanged from the earlier forge pass and stay
tested (`mn_forge_ring_test`). The seven lists are 1E:7554, 18:6FD0, 1A:531E,
25:6471, 14:7C37, 15:540B and 1B:4BE3.

Ids with no reachable `$2E` include 9, 55, 69, 71 and 84. 9 and 71 are on
1A:531E; 55 and 69 are on 18:6FD0 and 1B:4BE3. Ids 86-108 are on no forge list
and no `$2E`. Species 131 at 51:5614 is not a summon: no `$64` list entry
points at 51:5601, and the bytes the walker used to report it are the
misaligned walk of list 21:4238 (outlier 5, resolved below).

## Gives and chests

`$87` adds (category, id, count): cat 0 items at `$A3A7+id`, cat 1 stones at
`$A4A6`, cat 2 relics at `$A019`, cat 3 spells, cat 4 the animite word
`$A3A5`. `$88` is the floor/clear sibling (`Travel.lua`): cat 0-2 floor the
byte, cat 3 clears the spell byte (count unused), cat 4 subtracts the count
from the animite word (wraps to 0). Cats 5 and 6 return without a write.
Calling both "gives" hides the floors.

Chests are `$A4`. One chest has a second test in front of the flag. The others
are the ordinary self-gated `$A4` (opened-replay when the LCD is off, else the
flag). The detector that compared the chest's flag word to an earlier `$43`
does not see every non-kind-0 expression; the row below is the one the asm
confirms.

| What | Address | Maps | Preconditions | Port |
|---|---|---|---|---|
| Chest with a story test | 21:69ED, script 21:69E0 | 34, 35 (union of the chest block) | LCD off: jump to the chest (opened replay). Else `$43` kind 15, byte `$A2AE` == 0, jumps to 21:69F5; a nonzero byte falls into the chest. 21:69F5 is kind 17 (second word < first): story word > `$11` jumps to the chest. Story <= `$11` runs 21:6A0F, stores `$A2AE` = 1, and parks, so the next visit takes the chest because the byte is no longer 0. The chest itself is `$A4` flag `$A325` mask `$02`, category 3 id `$02` | tested (`mn_chest_test` for `$A4`; the `$43` is the generic expr) |

Gives with an earlier gate in the same block (the gate is the precondition;
the map column is a depth-8 union and includes upstream roots):

| Address | Op | Cat, id, count | Gate | Union maps | Port |
|---|---|---|---|---|---|
| 13:7545 | `$87` | 0, `$23`, 1 | 13:7501 `$A3` | 226, 230-232 | tested |
| 15:44D5 | `$87` | 0, `$15`, 1 | 15:4465 `$43` | 115-118 | tested |
| 17:561F | `$87` | 0, `$23`, 1 | 17:55AB `$43` | 172-175 | tested |
| 19:69DE | `$87` | 0, `$22`, 1 | 19:69CD `$A2` | 252-254, 281 | tested |
| 1A:49F5 | `$87` | 0, `$15` | 1A:49BD `$43` | 284, 288-290 | tested |
| 1A:4A66 | `$87` | 0, `$15` | 1A:4A3C `$43` | same | tested |
| 1A:4CB5 | `$87` | 0, `$19` | 1A:4C7D `$43` | 214, 282, 285, 292 | tested |
| 1A:4D34 | `$87` | 0, `$19` | 1A:4CFC `$43` | same | tested |
| 1A:50E7 | `$87` | 0, `$13` | 1A:50AF `$43` | 214, 282, 286, 293 | tested |
| 1A:5157 | `$87` | 0, `$13` | 1A:511F `$43` | same | tested |
| 1A:7415 switch | `$87` / `$88` | cat 0 ids `$01`, `$02`, `$0B`, `$14`; cat 2 id `$13` | `$4B` kind 1 on byte `$A2A8` (not the story word). The case targets are the give scripts | — | tested |
| 1A:7AF9 | `$88` | 0, `$1D`, 1 | 1A:7AF5 `$AE` mask `$F7` (bit 3 of `$A1A5`, not bit 1) | 145, 146 | tested |
| 1B:5D68 | `$87` | 0, `$20` | 1B:5D64 `$AF` | 342-344, 346 | tested |
| 1B:6603 | `$87` | 0, `$1C` | 1B:65F6 `$A2` | 344, 345, 349, 351 | tested |
| 1C:48D4 | `$87` | 0, `$1C` | 1C:48D0 `$AF` | 362, 364-366 | tested |
| 1C:74A9, 1C:7909 | `$87` | 0, `$2B` | 1C:749F, 1C:78FF `$43` | includes 40, 42, 72, 82, 83. The map 40 here is an upstream root, not the river-list walk | tested |
| 1E:5451 | `$88` | 0, `$1D` | 1E:544D `$AE` | 135, 138 | tested |
| 1E:6219 | `$87` | 0, `$1D` | 1E:620D `$43` | 141 | tested |
| 1E:6784 | `$88` | 0, `$1D` | 1E:6780 `$AE` | 134, 135, 141 | tested |
| 1F:66CB | `$87` | 4, count `$4B` | 1F:66A4 `$A2` | 134, 185-187 | tested |
| 1F:6732 | `$87` | 4, count `$64` | 1F:6702 `$43` | same cluster | tested |
| 1F:67D5, 1F:680A | `$87` | 4, count `$C8` | 1F:67AD `$A2`, 1F:67E2 `$A2` | same cluster | tested |
| 1F:6FB7 | `$87` | 4, count `$41` | 1F:6F90 `$A2` | 185-188 | tested |
| 22:74C3 | `$87` | 4, count 5 | 22:749D `$A2` | 51, 68 | tested |
| 22:7698 | `$87` | 0, `$29` | 22:7635 `$43` | 51, 68 | tested |
| 25:5EC5 | `$88` | 0, `$21` | 25:5EC1 `$AF` | 199-201, 205 | tested |
| 28:611B / 28:611F | `$87` / `$88` | id `$2A`; `$88` id `$2B` count `$0A` | 28:60F9 `$43` | 48, 59, 71 | tested |
| 28:61B2 / 28:61B6 | `$87` / `$88` | id `$04`; `$88` id `$2B` count 1 | 28:618C `$43` | same | tested |
| 28:6249 / 28:624D | `$87` / `$88` | id `$05`; `$88` id `$2B` count 1 | 28:6223 `$43` | same | tested |
| 28:62E3 / 28:62E7 | `$87` / `$88` | id `$06`; `$88` id `$2B` count 5 | 28:62BC `$43` | same | tested |
| 28:6375 / 28:6379 | `$87` / `$88` | id `$07`; `$88` id `$2B` count 5 | 28:6352 `$43` | same | tested |
| 2A:678F | `$87` | 0, `$15` | 2A:671D `$43` | 182, 183, 226, 277 | tested |
| 2B:40F3 | `$87` | 0, `$0D` | 2B:40A8 `$A3` | 52, 60 | tested |

The remaining `$87` / `$88` in reachable blocks have no earlier gate in that
block. Re-run the tool after the `$31` edges before quoting a new total; the
pre-`$31` count was 40 gated and 55 without a same-block gate. Tests:
`mn_chest_test`, `mn_ops_travel_test`.

## Map 40 trigger lists

Map id 40 is pointer `$4258`. The live entries install a real two-record list:

| Entry | `$64` list | Records |
|---|---|---|
| 2A:4715, 2A:4CAC | 21:4228 | kind 4 → 2A:4000; kind 1 → 2A:4009 |
| 2A:4769, and the later map-40 `$65` in that file whose `$64` operand is `$31 $42` | 21:4231 | kind 4 → 2A:4012; kind 1 → 2A:401B |

Kind 1 is moving up, kind 4 is moving left, anything else is any direction.
2A:4000 and 2A:4012 set pair `$00,$18,$0C,$15` and `$45` to 14:4294. 2A:4009
sets a pair and `$45`s to 2A:5084. 2A:401B is kind 15, story word == `$01`,
jumping to 2A:4BD0, else `$42`. Those four are scripts.

21:4238 is not a list. It is the low byte of pointer `$401B` inside list
21:4231. Unused_Script_21_7953 (also a `$65` of map 40, no lifted reader)
installs `$64 $38 $42`, so the walker treats `$1B` as a count of 27 and walks
off the end of the list. That walk is the species-131 report and the `$38` /
`$9D` "uses" inside map 40. The port's `setTriggers` on the live entries
installs 21:4228 or 21:4231. No port change. Outlier 5 is this artifact.

## Post-game story `$19` / `$1A`

There is no menu and no story compare inside 15:5F5E. 15:5F5E is a `$4B` kind
1 on byte `$A225`:

| `$A225` | Text | Fall-through | What it does |
|---|---|---|---|
| 0 | 15:5F7B | 15:5FC0 | stores `$A225` = 1, plays the anims, `$42` |
| 1 | 15:5FD6 | 15:5FF8 | stores `$A225` = 2, anims, `$42` |
| 2 | 15:600E | 15:6041 | writes the story word, then both arms `$45` 14:50B6 |

`$9F` runs the next opcode after `$FD`. 15:5FC0 and 15:5FF8 have no
bank/pointer inbound, and each ends `$42`, so the only way in is that
fall-through. The story word is written on the visit where `$A225` is already
2. 15:6041: `$43` kind 0, `$A1A5` mask `$02`. If the bit is set, 15:6058 stores
story `$19`. If it is clear, the fall-through 15:604A stores story `$1A`. Both
then `$45` 14:50B6. `$A9` does not clear `$A1A5`.

The bit is set, with story `$04`, by both map-8 entries 14:6B30 and 14:6BCF
(`$AF` mask `$02`). It is cleared by `$AE` mask `$FD` at 23:612A and at
23:6956 (23:6956 stores story `$15` and then clears). 23:6765 jumps to 23:6770
when the bit is already set; that path stores story `$15` and does not clear
the bit. Whether a save can still have the bit set when it reaches 15:6041 is
not settled (outlier, 2026-11-01).

After the store, `$4B` kind 4 (the story word) picks a script. In every site
below, the first `$65` of the `$19` target and of the `$1A` target is the same
map. The difference is which script runs. None of those briefs (first 40 ops,
stop at `$45` or `$27`) contains a Hyren `$2E` or a chest. 1A:7415 is kind 1
on `$A2A8` (the give switch above). 1A:79A9 is kind 3. Neither is this split.

| `$4B` | Cases (value → target) | First `$65` | Union maps of the `$4B` | Port |
|---|---|---|---|---|
| 13:53D9 | `$19` → 13:5181, `$1A` → 13:51A7, `$18` → 13:53F7 | map 61. The fall-through also `$AE`s `$A1A5` mask `$7F` (bit 0, not bit 1) | 2 | implemented |
| 14:50C8 | first case `$01`: 14:512C, 14:56C5, 14:5948 | map 2 | 43, 61 | implemented |
| 14:50E3 | first case `$01`: 14:511B, 14:56C5, 14:5948 | map 2 | 226, 230, 232, 234, 277 | implemented |
| 14:7DF7 | `$19`: 14:7D24, 14:7DD2 | map 59 | 48, 59 | implemented |
| 16:4C90 | first `$01`: 16:4CA7, 16:50FE, 16:471E, 16:4741 | map 43 | 2 | implemented |
| 16:62E1 | `$19`: 16:5655, 16:5801 | map 44 | 43 | implemented |
| 16:6CF3 | `$19`: 16:693F, 16:6965 | map 47 | 44, 55 | implemented |
| 16:7C80 | `$19`: 16:6F7D, 16:7030 | map 48 | 44, 59 | implemented |
| 22:70A2 | 22:7058, 22:707D | map 65 | 51 | implemented |
| 22:729F | 22:7255, 22:727A | map 66 | 51 | implemented |
| 22:7462 | 22:7418, 22:743D | map 67 | 48, 59 | implemented |
| 22:7769 | 22:7710, 22:7735 | map 68 | 51 | implemented |
| 23:570E | 23:529D, 23:52C2 | map 62 | 52, 62 | implemented |
| 23:71EA | first case `$01`: 23:7357 (then `$A9` word `$0002`), 23:724A, 23:7224, 23:70EB, 23:7111 | map 63. The `$0002` store is on the `$01` case | 54, 64 | implemented |
| 23:7C2B | 23:7B69, 23:7B8F | map 64 | 63 | implemented |
| 28:5070 | 28:40C7, 28:457B | map 53 | 51, 54 | implemented |
| 28:53EF | 28:50EA, 28:510D | map 54 | 63 | implemented |
| 28:585C | first case `$02`: 28:5BDF, 28:55E1, 28:5816 | map 55 | 44, 47, 56 | implemented |
| 28:5EA7 | 28:5DAC, 28:5E82 | map 58 | 44, 47, 56 | implemented |
| 2B:4753 | 2B:45B3, 2B:472E | map 60 | 52, 62 | implemented |
| 2B:5963 | 2B:4FE1, 2B:54B0 | map 51 | 44, 65 | implemented |
| 2B:7086 | 2B:65FE, 2B:6624 | map 52 | 60, 62 | implemented |

## Hidden spots, passwords, sound test

Unchanged, and still not outliers:

- Hidden spots on maps 101, 105 and 108: use item id `$2A` from the Start menu
  while standing on the `$B0` cell. SetupCommand4D stores the id at `$C724`
  and the cell byte at `$C725`, then the map fallback tests both. Implemented
  (`mn_command4d_test`).
- No password entry and no joypad-sequence compare. `PollScriptLoopButtons`
  only toggles `$C9C7` on Start.
- Sound test bank 7 `$5997` / `$59CA` has no caller. Not wired into the port.

## Where the old rows were wrong

- Cave was not reached through 17:4E64. That table has no Cave or Mush `$2E`.
- Coral was not summoned on maps 34-35. Those maps' 21:6822 species are not 16 or 21.
- Core grass is 23:4070 on maps 313-340, not 1B:52CA, and not only 313-315.
- The map-203 Core table is the tail of 25:6653 only. It is not nested through 25:603F.
- 15:5F5E does not store `$19` / `$1A`, and it does not read `$A1A5`. The store is 15:6041, on the third `$A225` step. The flag is `$A1A5` bit 1, set on map 8 and cleared at 23:612A and 23:6956. docs/mn-story-graph.md's line that names the flag is that older reading.
- `$88` is a floor or a clear, not a second give.
