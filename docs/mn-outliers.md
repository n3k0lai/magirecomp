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
3. **187 entry 29:4DF3** has no static caller. Is it the post-event re-entry, and does any route rely on it?
4. **Harness hacks to re-check per leg:** god mode and auto-battle skip battle-gated scripts (`$2B`/battle
   ops); MN_NOENC hides step encounters; snapshot rebuilds re-run map init, not the original transition.
   A route step that only worked because of one of these should be re-run with no MN_* vars. Not done in
   this pass. The static tool gives each leg's flag writers to compare against.
5. **Unfound story stores** ($02, $05, $0C-$0E, $11, $12, $15-$18): see docs/mn-story-graph.md. Are they
   written by asm (for example battle wins) rather than `A9`?
