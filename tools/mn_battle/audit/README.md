# Battle port audit tools

Checks the Lua battle engine (src/mn/battle/Engine.lua) against the matching
decomp source. Point them at a checkout of the decomp (the scaffold reads
`src/*.asm` and the section addresses in it). Nothing here reads or writes ROM bytes.

- `srclib.py`: loads the scaffold, finds the routine at a bank:address, lists labels.
- `handlers.py`: translates every bank-2 move handler ($47D0-$5040) into the
  engine's chain DSL; diff its JSON against `dump_handlers.lua` output.
- `relics.py`: translates the bank-7 relic routines ($6BD5-$6FCE) into the
  `RELIC_OPS` table in Engine.lua. Every instruction must match a pattern.
- `setupcmp.lua`: builds a battle with Engine.new from recorded draws and diffs it
  against the real WRAM of a PyBoy state at the first menu.
- `replay_all.sh`: replays every oracle trace (ROM=..., TRACES=...).
