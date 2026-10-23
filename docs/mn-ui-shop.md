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
bytes the same routines update. `$8F` stores the bought record
address at `$CD52`, the pass count 2 at `$CD50`, loads that record
through `$D110` with `$D389` = 1, writes the body back, and restores
`$C937`.

## Window

`$8C` copies the 18-by-20 map at `$4CB3`, `$8F` the map at `$4E1B`, and
`$90` the map at `$4B4B` (`PlaceWindowCopyMap`, `$76FA`). Attribute flips
come from `PaintMapAttrsSeedSlot` (`$7463`). `$8C` also paints the bottom
strips from `$5627`. Tiles `$86` onward are the indexes `CopyRepeatedTileIndex`
and `CopyIndexedBlocks` wrote; `$80`–`$85` are the frame in `Font`'s sheet.

The scroll pairs are `$9C29` (row 1, column 9) and `$9D89` (row 12, column 9).
`RefreshFrameMarkPair` (`$7751`) and `RefreshFrameMarkWindowPair` (`$7777`)
write `[$CCEB]` into a pair. `RefreshFrameBlankMarkPair` (`$779D`) and
`RefreshFrameWindowPair` (`$77C2`) write tile `$80`. `$CCEB` is `$0B` for
`$8C`, `$F3` for `$8F`, and `$04` for `$90`.

`$90` B follows `StepPrefixedBlockChoiceFE` (`$6CA8`). `$CCE3 == 0` calls
`ScanArmedSlotMarks` (`$76E0`): a copied mark stores 3 at `$CD81` and 1 at
`$CCE3`, and a miss only rearms. Any other flag except 3 forces the menu
and blanks the three cells at `$76B1`. Flag 3 stores `$FF` at `$CCFC` and
`$CCFD` and closes.

`$8F` calls `SpendNewEntryMeasures` (bank 2 `$5B35`) with `$CD50` = 2, so
one pass runs. The entry at `$CD52` is loaded to `$D110`, `$D389` is set
to 1, and the body is written back. Bit 0 leaves the measure word alone.
The pass uses the battle port of `SpendMeasureHundred`; the real divider
is not sampled.

## Still open

`ClampGroupSRAMByte` still does not stage the 13-byte tail at `$C949`.
`$8F` does not draw the tier message. The measure pass does not read
`rDIV`, so the stat rolls are a seeded stand-in.

## Harness

`ListChoice.demo` fills a synthetic list when `$CCA7` is not already `$FF`.
`--mn-ui ListChoice` uses that. `MN_UI_MODE=8c|8f|90` selects the window
(default `$8C`).

Wiring is the `openList` call at the end of the `$8C`, `$8F` and `$90`
handlers: `ListChoice.new(vm.host.uiContext(), mode)` inside `runOverlay`.
