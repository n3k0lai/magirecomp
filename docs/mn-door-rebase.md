# Door rebase and the slot-0 template

`opcode_02.asm` computes the player's new cell from the cell they left:
`new = old - lo + hi` per axis. `$00` (`opcode_00_bank1.asm`) later copies
that pair into the player cell. A slot-0 `$05` record (FillScriptRecord0808)
also carries a cell, which the port used whenever the pending pair was a wall.

That wall test must run against the destination map. Door 1A:6802 (map 26 to
15, pair `07 08 00 1B`) fills slot 0 at 5,5 while map 26 is still loaded, so
the old check rejected the rebased cell and placed Tony inside the walls of
map 15. The VM now marks the pair as pending until `$65` loads the new map,
and only then lets the template override a pair that lands on a wall (the
ringsmith case, map 59).

Checks: `tests/engine/mn_door_rebase_test.lua`; headless runs from the
26-to-15 door land at 10,27 when leaving from 9,0 (9,27 from 8,0) and walk
on to map 16; the 223-to-225 door still lands at 7,11.
