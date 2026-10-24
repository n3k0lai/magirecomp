# Route 12 (headless)

`scripts/mn-route12.sh` walks a new game toward control after the Korg duel
(map 8, beat 12). Each leg is one `mn-headless` run. Later legs resume with
`MN_LOAD` from the previous leg's door snapshot under `/tmp/mn-route12/`.

## Legs

| Leg | Frames | From | Route | Snapshot |
|-----|--------|------|-------|----------|
| into222 | 8000 | new game, map 216 | `219:far,220:12.0,221:36.0` | door into map 222 (`into222.lua`) |
| river | 12000 | that door | `222:28.4r`, then the default planner | map 40 west exit into map 0 (`after40.lua`) |

Beat lines the script prints:

1. `script 2A:6CB5` on the new-game door.
2. `talk=1F:5D95` when map 222's entry spawns the crystal.
3. `enter map 40` after `1F:5EAE` plays the cave-in and the fall.
4. `door crossed -> map 0`: the river scene is over and Tony leaves map 40.
5. `enter map 2` (the stairs below Vash Naroom).
6. `enter map 43` (Vash Naroom).

The gorge scene on map 219 is still running at frame 3000 (player hidden at
6,14), so leg 1 cannot be split on a door and stays 8000 frames.

## Beat 4 (fixed 2026-10-23)

The river scene (`2A:4837` .. `2A:4C51`, `src/evscripts/bank2A/4715.asm`) has
no door inside it, so the river leg runs 12000 frames instead of 3000 and
checkpoints on the next door: map 40's west exit into map 0.

That door could not be a snapshot target before. `Overworld:snapshot`, the
door planner and the step trigger's direction gate read the importer's cached
trigger list (the first `$64` `findEntries` saw: `21:4238` for map 40), while
the entry that actually ran installed `21:4228` / `21:4231`. They now read the
live list (`self.triggerPtr`) and resolve its script's `$65` with
`MnRom:resolveWarp` (`Overworld:triggerTo`, `World.gate`;
`tests/engine/mn_trigger_live_test.lua`).

## OPEN QUESTIONS

- Legs after `after40.lua`: Vash Naroom (beats 6-9) onward to the Korg duel.
  Beat 8's inn has a `$9C` Yes/No save; mn-headless now gives each run a
  private save folder, so a route that answers Yes does not touch the real
  slot.
