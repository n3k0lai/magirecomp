# Static story graph (`tools/mn_story_graph.py`)

`python3 tools/mn_story_graph.py ROM [--json out] [--cells MAP x0 y0 x1 y1 width]`

The tool reads the ROM at run time and op sizes from `src/mn/Opcodes.lua`. It embeds no ROM bytes.
Map entry scripts are found as `65 lo hi 4F` (bank $4F map record, 15 bytes each). The `64` trigger
list (bank $21: count, then 4-byte {kind, bank, ptr}, cell $C0+i, kind 1 up / 2 down / 3 right /
4 left) and the `69` A list (bank $21: count, then 4-byte {kind, bank, ptr}, cell $40+i) are walked
the same way. Every op is decoded into effects: story stores (`A9`), flag OR/AND/set (`AF`/`AE`/`AC`/`AD`/`A5`-`A7`),
tests (`43`/`49`/`4B`), chests (`A4`), rect copies (`7E`/`7F`), cell writes (`80`/`81`, `03`/`04`/`0D`/`0E`
record-relative), overlays (`68`), door pairs (`01`/`02`), spawns (`05`) and map loads (`65`). `collision()`
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
story `$17`. Story `$10` is maps 187-189. The other level-5 source is the 2A:50AE preset (maps 40/42), and
its selector is still INCBIN. The port now models the `$01`/`$02` layer walks (CountCellRun 01:517C,
dispatch 01:51B6). See docs/mn-outliers.md for the level table.

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

| word | store (A9) | reached from (map: script) |
|---|---|---|
| $01 | 1F:5011, 2A:50C7 | 40/42: 2A:50AE, 216 |
| $02 | 23:73AD | 63, 64, 54 |
| $03 | 13:5D5F | 61: 13:4163 |
| $04 | 14:6BCF | 1,2,3,7,8 |
| $05 | 1D:5D45 | 223-225 |
| $06 | 1A:672C | 24: 1A:65CE, 25: 1A:66CB |
| $07 | 1D:465D | 223, 225, 277, 278 |
| $08 | 22:6498 | 76-81 (1C:4FB5...) |
| $09 | 15:4CCB, 2A:50D9 | 40/42 |
| $0A | 13:6C74 | 125, 126, 129-132 |
| $0B | 22:6BB9, 2A:510E | 40/42 |
| $0C | 1A:76B9 | 145, 146 |
| $0D | 1E:75FD | 144: 1E:72B4 -> `$8E` pick path -> 1E:75EA |
| $0E | 1E:55E6 | 135, 141 |
| $0F | 2A:5115, 28:63BE, 19:7838 | 40/42; 134/146/189 via 28:63B6 |
| $10 | 1F:7B0B | 187 1F:694F/6958, 188 1F:74F5, 189 |
| $11 | 1C:42A9 | 137 |
| $12 | 2F:473C, 25:73BC | 368 (`$05` running script 1C:49BC); 281 via 2F:473F |
| $13 | 25:74A0 | 240: 18:636F |
| $14 | 18:52B4 | 267: 18:4B6F, 270: 18:5264 |
| $15 | 23:67E1, 23:6953 | 63 |
| $16 | 17:71AF | 310 |
| $17 | 19:6477 | 283, 290 |
| $18 | 24:7F41 | 340 |
| $19 | 15:6058 | 191-195: 15:5F5E |
| $1A | 15:604A | 191-195: 15:5F5E |

Selections on the story word (`4B`/`49`, and `43` with expr `0F 04 05 v`, story == v) for $0F-$1A: 134 12:7183,
135 17:6B34 / 1E:5B90 / 1E:69D9 ($0F, $10); 255/277/278 1B:4E6E ($12-$14); 288 1A:4970 and 290 19:638C ($16);
223/225 1D:489A ($17); 2/70 13:53D9, 35 23:7C2B / 28:53EF, 40 16:62E1, 61 14:50C8 ($18-$1A).

- **Gauntlet neighbour 19:6386** (map 290's `$45` target from trigger `$C1` 1A:4B10): it sets `$A2B2` = 1 and,
  when story == `$16` (the `43` at 19:638C), jumps to 19:63BF, which sets `$A3A3` = 5 and stages the gauntlet;
  19:6477 then stores `$17`. Its sibling Unused_Script_19_62AA (the Thunder battle) has no caller.
- **Post-game** is `$19`/`$1A` (15:5F5E, the stay choice on 191-195): `$A1A5` bit 1 (Orwin not cured) picks
  `$19`, cured picks `$1A`. Nothing stores a later word.

## Unresolved

- Every story store `$01`-`$1A` is attributed. The earlier misses were tool bugs. The tool read `$05`
  operand 12-14 as the running script, but opcode_05.asm puts it at 9-11. It also stopped at `$86`, `$94`
  and `$8E`, which all resume (MarkScriptDone21B2 resumes at the next byte; the `$8E` pick path continues
  past the list).
- Attribution is reachability: the walk follows far targets (`45`, `43`, `09`, `59`-`5B`, `05`) up to a
  limit, so a shared script can show up under several maps.
- About 25 ops are unsized (`tab`/`rec` variants with data-dependent length), so those walks stop early.
- The `$8E` resume after `ret nz` (`$CD49 != 0`) is in INCBIN (docs/mn-outliers.md).
