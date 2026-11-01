# Routed stories audit (2026-11-01)

Static read of the decomp scripts and of `tools/mn_story_graph.py` against
`magination.gbc` (JSON kept under `/tmp`). The port column is `src/mn`. A step
**matches** when the port already does what the opcode does. **Fixed** is a
change in this audit. **Diverges** is a port difference that was left in place.

`$A9` (StoreScriptWordAtA123, bank 1 `$27C6`) writes `$A123` and then bank 7
`$40E6` clears `$7F` bytes at `$A125` and at `$A224`. The port does that and
yields to the next pass. `$A8` increments the word and clears the same runs.
No `src/mn` check compares the story word except expression kind 4, which is
LookupIndex4.

## Port fix

Scripted record motion (`$15` / `$4C`, record head `$4A6B` → bank 5 `$67A3` →
ApplyFineXDelta `$67B1` and ApplyFineYDelta `$67E7`) steps the cell when bit 4
of the fine sum is set. It does not read the destination cell. `Sprites.walkGate`
used to allow a wall only when the slot-0 stand-in was already standing in one,
and to refuse every other object any cell but 0. That gate now accepts every
cell. Player steps still use ProbeCells (World.step). Test:
`tests/engine/mn_standin_hop_test.lua`.

The story-graph tool now follows opcode `$31`'s win tail (`$D3CD`) and loss tail
(`$D3D0`), the split in dispatch_nonzero_d016.asm. The port already did
(`ScriptVM` duelTail). The old table missed 14:6B30 and 13:6CD9 for that reason.
Test: `tests/tools/mn_story_graph_test.py`.

## Story words

Preset room 2A:50AE (maps 40/42) is not the story path. It stores `$01` at
2A:50C7, `$09` at 2A:50D9, `$0B` at 2A:510E and `$0F` at 2A:5115, and it can
enter the real `$01` script 1F:5011. Unused_Script_2A_5123 stores `$09` and
`$A3A3` = 5; nothing reaches it.

| Word | Status | Store and what the script does |
|---|---|---|
| `$00` | matches | No `$A9`. New game runs until 1F:5011. |
| `$01` | matches | 1F:5011 from map 216 (2A:6CB5, 2A:6D78). Sets `$A2B2` = 1 just before the store and `$A3A3` = 0 just after. |
| `$02` | matches | 23:73AD from maps 63, 64 and 54. |
| `$03` | matches | 13:5D5F from map 61 (13:4163). The same script is also walked from map 43. |
| `$04` | matches | 14:6B30 is the Korg `$31` win tail: store `$04`, `$A3A3` = 1, `$A1A5` \|= `$02`. 14:6BCF stores `$04` again when the word is already 3 (14:6AAE) and does not set the level. The port's duelTail already entered 14:6B30. The old graph listed only 14:6BCF. |
| `$05` | matches | 1D:5D45 from maps 223-225. |
| `$06` | matches | 1A:672C from maps 24 (1A:65CE) and 25 (1A:66CB). |
| `$07` | matches | 1D:465D from map 223 (1D:48B4, 1D:4F57), then `$A3A3` = 2 at 1D:4660. The old "225, 277, 278" reach list is not in the walk. |
| `$08` | matches | 22:6498 from maps 74, 76-82 and 279. |
| `$09` | matches | 15:4CCB. World map 279 cell 34,21 runs 2F:44DE. Also walked from maps 122 and 125. The old table's "40/42" is the preset 2A:50D9. |
| `$0A` | matches | 13:6C74 (the stone: `$A2B2` = 1, `$A3A4` = 3, then the store) and 13:6CD9 (Ogar `$31` win tail). Maps 125, 126, 129-133. No required item. The old graph listed only 13:6C74. |
| `$0B` | matches | 22:6BB9 from map 75 (script 22:6B1B). Preset is 2A:510E, which is what the old "40/42" column was. |
| `$0C` | matches | Opcode 1A:76B9, script label 1A:76AF. Maps 145 and 146. Same store. |
| `$0D` | matches | 1E:75FD from map 144 (1E:72B4, the `$8E` pick path into 1E:75EA). Both `$43` tests are kind `$10` (inequality): the story word must be exactly `$0C`, and byte `[$C726]` must be `$2A`. The route note said `>= $0C`; that sentence is corrected. Port `VM:expr` kinds 16-20 match lookup_index_16..20.asm. |
| `$0E` | matches | Opcode 1E:55E6 (script 1E:55E2 sets `$A2B2` = 1 first). Reached from 135 (12:760D) and 141 (1E:61DC). The key is `$A1A5` bit 3 (mask `$08`): 1E:620D ORs it in, and 1E:61DC jumps to 1E:6204 → 12:7608 only when that bit is set. |
| `$0F` | matches | Three real stores. The routed horn scene is 19:7838 (249's 19:77F2, 250's 19:7AFC). 28:63BE is 134 trig2 (28:63B6), which clears `$A2B2` and warps toward 185. 2A:5115 is debug trig9, not an Opcode16 operand. The early route note that called 2A:5115 data is corrected. |
| `$10` | matches | 1F:7B0B from maps 187, 188 and 189 only. No port shortcut. Not routed. See 186 below. |
| `$11` | matches | 1C:42A9 from map 137 (1E:4BFE). Not routed. |
| `$12` | matches | 2F:473C and 25:73BC. Map 368's 1C:48FD reaches both; 281 reaches 25:73BC. `$A3A3` = 4 is beside 2F:473C. Not routed. |
| `$13` | matches | 25:74A0 from map 240 (18:636F). Not routed. |
| `$14` | matches | 18:52B4 from maps 267 and 270. Not routed. |
| `$15` | matches | 23:67E1 and 23:6953, both from map 63. Not routed. |
| `$16` | matches | 17:71AF from map 310 (17:71FC). Not routed. |
| `$17` | matches | 19:6477 from maps 283 (19:63C8) and 290 (1A:4B10). Level 5 is 19:63C3 on the story-`$16` path into that scene. Not routed. |
| `$18` | matches | 24:7F41 from maps 340 (24:7F1E) and 331 (24:6D51). Not routed. |
| `$19` | matches | 15:6058. Map 191 script 15:5F5E. `$43` kind 0: `[$A1A5] & $02` nonzero jumps here. Not routed. |
| `$1A` | matches | 15:604A, the fall-through of that test. Not routed. Nothing stores a later word. |

## Underneath geyser (docs/mn-dungeons.md)

Matches. The mechanics table already described the port. The "Gaps" list under
it still read as open work; those four jobs (colored gates, grass, chest
categories 2 and 3, core `$7E` replay) are done. Conveyors are implemented in
Motion/PixelWalk and these planes have none. Ogar's win tail is the ordinary
`$31` path. Chest grant and `$7E` during setup match the asm. The gap prose is
marked as the original job text.

## 186 → 187

Matches. World.step's thresholds are the asm (count-2 hop at `$C9A6 >= 3`,
count-3 `$02` layer at `>= 5`). After the first press of levers `$40`-`$45`
and `$4A` (each unpacks collision `69:7AD0` and blits its own `$7F` rects), a
flood from (3,32) reaches neither `$C1` nor `$C2` at mark 3. At mark 5 it
reaches `$C1` (and interior `$C7` / `$C8`) and still not `$C2` or `$C9`. The
3-wide `$02` is x 40-42 on rows 59-63; row 58's `$00` at x 43 is the layer-2
exit onto the `$82` column. Opening every `$09` as if it had been pushed away
does not add a mark-3 path. `$C3`-`$C6` have no cells. Level 5 on the story
path is 19:63C3, story `$17`, after 187-189. No World.step change.

## Already the same as the asm

- `$A9` clearing by `mem[a] = nil` reads back as 0, and a snapshot skips both
  nil and 0, so a reload does not keep the cleared flags.
- `ListChoice.demo` fills a synthetic shop cost only when `$CCA7` is not `$FF`.
  Live `$8F`/`$90` arm `$FF` before `ListChoice.new`.
- `World.mark` reads `$A3A3`. The only `ld [$c9a6], a` sites are the three
  CopySRAMMarkThenHead routines, which copy `$A3A3`.
- `MN_*` switches are opt-in. The suites were run with none of them set.

## Left in place

| What | Status |
|---|---|
| Scripted step with `x < 0`, `y < 0` or `x >= width` | diverges. The asm steps anyway. The port rejects those so it cannot index off the plane. `y >= height` stays open. No routed step needed the rejected edges. |
| Non-driven object more than 6 cells from its spawn | diverges. The port snaps it home. Story threads set `driven` and are not snapped. |
| `$16` walkers ride the camera | diverges, already recorded in docs/mn-parity.md. The Tavel Gorge kids halt because the camera is at the map top, not because of a cell gate. |
| Mailbox latch `$53`-`$62` | diverges, already recorded in docs/mn-parity.md. No story step here depended on the one-frame case. |
