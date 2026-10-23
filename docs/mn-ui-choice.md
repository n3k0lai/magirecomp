# Choice windows

Opcodes `$8B` and `$8D` stage an armed slot and then wait until the player
picks a row. `src/mn/ui/ChoiceWindow.lua` is that wait. The handlers in
`src/mn/ops/Travel.lua` keep their staging writes, and when a script is
running they open the screen with `vm.host.runOverlay`. Map setup
(`vm.init`) and a host with no `runOverlay` still return the next opcode
without waiting.

## Which window

`$CCB4` selects the slot list in bank 3 at `$4524` (`LoadArmedSlotRecord`).

- `8` is `$8B` (`StageTilesArmSlot` / `DispatchArmedChoice`). The picture is
  the 18-by-20 map at bank 3 `$4CB3`. Sixteen glyph indexes at `$CC43` are
  the tiles that start at `$CC45`.
- `7` is `$8D` (`StageWindowTilesArmSlot` / `ServiceWindowChoice`). With no
  slot staged, `ChoiceWindow.demo` writes the `$8D` bytes so the harness
  can open the screen on its own. The page of pairs comes from SRAM the way
  `LoadPagedSRAMChoicePairs` reads it.

## Input and the bytes a script reads

New presses follow `ReadJoypadSample`: low nibble A, B; high nibble Right,
Left, Up, Down. `$CCA9` is `$F3`, so A, B, and the directions pass.
`DispatchMaskedAction` tries A, then B, then one direction. A stores `$CD81`
in `$CCA7`. B stores `$FE`. A direction copies the candidate in the active
8-byte record. A zero byte at `[$CCB6] + index` does not move the cursor
(`SelectSlotFromHighNibble` would repeat that candidate and not return).

The blink is `QueueBlinkSprite`. `$CCB9` of 0 holds tile `$82` on the cell.
Otherwise tile `$81` is hidden while `$CD7F` is below `$0F`, and the count
wraps at `$1F`. The cell is `($CD82, $CD83)` in tiles.

`$8B` then follows `DispatchArmedChoice`:

- Slots 0, 1, and 2 write `$CCFD` as 0, 3, and 2, plus the pointer bytes
  `PrepareChoice012` stores, and the screen closes. The item list that
  routine opens afterwards is not run.
- B, while `$CCE3` is 3, writes `$FF` at `$CCFC` and `$CCFD`.
- Slot `$0D` does the same blank pair (`CopyOtherChoiceByte`).
- Any other slot copies `$CCCD[slot - 3]` into `$CCFC`.

The next opcode is unchanged. Scripts that follow `$8B` compare the byte at
`$CCFD` (`LookupIndex1` on `$CCFD`). 0, 2, and 3 are the three picks. `$FF`
matches none of them.

`$8D` saves the choice at `$CD74`. `$FE` closes as a cancel. 0 and 8 turn
the page and leave the window open, with `$CD81` back at 1. Any other slot
closes with that pick. The confirm that `ResolveArmedListChoice` would open
is not run. Scripts after `$8D` in the disassembly do not branch on this
byte; they enter a fixed script.

`scr:update` returns `{ pick = slot, cancelled = bool }`. `pick` is the
`$CCA7` value. `cancelled` is true for B and for the armed blank pair.
