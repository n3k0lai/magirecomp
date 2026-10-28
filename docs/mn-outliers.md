# Open questions for Nicholai (static audit, static-story branch)

1. **`$02` layer walk.** `World.hop` only models runs of 1 and 2. CountCellRun with 3+ and `$C9A6 >= 5`
   switches the record to the `$02` layer heads (`$C12A`/`$C12C` swap). 186's overlay (69:7AD0) has the open
   corridors the base map lacks. Should the port model the layer walk? It's a design call: it touches the
   planner, the step and the camera. What sets `$C9A6 >= 5` is not traced yet.
2. **`$4C` QueueRepeatedSpriteList / `$4D` StepScriptSpritePointerTable** run in map scripts (24, 35, 44-48,
   52, 53, 63, 72, 73, 75, 82, 113, 124, 135, 136, 189, 222, 224, 257, 341, 345, 346 / 40, 44, 47, 52, 53, 189,
   222, 257, 270). ScriptVM logs them as unimplemented and skips them. If the asm waits on the sprite list,
   skipping changes script timing (cutscene sync with `$C6F8`-`$C6FD`). Confirm against the bank-1 handlers
   before implementing.
3. **187 entry 29:4DF2/4DF3** is only reached from the bank-`$29` stub chain (29:431C, a `45` at 29:433F).
   Every stub chains to the next map, which looks like a demo/recap tour. Is that right, or is the chain
   used in play (for example as a warp preview)?
4. **Harness hacks to re-check per leg:** god mode and auto-battle skip battle-gated scripts (`$2B`/battle
   ops); MN_NOENC hides step encounters; snapshot rebuilds re-run map init, not the original transition.
   A route step that only worked because of one of these should be re-run with no MN_* vars. Not done in
   this pass. The static tool gives each leg's flag writers to compare against.
5. **Unfound story stores** ($02, $05, $0C-$0E, $11, $12, $15-$18): see docs/mn-story-graph.md. Are they
   written by asm (for example battle wins) rather than `A9`?
6. **186 -> 187 needs `$C9A6 >= 5`.** The only static path into 187's `$C1` corridor walks a 3-wide `$02`
   band (from the `$44` rect at x 39-43, rows 52-63). That needs `$A3A3 = 5`, but the `$0F` warp
   (2A:5118) stores 3. Is the intended order to get the `$A3A3 = 5` upgrade (19:63C3, map 290 / 2A:50CE)
   before entering 186? And should the port implement the layer walk (item 1) to make it possible?
7. **186 `$C3`-`$C6`** (1F:62A1-62BC) exist in the trigger list, but no base or overlay cell carries those
   values. Are they dead data, or written by asm we haven't traced?
