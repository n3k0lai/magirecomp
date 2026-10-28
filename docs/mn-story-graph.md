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

**Answer.** Static code gives exactly one gameplay path from 186 into 187. Open the `$42`, `$44` and `$45`
rects through their flag-gated scripts, then walk the `$02` band south with `$C9A6 >= 5` into the `$C1`
corridor. The catch is that `$C9A6` is copied from SRAM `$A3A3`, and at `$0F` the warp at 2A:5118 stores
**3**. Only 19:63C3 (map 290, through 1A:4B10) and 2A:50CE (the warp room) store 5. So either:

- the route has to pick up the `$A3A3 = 5` upgrade (map 290 or the warp room) before 186, or
- the port's lack of a layer walk is the blocker.

Both are listed in docs/mn-outliers.md. The port doesn't model the layer walk (`World.hop` only handles runs
of 1 and 2), so the port can't make this move today, whatever the flags are.

Other 187 entries:

- 29:4DF3 (`65` 187 at 29:4DF3; script starts at 29:4DF2) is reached only from stub 29:431C (a `45` at
  29:433F).
- Bank `$29` is a chain of 38-byte stubs (29:4021 + 0x26*k). Each one draws map records, calls a bank-`$26`
  routine and waits, then jumps (`45`) to a per-map entry. Each entry then jumps to the *next* stub (29:4DEF
  -> 29:4342, ...).
- That fits a non-interactive tour (attract/demo or a recap), not a gameplay door. It's unconfirmed, because
  the asm that starts the chain isn't traced.
- `$10` is stored at 1F:7B0B. It's reached from 187 `$C7`/`$C8` (1F:694F / 1F:6958, through 189's entry
  1F:79E5) and from 188 `$C2` (1F:74F5). The {187, 188, 189} cluster has no other outside entry, so `$0F -> $10`
  is gated entirely on getting into 187.

## Story stores ($01-$1A)

| word | store (A9) | reached from (map: script) |
|---|---|---|
| $01 | 1F:5011, 2A:50C7 | 40/42: 2A:50AE, 216 |
| $03 | 13:5D5F | 61: 13:4163 |
| $04 | 14:6BCF | 1,2,3,7,8 |
| $06 | 1A:672C | 24: 1A:65CE, 25: 1A:66CB |
| $07 | 1D:465D | 223, 225, 277, 278 |
| $08 | 22:6498 | 76-81 (1C:4FB5...) |
| $09 | 2A:50D9 | 40/42 |
| $0A | 13:6C74 | 125, 126, 129-132 |
| $0B | 2A:510E | 40/42 |
| $0F | 2A:5115, 28:63BE | 40/42; 134/146/189 via 28:63B6 |
| $10 | 1F:7B0B | 187 1F:694F/6958, 188 1F:74F5, 189 |
| $13 | 25:74A0 | 240: 18:636F |
| $14 | 18:52B4 | 267: 18:4B6F, 270: 18:5264 |
| $19 | 15:6058 | 191-195: 15:5F5E |
| $1A | 15:604A | 191-195: 15:5F5E |

Selections on the story word (`4B`/`49`) for $0F-$1A: 134 12:7183, 135 17:6B34 / 1E:5B90 / 1E:69D9 ($0F, $10);
255/277/278 1B:4E6E ($12-$14); 223/225 1D:489A ($17); 2/70 13:53D9, 35 23:7C2B / 28:53EF, 40 16:62E1 ($18-$1A).

## Unresolved

- Stores for $02, $05, $0C-$0E, $11, $12, $15-$18 aren't found as `A9` in map-reachable scripts. They may
  be `AD`/`A7` word stores to $A123, asm, battle/cutscene scripts, or lookup tables (`45`) the walk can't follow.
- Attribution is reachability: the walk follows far targets (`45`, `43`, `09`, `59`-`5B`) up to a limit, so a
  shared script can show up under several maps.
- About 25 ops are unsized (`tab`/`rec` variants with data-dependent length), so those walks stop early.
- 187's entry 29:4DF3 has no static caller.
