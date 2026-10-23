# Shop and list windows

`src/mn/ui/ListChoice.lua` is the choice window for three bank-3 opcodes.
The handlers in `src/mn/ops/Travel.lua` still stage the block. When the
script is running (not `vm.init`) and the host has `runOverlay`, they then
wait on this screen. Cancelling or finishing returns into the same script.

| Opcode | Routine | What the window is |
| --- | --- | --- |
| `$8C` | `StageCopiedBlockArmSlot` / `DispatchCopiedBlockChoice` | A copied list of an id plus 13 glyphs. A pick stores that id at `$CCFC` and the window stays up. B closes. |
| `$8F` | `StageSramListArmSlot` / `SpendSramListChoice` | Records in SRAM. A pick spends the currency word and a stock byte, then stays up. B closes. |
| `$90` | `SetupPrefixedBlockChoice` / `DispatchPrefixedBlockChoice` | Bottom menu, then a buy list from the copied block or a sell list of owned counts. |

The cursor is slot list 8 (`$8C`, `$8F`) or slot list 6 (`$90`). Eight rows
are on screen. Past that, the up and down slots scroll by a page. A zero
mark is skipped in that same direction. The hand blinks: hidden for the
first half of the `$20` count.

`$90` buy compares the record's cost with `$A3A5`, then adds one to the
count at `$A3A7` up to the cap in that item's ROM record. Sell adds that
record's word to `$A3A5` (capped at 999) and decrements the count. `$8F`
compares the same currency word, then subtracts the quantity from `$A4A6`.
A short cost, a short stock, a full stack, or a zero sell word stores 2 at
`$C921` and leaves the list up. No message is drawn for that.

The ring-forge questions (make, restore, replace, too few, deequip) are the
bank-4 window `CopiedBlockWindowChoice`, reached from the other choice
opcode. They are not this screen.

## Bytes

Read: the staged block at bank-6 `$D000`, choice bytes `$CCCD`, page
`$CCD5` / `$CCC8` / `$CCCC`, mode `$CCCB`, flag `$CCE3`, marks `$CCD6`,
currency `$A3A5`, counts `$A3A7`, stock `$A4A6`, SRAM records `$A025` and
the length at `$A122`, the mark list `$A118`. Prices and names come from
the ROM at draw time.

Write: `$CCFC` (`$8C`), currency, counts, stock, the sound bytes `$C91E`
`$C91F` `$C920` `$C921` `$C92A` `$C92C`, and the page / mark / cursor
bytes the same routines update. `$8F` also stores the bought record
address at `$CD52` and a pass count at `$CD50`.

## Still open

`SpendNewEntryMeasures` (bank 2) is not called; `$CD50` is set to 2 so a
later port can. Scroll-arrow tiles (`$7751` / `$7777` / `$779D`) and the
`$CCE3 == 0` step (`$76E0`) are not ported. The window frame is drawn as
bars; the tilemap pictures at `$4B4B` and `$4E1B` are not.

## Harness

`ListChoice.demo` fills a synthetic list when `$CCA7` is not already `$FF`.
`--mn-ui ListChoice` uses that. `MN_UI_MODE=8c|8f|90` selects the window
(default `$8C`).

Wiring is the `openList` call at the end of the `$8C`, `$8F` and `$90`
handlers: `ListChoice.new(vm.host.uiContext(), mode)` inside `runOverlay`.
