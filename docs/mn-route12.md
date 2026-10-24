# Route 12 (headless)

`scripts/mn-route12.sh` walks a new game toward control after the Korg duel
(map 8, beat 12). Each leg is one `mn-headless` run. Later legs resume with
`MN_LOAD` from the previous leg's door snapshot under `/tmp/mn-route12/`.

## Legs

| Leg | Frames | From | Route | Snapshot |
|-----|--------|------|-------|----------|
| into222 | 8000 | new game, map 216 | `219:far,220:12.0,221:36.0` | door into map 222 (`into222.lua`) |
| river | 12000 | that door | `222:28.4r`, then the default planner | map 40 west exit into map 0 (`after40.lua`) |
| town | 8000 | `after40.lua` | default planner to Vash Naroom, then `@43#2,43:9.0` | town north exit into map 44 (`into44.lua`) |
| orwin | 6000 | `into44.lua` | `44:13.0,51:29.2`, then the default planner (53, 54) | 54 door into Orwin's house 63 (`into63.lua`) |
| ring | 11000 | `into63.lua` | `63:14.9d,54:3.9d,53:0.27l,51:13.23d,44:23.5r,48:12.2u,59:10.10u>8.13d` | ringsmith counter (14:700F), then 59's exit back into 48 (`48:2`, `after59.lua`) |
| inn | 7000 | `after59.lua` | `48:0.6l,44:0.5l,47:8.4u,55:7.14u>14.17d` | Poad's rest (28:5918, control at 16,5), then 55's exit into 47 (`47:2`, `after55.lua`) |
| evu | 10000 | `after55.lua` | `47:19.7r\|8.4u\|19.7r,44:13.0u\|0.5l\|13.0u,51:0.12l\|13.23d\|0.12l,52:4.1u\|17.5r\|4.1u,60:14.5r>6.9d\|14.5r>6.9d,55:7.14u>14.17d` (MN_PICK=2B:43F0) | Evu, the other inn scene, Evu again; spell 3:1; exit into 52 (`52:4`, `after60.lua`) |
| train | 7000 | `after60.lua` | `52:17.5r,51:13.23d,44:12.16d,43:far,61:0.9` | Eidon training in 61 (Awl 0:45, control 10,9), the quake on 0,9 (13:5D5F), door into 2 (`after61.lua`) |
| glade | 6000 | `after61.lua` | `2:6.15d,277:37.13,3:far,4:far,5:21.0u` | quake scene in 2 (control 12,8), 277, the Glade 3, 4, 5; north door of 5 into 7 (`after5.lua`) |
| korg | 12000 | `after5.lua` | `7:far,277:37.8,8:far` | 277 step-on 37,8 (2F:4210), Shadow Geyser scene and Korg duel in 8 (control 8,8), then the second door into 277 (`277:2`, `beat12.snap`) |

`MN_FROM=town bash scripts/mn-route12.sh` reuses the earlier legs' snapshots
and logs in `/tmp/mn-route12/` and runs from that leg on.

Beat lines the script prints:

1. `script 2A:6CB5` on the new-game door.
2. `talk=1F:5D95` when map 222's entry spawns the crystal.
3. `enter map 40` after `1F:5EAE` plays the cave-in and the fall.
4. `door crossed -> map 0`: the river scene is over and Tony leaves map 40.
5. `enter map 2` (the stairs below Vash Naroom).
6. `enter map 63` (Orwin's house, reached from Vash Naroom 43 through 44, 51, 53, 54).
7. `script 14:700F` (A on the ringsmith's counter cell in 59; ring and 50 Animite).
8. `script 28:5918` (Poad's rest in the inn, 55). Before the Korg duel this talk only offers the rest; it gives no item. The fireplace Remedy Drink in 62 is not on the route yet.
9. `got 3:1 x1` (Evu gives the spell after the jellybean trade in 60).
10. `got 0:45 x1` (Eidon hands over the Awl at the training grounds, 61).
11. `door crossed -> map 5 at` (the third Glade map, after the quake scene in 2 and the walk through 277, 3 and 4).
12. `player control at 8,8` (after the Korg duel and its win tail in the Shadow Geyser, 8).

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

## Town leg (2026-10-23)

Map 43 is entered twice: Eidon's scene from the stairs (talk `14:4D01`), then
a second entry at 2,46. `@43#2,...` in `MN_ROUTE` holds the route back until
that second entry (entries are the `door crossed` count). The live list
`16:4271` has the step trigger `16:4026` at 6,38/6,39 (on the way up) and
the north exit `16:401D` at 9,0/10,0 into map 44.

Engine fix: once `StartMenu.canOpen` is true in town, the route input gave a
direction for the `start` poll and opened the start menu every frame. Route
input now answers only `a` and `dir`.

The planner after the 44 door went 44 -> 47 -> 55 (the inn, talk `28:5918`)
inside the same run, so the inn (beat 8) may come before the ringsmith
(beat 7) on this route.

## OPEN QUESTIONS

- Legs after `into44.lua`: Vash Naroom (beats 6-9) onward to the Korg duel.
  Beat 8's inn has a `$9C` Yes/No save; mn-headless now gives each run a
  private save folder, so a route that answers Yes does not touch the real
  slot.

## Historian leg notes (2026-10-23)

- Evu's record 2B:479E switches on the story word ($A123). At 2 it switches
  again on $A224, a per-chapter phase byte that the VM clears on each new story
  word: 0 -> 2B:4538, 1 -> 2B:41CB (sets 2), 2 -> 2B:42FA, 3 -> 2B:4353 (the
  jellybean question; choice 2B:4396 / 2B:43F0, and 43F0 sets 4).
- The ringsmith (14:7399) leaves $A224 at 1. With $A224 = 2, 55's init
  28:5BDF loads a second scene (slot 2 at 7,13, record 28:5C27, which sets 3).
- The autopilot takes the first choice option (2B:4396, no trade), so the leg
  sets MN_PICK=2B:43F0. MN_WATCH=A224 logs each phase write.
- No engine change was needed; every flag on this chain is already modeled.
- 62's alternate scene (init 23:529D, the $A126/$A127 jellybean scripts) is
  chosen only at story word $19, much later than this beat. The fireplace
  Remedy Drink (62, cell $41, 23:4F86) is still off the route.
- A snapshot taken on 60's exit door places Tony on the exit cell, so loading
  it walks straight back into 52.

## Bracelet legs (2026-10-24): into15 to the bracelet scene
Working notes for the headless route toward the bracelet. Script addresses
refer to the decomp's bank $1A event scripts. Floor-puzzle state lives in
the story bits at $A125.

### Puzzle bits ($A125)

| bit | set by | effect on map init |
|-----|--------|--------------------|
| 0 | lever in map 20 (1A:62AB) | map 20 init (1A:6324 -> 6377) opens its south gate |
| 1 | second lever in map 20 (1A:6304) | map 16 init (612D -> 6136) opens the 0,9 exit to 17 |
| 2 | lever in map 19 (1A:6234) | map 23 init (654B -> 6594) joins 23's south door room to its middle room |
| 3 | lever in map 23 at 6,13 (1A:6533) | map 20 init (6324 -> 63B9) opens column 14 and the north block, joining 20's north and west halves |

Map 23's middle room (rows 14-16) is a dead end even with bit 2: rows 9-13
stay solid, so the 23 corridor (rows 5-8, exits to 22 and 24) is reached from
the other side, not from 18. The bit 3 lever only shakes the camera in map 23;
its real effect shows on the next load of map 20.

### Legs

1. Done: 15 -> 16 -> 19 -> 20, lever (bit 0); back to 15.
2. Done: 15 north door -> 20, second lever (bit 1); back to 15.
3. Done: 15 -> 16 -> 17 -> 18 -> 19, lever (bit 2) -> 18 -> 23 south room.
   Needed the A-list fix (commit b75c74b3): map 19's init sets its A-list
   before its map load, and the load used to drop it.
4. Done (green, 9000 frames from the 23 door snapshot): route
   `23:6.14u>11.21,18:16.19,17:23.13,16:23.10,15:10.0,20:0.5` pulls the 23
   lever ($A125 = $0F), walks 18 -> 17 -> 16 -> 15 and snapshots 15's north
   door (1A:5BD2) into 20. The west half of 19 (entered from 18 at 0,4) does
   not reach 19's east exit, so 18 -> 19 -> 20 is not a path.
4b. Open: entering 20 from 15's north door lands in the south pocket (16,22)
   and runs init 1A:6462, which tests no puzzle bits; only init 1A:6324
   (entered through 1A:6448) applies the bit 3 copies. Next: find which
   door table entry runs 6448 (likely 19's east exit into 20 at 0,16 or the
   21/22 side) and route through it to 20's west exit, then 21 -> 22 -> 23
   corridor -> 24.
5. Todo: map 25 init (1A:66B7) places the object whose talk script (672C)
   moves the story word to 6.
6. Todo: village chain sets $A225 = 2 (1D:5888 / 7720 / 7766), then the map
   223 NPC (1D:44EF -> 465D) sets the bracelet flag ($A3A3 = 2).
7. Todo: first kick on a $0B cell.

### Harness notes

- A `x.yD>next` goal with a lever (no text box) advances only after the
  repeat press shows the already-pulled message; give the next goal a cell
  that is reachable, or the planner idles silently.
- Snapshots stay in /tmp and out of git.
