# Field Start menu

Pressing Start in the field is `HandleStartPress` (bank 6). The loop is
`AfterStartLoop` at 06:673B: each frame blinks the cursor (`QueueBlinkSprite`)
and dispatches one just-pressed button (`DispatchMaskedAction`). This module
is that screen. Nothing in `Overworld` calls it yet.

## Open

`StartMenu.canOpen(vm)` is the four gates at the top of `HandleStartPress`:

- `$C6EE` is 0. It is 1 while a text box owns the window.
- Bit 1 of `$FFAB` is set. `FinishFrame` copies `$FFAA` into `$FFAB`.
  `default_state` sets both to 3, so the bit starts set.
- `$C716` is 0. That byte is the high half of the script pointer at `$C714`.
- `$CCA6` is 0. It is a countdown.

## What the screen does

`StartMenu.new(ctx)` builds the menu. The cursor record (column, row, and the
four neighbours) and the A/B command pair are read from bank 3 at runtime.
There is no key repeat. Start, or B on the first row, closes the menu and
restores the field sound bytes (`$C92C` = `$0F`, `$C92A` = 4).

Opening also fills `$CC4D` with ones, then clears or replaces a few of those
bytes from SRAM. The cursor will not land on a row whose byte is zero:
spell (`$CC4E`, the `$A5A6` span), rings (`$CC4F`, `$A118` plus one), items
(`$CC50`, the `$A3A8` span), glyph (`$CC51`, `$A3A4`), list (`$CC52`, the
`$A4A6` span), and save (`$CC71`, `$CCA5`). An empty field SRAM leaves the
first row and Rings.

A on the spell row or the item row opens that list as a child screen. The
child reads five nonzero SRAM bytes (`$A5A5` for spells, `$A3A7` for items),
draws each count, and takes the 13-byte name from the matching bank-7 record.
B once moves onto the row's label; B again returns to the top menu. Scrolling
follows the same pointer walks as `FillGroupPointers`.

A on Glyph opens the map (`DrawIndex9Map`). `$A3A4` chooses which stamp
cells are added to the index-9 tilemap. The cursor record for that mode
sits past the window, and every direction stays on it. B returns to the
Glyph row. A on Rings and List does nothing. Those modes are still to do.
Save is the slot to the right of the first row. A latches the cursor; A
again plants the five-byte script record at `$C714` (`$CCA5` chooses which
record) and writes the save file the way opcode `$92` does when its copy
operand is zero: player cell, stamp, mirror, `mn_save/slot1.sav`.

Harness names: `StartMenu`, `start.Items`, `start.Spell`, `start.Glyph`,
`start.Save`.
Do not run `start.Save` against the real save directory.

## Wiring

`Overworld:update` never reads Start. After the overlay, battle, thread,
encounter, and camera work, it returns early for `$9C` choices only by
handling them, then for `vm.wait`, an open text box, a step in progress,
a slot-0 cutscene, and a live talk thread. The A poll is the next block.

Call `StartMenu.canOpen(ow.vm)` there, and on success
`overlay(StartMenu.new(ctx), cb)` with the same context the other screens
use: `rom`, `vm`, `ow`, `input`, `log`. Text, waits, movement, slot 0, and
talk then block Start the way those returns already block A.

The field port does not latch `$FFAB` today. `canOpen` stays false until
that bit is set the way `default_state` and `FinishFrame` set it.

## Left for later

Rings (`DrawIndexedEntry`), the list mode
(`IndexedSetup` index `$0B`), mode 6, Select on slots `$1C` and `$1D`
(`RetargetSramSlotCount`), the party pictures (`CopyIndex5VRAMTiles`), and
one icon on the spell row. A latched A on any slot other than Save does not
plant a script yet (`SetupCommand4D`).
