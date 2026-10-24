# Route 12 (headless)

`scripts/mn-route12.sh` walks a new game toward control after the Korg duel
(map 8, beat 12). Each leg is one `mn-headless` run. Later legs resume with
`MN_LOAD` from the previous leg's door snapshot under `/tmp/mn-route12/`.

## Legs

| Leg | Frames | From | Route | Snapshot |
|-----|--------|------|-------|----------|
| into222 | 8000 | new game, map 216 | `219:far,220:12.0,221:36.0` | door into map 222 (`into222.lua`) |
| crystal | 3000 | that door | `222:28.4r` (face the object at 29,4) | none |

Beat lines the script prints:

1. `script 2A:6CB5` on the new-game door.
2. `talk=1F:5D95` when map 222's entry spawns the crystal.
3. `enter map 40` after `1F:5EAE` plays the cave-in and the fall.

The gorge scene on map 219 is still running at frame 3000 (player hidden at
6,14), so leg 1 cannot be split on a door and stays 8000 frames.

## Blocker before beat 4

`bash scripts/mn-route12.sh` (2026-10-23) prints beats 1-3, then exits 1.
Leg 1 (8000 frames, the default planner on map 222) and leg 2 (3000 frames,
`222:28.4r`) both stop in the same place:

A 3000-frame crystal leg ends here:

- Map 40, player cell 9,28, `hide=true` (slot 0 still owns Tony).
- Frame 3000. Thread trace: slot 0 at `2A:4882`, waiting on the schedule in
  `2A:4837`.
- Last `[mn-test]` lines: `enter map 40`, `place player 9,28`, npc slot 0
  `anim=2A:4837`, `music $1E`. No `[vm]` error.

`src/evscripts/bank2A/4715.asm` is the river scene (`2A:4774` loads map 40,
slot 0 runs `2A:4837`). Control comes back only when `2A:4C51` does opcode
`$09` of slot 0 onto a sprite-bank anim (`20:50AB`); `Overworld` treats that
as `release`. That script is still well ahead of `2A:4882` at frame 3000
(dialogue and `$15` schedules for the Furoks, then Korg, Zet and Eidon).

`Overworld:snapshot` writes a file only when the player walks onto a step
trigger whose cached `to` matches `MN_SNAP_TO`. Nothing in this stretch is
a step trigger: the cave-in and the fall are opcode `$65` loads. The next
door is map 40's west exit (live list `21:4228` or `21:4231`, index 0, kind
4, script `2A:4000`, into map 0). The cache's trigger list for map 40 is the
first `$64` `findEntries` saw, on entry `21:7954` (list `21:4238`). Index 0
of that list does not resolve to map 0, so `MN_SNAP_TO=0` would not write
even after Tony walks out.

Suspected gap: checkpointing, not the scene VM. Threads advance every sample
(`2A:4853` at tick 2600, `2A:4882` at tick 3000) and text boxes close. A
later leg cannot start mid-scene, and one 3000-frame leg cannot both cross
the cave and finish `2A:4C51`.

## OPEN QUESTIONS

- Ene: a mid-cutscene checkpoint (write `MN_SNAP_FILE` from a script load, or
  when slot 0 is released) is what would let beat 4 continue in 3000-frame
  legs. Wiring is `Overworld:snapshot` / `Overworld.load`.
- Map 40's cached `triggers[].to` should follow the list the entry actually
  runs (`21:4228` / `21:4231`), not `21:4238`. Until then the west exit cannot
  be a snap target.
