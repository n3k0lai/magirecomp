# Static story graph (`tools/mn_story_graph.py`)

`python3 tools/mn_story_graph.py ROM [--json out] [--cells MAP x0 y0 x1 y1 width]`

The tool reads the ROM at run time and op sizes from `src/mn/Opcodes.lua`. It embeds no ROM bytes.
Map entry scripts are found as `65 lo hi 4F` (bank $4F map record, 15 bytes each). The `64` trigger
list (bank $21: count, then 4-byte {kind, bank, ptr}, cell $C0+i, kind 1 up / 2 down / 3 right /
4 left) and the `69` A list (bank $21: count, then 4-byte {kind, bank, ptr}, cell $40+i) are walked
the same way. Every op is decoded into effects: story stores (`A9`), flag OR/AND/set (`AF`/`AE`/`AC`/`AD`/`A5`-`A7`),
tests (`43`/`49`/`4B`), chests (`A4`), rect copies (`7E`/`7F`), cell writes (`80`/`81`, `03`/`04`/`0D`/`0E`
record-relative), overlays (`68`), door pairs (`01`/`02`), spawns (`05`), map loads (`65`) and `$31`
battle tails (win at `$D3CD`, loss at `$D3D0`; dispatch_nonzero_d016.asm). `collision()`
unpacks a map's block record so the cell grid can be checked without running the game.
The generated JSON is not committed (it holds ROM operand values); regenerate it locally.
Test: `python3 tests/tools/mn_story_graph_test.py` (made-up bytes).

## 186 -> 187 (story $0F)

Trigger cells (186 is 64x64; base collision from the map record's block stream):

- `$C0` (3-4, 32) goes back to 185. `$C1` is row 63, x 46-49. `$C2` is row 63, x 54-55. `$C7`-`$C9` are
  interior (27,56 / 37,43 / 60,30).
- `$C3`-`$C6` (1F:62A1-62BC) are **in neither the base grid nor the `$68` overlay** (69:7AD0). Their door
  rebases (x 7, 20, 46, 59 at row 63) mirror 187's up-exits, but no cell carries those values. They look dead.
- `$C1`-`$C6` are all kind 2 (down) and enter 187's entry 1F:7257 (`65` at 1F:730C).
- 187's `$C0`-`$C5` (row 0; 1F:6910-693D, kind 1 up) load 186 rebased to row 63 at x 7 / 20 / 34->45 / 46 /
  53 / 59. So 186 `$C1` pairs with 187 `$C2`, and 186 `$C2` pairs with 187 `$C4`.

Pockets:

- On the base grid, `$C1` sits in a sealed corridor: the x=44 `$82` column (rows 44-56) plus x 44-49, rows
  57-63. `$C2` sits in a sealed pocket at x 49-55, rows 43-63, which holds the chests `$58` (51,44, 1F:680F)
  and `$59` (51,46, 1F:6817).
- Neither pocket connects to the 185 arrival area. **They are the landing corridors of 187's up-exits**, so
  you reach them by walking up out of 187, not from 186.

Every 186 cell write, checked (`7F` overlay->live rects, plus A0/A2/A4/80 cells):

- x 25-31 and x 23-38, rows 15-34 (entry/early rects)
- `$42`: x 16-20, rows 34-48 and x 12-15, rows 42-45
- `$43`: x 25-31, rows 34-42
- `$44` (1F:6434, gated on `$A125` bits `$10`/`$20`): x 25-31, rows 42-49; x 32-43, rows 45-51; x 39-43,
  rows 52-63
- `$45` (1F:6516): x 16-26, rows 48-58
- x 51-52, rows 5-11; `$50`: x 59-61, row 31

None of them writes x>=44 at rows 40-43 or the row-42 wall at x 49-55. The `03` writes at 1F:7356-7376 run
in **187**, not 186.

Reachability (BFS in /tmp-only helper; arrival at (4,31)):

| rects applied | `$02` cells walkable? | `$C1` reachable | `$C2` reachable |
|---|---|---|---|
| none | no / yes | no | no |
| all of the above | no | no | no |
| early + `$42` + `$44` + `$45` (minimum) | **yes** | **yes** | no |

The `$44` rect x 39-43, rows 52-63 brings in a 3-wide `$02` band (x 40-42) running down to row 63 that
joins the `$C1` corridor at row 58. Walking that band is the `$02` layer walk: CountCellRun gives a run of 3,
which needs `$C9A6 >= 5`.

**Answer (resolved from code).** 186 -> 187 on foot needs the `$02` layer walk with `$C9A6 >= 5`.
`$C9A6` is copied from SRAM `$A3A3`. On the story path level 5 is set only after 186: 19:63C3, maps 290/283,
story `$17`. Story `$10` is maps 187-189. The other level-5 source is the 2A:50AE preset (maps 40/42).
The port models the `$01`/`$02` layer walks (CountCellRun 01:517C, dispatch 01:51B6). See docs/mn-outliers.md
for the level table.

Re-derived 2026-11-01 from the lever scripts, not from a dumped plane. Each A-list lever's first press
(mask clear: `$A2` falls through, `$A0` enters its target) unpacks collision `69:7AD0` and blits its `$7F`
rects. After `$40`-`$45` and `$4A`, a flood from the 185 landing (3,32) with World.step's rules reaches
525 cells at mark 3 and none of `$C1`, `$C2`, `$C7`, `$C8`, `$C9`. At mark 5 the same plane reaches `$C1`,
`$C7` and `$C8` (1078 cells) and still not `$C2` or `$C9`. The crossing is the 3-wide `$02` at x 40-42 on
rows 59-63; row 58 has `$00` at x 43, which the layer-2 heads exit onto, then the `$82` column. Treating
every `$09` as open does not add a mark-3 path: a push does not rewrite an `$08` wall. `$C3`-`$C6` still
have no cells.

Other 187 entries:

- 29:4DF3 (`65` 187 at 29:4DF3; script starts at 29:4DF2) is reached only from stub 29:431C (a `45` at
  29:433F).
- Bank `$29` is a chain of 38-byte stubs (29:4021 + 0x26*k). Each one draws map records, calls a bank-`$26`
  routine and waits, then jumps (`45`) to a per-map entry. Each entry then jumps to the *next* stub (29:4DEF
  -> 29:4342, ...).
- It's the travel-card tour. 29:4000 is one `$86` (seed_camera_loop.asm), entered by `$45` from 16:5EEB
  (maps 2/44), 1F:581F and 2A:5E57 (maps 182/183), and it falls into the 29:4001 stub chain.
- `$10` is stored at 1F:7B0B. It's reached from 187 `$C7`/`$C8` (1F:694F / 1F:6958, through 189's entry
  1F:79E5) and from 188 `$C2` (1F:74F5). The {187, 188, 189} cluster has no other outside entry, so `$0F -> $10`
  is gated entirely on getting into 187.

## Story stores ($01-$1A)

| word | store (A9) | story path | also |
|---|---|---|---|
| $01 | 1F:5011 | 216: 2A:6CB5, 2A:6D78 | preset 2A:50C7 via 2A:50AE on 40/42 |
| $02 | 23:73AD | 63, 64, 54 | |
| $03 | 13:5D5F | 61: 13:4163 | also walked from 43 |
| $04 | 14:6B30, 14:6BCF | 8: Korg `$31` win tail 14:6B30 (sets `$A3A3` = 1 and `$A1A5` \|= `$02`); 14:6BCF when the word is already 3 (14:6AAE) | the win tail is reachable from every map whose walked scripts hit that `$31` |
| $05 | 1D:5D45 | 223-225 | |
| $06 | 1A:672C | 24: 1A:65CE, 25: 1A:66CB | |
| $07 | 1D:465D | 223: 1D:48B4, 1D:4F57 (then `$A3A3` = 2 at 1D:4660) | |
| $08 | 22:6498 | 74, 76-82, 279 | |
| $09 | 15:4CCB | 279: 2F:44DE; also 122, 125 | preset 2A:50D9 on 40/42. Unused 2A:5123 stores `$09` and `$A3A3` = 5; nothing reaches it |
| $0A | 13:6C74, 13:6CD9 | 125, 126, 129-133. 13:6C74 is the stone (also `$A2B2` = 1, `$A3A4` = 3). 13:6CD9 is the Ogar `$31` win tail | |
| $0B | 22:6BB9 | 75: 22:6B1B | preset 2A:510E on 40/42 |
| $0C | 1A:76B9 | 145, 146 (script label 1A:76AF) | |
| $0D | 1E:75FD | 144: 1E:72B4 -> `$8E` pick -> 1E:75EA | only when the story word is exactly `$0C` and byte `[$C726]` is `$2A` |
| $0E | 1E:55E6 | 135: 12:760D, 141: 1E:61DC | `$A2B2` = 1 at 1E:55E2, then the store |
| $0F | 19:7838, 28:63BE | 249: 19:77F2 and 250: 19:7AFC (horn); 134: 28:63B6 trig2 | debug 2A:5115 on 40/42 trig9 |
| $10 | 1F:7B0B | 187: 1F:694F/6958, 188: 1F:74F5, 189 | |
| $11 | 1C:42A9 | 137: 1E:4BFE | |
| $12 | 2F:473C, 25:73BC | 368: 1C:48FD reaches both; 281: 2F:473F reaches 25:73BC | `$A3A3` = 4 beside 2F:473C |
| $13 | 25:74A0 | 240: 18:636F | |
| $14 | 18:52B4 | 267: 18:4B6F, 270: 18:5264, 18:52C3 | |
| $15 | 23:67E1, 23:6953 | 63 | |
| $16 | 17:71AF | 310: 17:71FC | |
| $17 | 19:6477 | 283: 19:63C8, 290: 1A:4B10 | `$A3A3` = 5 at 19:63C3, before the store |
| $18 | 24:7F41 | 340: 24:7F1E, 331: 24:6D51 | |
| $19 | 15:6058 | 191: 15:5F5E | `$A1A5` bit 1 (mask `$02`) set jumps to 15:6058; clear falls through to `$1A` |
| $1A | 15:604A | 191: 15:5F5E | the clear side of that `$43` |

Selections on the story word (`4B`/`49`, and `43` with expr `0F 04 05 v`, story == v) for $0F-$1A: 134 12:7183,
135 17:6B34 / 1E:5B90 / 1E:69D9 ($0F, $10); 255/277/278 1B:4E6E ($12-$14); 288 1A:4970 and 290 19:638C ($16);
223/225 1D:489A ($17); 2/70 13:53D9, 35 23:7C2B / 28:53EF, 40 16:62E1, 61 14:50C8 ($18-$1A).

- **Gauntlet neighbour 19:6386** (map 290's `$45` target from trigger `$C1` 1A:4B10): it sets `$A2B2` = 1 and,
  when story == `$16` (the `43` at 19:638C), jumps to 19:63BF, which sets `$A3A3` = 5 and stages the gauntlet;
  19:6477 then stores `$17`. Its sibling Unused_Script_19_62AA (the Thunder battle) has no caller.
- **Post-game** is `$19`/`$1A` (15:5F5E, the stay choice on 191-195): `$A1A5` bit 1 (Orwin not cured) picks
  `$19`, cured picks `$1A`. Nothing stores a later word.

## Unresolved

- Every disassembled story store `$01`-`$1A` is attributed. `$31` win and loss tails are followed
  (dispatch_nonzero_d016.asm), which is why 14:6B30 and 13:6CD9 show up. Unused_Script_2A_5123 stores
  `$09` and is not reached. The walk also decoded four `A9` shapes past the last bank-`$1B` script
  (6CB7.asm), on map 198: words `$9E4F` at 1B:7017, 1B:7144 and 1B:71E5, and `$D33D` at 1B:7721.
  Those are not `SC_StoreScriptWordAtA123` sites.
- Attribution is reachability: the walk follows far targets (`45`, `43`, `09`, `59`-`5B`, `05`, `31`)
  up to a limit, so a shared tail can show up under many maps. The "story path" column is the map
  whose own script is the scene; the wider map list in a raw dump is the over-approx.
- 10 unique ops are unsized (`tab`/`rec` variants with data-dependent length), so those walks stop early.
- The `$8E` resume after a forge is source now (docs/mn-outliers.md item 9, `mn_forge_ring_test.lua`).
