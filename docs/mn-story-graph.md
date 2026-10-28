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

- Map 186's only ways into 187 are its triggers `$C1`-`$C6` (1F:628F, 6298, 62A1, 62AA, 62B3, 62BC; kind 2,
  down). Each one rebases the door pair (`02`) and enters 187's entry 1F:7257 (`65` at 1F:730C).
- No script reachable from 186 writes x=44 rows 40-43, or the row-42 wall at x 49-55. The only cell writes
  in the box x 40-56, y 38-47 are the `$44` rect at 1F:6492 / 1F:64FE (cols 32-43, rows 45-51) and the chest
  plants `$58` 1F:680F (51,44) and `$59` 1F:6817 (51,46). The `03` writes at 1F:7356-7376 (slots 37-41) run
  in **187** (gated by `$A126` bit `$80` at 1F:734E). They don't run in 186.
- The base collision (block record) has rows 40-41 solid `$08` across x 38-58, and x=44 rows 44-48 is a `$82`
  run. The `$68` overlay that 186's entry unpacks (65:63E0 / 69:7AD0, 1F:6896) has x 42-47, rows 40-43
  open, and x 43-58, rows 43-48 all `$00`. Only `7F` copies move overlay cells into the live map, and 186's
  only `7F` is `$50`'s 59-61,31.
- Conclusion: no 186 script opens that wall. If 187 is reached from 186 at all, it has to be through cell
  behaviour, not script writes. The candidates are the `$02` layer walk (CountCellRun run of 3+ with `$C9A6 >= 5`,
  which switches the record to the `$02` layer heads and is **not modelled** in `World.hop`) or a push block.
  187 also has a second entry, 29:4DF3 (a lookup-entered script in bank $29; caller not resolved statically).
- `$10` is stored at 1F:7B0B. It's reached from 187 triggers `$C7`/`$C8` (1F:694F / 1F:6958, kind 2 down,
  through 189's entry 1F:79E5) and from 188 `$C2` (1F:74F5). So `$0F -> $10` happens past 187, not in 186.

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
