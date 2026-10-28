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
4b. Done: the lever-aware init 1A:6324 runs from 19's upper east door
   (1A:6222) and 21's south door (1A:6448, entry 2 of map 21's step list
   21:413E: from 11,23 in 21 to 13,0 in 20). The walkable path is
   23 (lever at 6,13) -> 18 -> 19 at 0,4 -> 19's upper east door -> 20's west
   upper exit -> 20 north (column 14 opened by the bit 3 copies) -> 21 ->
   22 -> 23 corridor -> 24 (lands at 19,18). Script legs `levers` and
   `corridor` (`MN_LEGS=bracelet`).
4c. Done (leg `gate24`, from into24.lua): map 24's init (1A:65D7) keeps a
   wall at rows 13-15, cols 6-9 between the south area and the north exit
   (7,1 -> 25) unless $A125 bit 4 and $A126 bit 3 are both set. Talking to
   the NPC at 6,15 (stand at 6,16 facing up; 1A:6645 -> 1A:5C7D) sets
   $A126 bit 2. The map 22 lever (1A:64AF at 13,2) then sets $A125 bit 4 and
   $A126 bit 3; without bit 2 it shows a hint and clears bit 4 again
   (1A:64D4). Back in 24 the wall is open and 24's north door (1A:65CE)
   leads into 25. No engine change needed.
5. Story 6 (leg `scene25`, from into25.lua): 25's init (1A:66B7) places
   slot 2 at 5,5; talking to it (stand at 5,6 facing up) runs 1A:672C, which
   sets the story word ($A123) to 6. With story 6, 25's exit (1A:668E)
   runs 1A:66A3, which hands slot 0 the guardian scene (1A:674C): four talk
   steps keyed on $C6FD, then 1A:5F88 sets up the duel (battle script
   4C:4023). Engine fix: the pad is ignored while a script runs in slot 0;
   before it, the route stepped back onto the exit during the scene's pause
   and restarted the scene. Open: the duel never starts. Slot 0 loops in
   1A:603B (C70D record 1A:6045 picks an animation, then waits for $D3C2)
   and $D3C2 never clears.
5a. Done (leg `duel25`, from into25.lua): the guardian duel is a scripted "director" duel.
   In the ROM, Opcode25 plants the $2B-style handler and jumps straight into
   the battle engine (bank 4 $6416); it does not wait for Opcode27.
   Opcode2B clears $D3C2 and sets hScriptHandler to the $0F66 stub, which
   only steps the script while $D3C2 is nonzero. So the rest of the stream
   (combatant adds via $2E, text, the 1A:603B loop) runs inside the battle,
   one chunk each time the battle engine raises $D3C2. The port only starts
   battles on Opcode27 and treats $2B as a one-frame yield, so the stream
   spins. The same $25 -> $2B pattern starts 17 scripted duels (banks 12,
   13, 14, 15, 16, 18, 1A, 1F, 22, 23 and 26), so the fix is general: start
   the battle on $25 when $2B follows, and let Battle raise $D3C2 at its
   turn points to resume the director stream. $A3A3 = 2 (item 6) comes after
   this duel.
   Port (src/mn/ScriptVM.lua op $2B, src/mn/Battle.lua startDirector/pass): the
   port still collects a battle script's ops, but when the stream loops back to
   a $2B it already passed since the $25 (1A:603B), the battle starts there.
   Each engine round raises $D3C2 between the ranking and the slot walk (bank 2
   $5E5E, WaitUntilD3C2Clears) and waits until the stream's next $2B clears it;
   summons the stream ran in that pass reach the engine then. When the battle
   ends, the $31 win or loss script runs as the main script (ContinueStartup),
   which ends the slot 0 director. $27 duels (Korg) are unchanged. Tests:
   tests/engine/mn_battle_director_test.lua. The guardian is won in about 24
   passes with MN_GOD; its win script 1A:67C7 walks through 9 into the small
   room 10 (bank 1D village, south door to the world map).
   Room 10 fix: its entry (1A:6841) fills slot 0 with the $5D81 pad handler and a
   sprite anim, which is the player record itself. The duel scene left hidePlayer
   set, so the port made it a cutscene stand-in that kept the pad locked. Overworld
   spawn now drops that stand-in, and the leg holds down to the south door. Run
   duel25d writes out10.lua (door 1D:4000 into 277), which is the start for the
   bracelet legs.
6. Todo: village chain sets $A225 = 2 (1D:5888 / 7720 / 7766), then the map
   223 NPC (1D:44EF -> 465D) sets the bracelet flag ($A3A3 = 2).
   Who's who (from the decomp and earlier b13 harness logs): map 225 slot 2 at 8,4
   (behaviour 1D:76DC, talk 1D:76E4) selects on story word $04. At story 6 it
   goes to 1D:7724, which selects on $A225: 0 gives a text only, 1 gives 1D:776A
   (sets $A225 = 2), 2 falls through to 1D:7931. 1D:7720 and 1D:7766 are
   alternative entries into the same code, and 1D:5888 is another $A225 = 2 setter
   that has no known caller yet. Map 223 slot 2 at 22,22 (behaviour 1D:44EF ->
   1D:4558, talk 1D:44F7) selects on $A225: 0 or 1 goes to 1D:456C, and 2 goes to
   1D:465D (the bracelet). $A225 = 1 comes from 13:7372: map 229 (north door
   of room 10, 5,4) lists it on its $40 cell at 50,8, a $A2 record on $A334 bit 2.
   Pressing A from 50,9 facing up sets $A334 bit 2, clears the cell and stores
   $A225 = 1 (leg a229/a225 below). Map setup must not continue past the $44 in
   that record ($44 follows its word while the LCD is off), or every re-entry
   would store $A225 = 1 again. Done (legs to225/bracelet): 225's 8,4 NPC from
   9,4 facing left stores $A225 = 2, then 223's 22,22 NPC from 22,23 facing up
   runs 1D:465D (story word 7, $A3A3 = 2).
7. Done (legs to229/kick): first bracelet kick. Map 229 has a two-cell-wide
   wall of $0B cells at 39-40,12-15 between the 44,24 arrival side and the west
   half. With $A3A3 = 2, A from 41,13 facing left kicks 40,13, A from 40,13 kicks
   39,13, and the player walks through to 38,13. A kick ends a `>` goal like a talk.
   Route from out225.lua: 223 -> 277 -> 3 -> 4 -> 5 -> 7 -> the 277 enclosure,
   over 37,8 to room 10's door (37,7), then 10's north door into 229.
   Engine fix: 277's init (2F:4165) fills slot 2 at 37,8 as the Shadow Geyser
   step-on ($65A4, tail 2F:4210 into 8), but 2F:41F4 only takes the slot
   (Opcode0B) while the story word is 3..5. The port fired the step-on for the
   untaken (dormant) record too, so at story 6 and 7 every crossing of 37,8 fell
   into 8. Dormant $65A4 records no longer fire (Overworld) and the route
   planner no longer avoids them (Boot). The a225 leg drops its 8 detour.
   Checked: korg leg still wins at story 5; a225 and to229 cross 37,8 into
   room 10 with no Geyser. No 204 route is needed.
   out225.lua is snapshotted on the door into 223, before the 22,22 bracelet
   talk, so it still has $A3A3 = 1 (enough for $09 cells, not $0B). to229
   talks to that NPC first (story 7, $A3A3 = 2), then runs the route; the
   kick leg from to229in229.lua kicks 40,13 and 39,13 and ends at 38,13.

8. Todo: story 7 chain (read from the decomp; legs not yet run). The
   chapter phase byte $A224 is cleared when 1D:465D sets story 7, and the
   story-7 checks are `story == 7 AND $A224 ...` lookups (index 8 = AND,
   15 = equal, 19 = below):
   - $A224 = 0: map 113's entry selector (15:5CF9) picks 15:5D3D, which
     takes slot 2 at 11,10 (talk 15:5D7C). This is the first objective.
   - $A224 = 1: 113 picks 15:5D88.
   - $A224 = 2: map 74 (22:5F0F) picks 22:620C, which stores $A224 = 3.
   - $A224 = 3: 19:4B1D (maps 105-107).
   - $A224 = 4 and 5: 17:4181 and 17:43C9 (maps 210 and 211); 17:41EC
     stores 5.
   - $A224 = 6: 17:4849 (map 212/213) stores 6, then map 74 picks 22:6498,
     which stores story 8.
   Door graph past the kicked wall: 229's left door (9,10) -> 204 -> 205
   -> 200 -> 199 -> 198 -> 114 -> 113. 114 also links 113 twice, and 112
   links 113 and 279. Map 74 has no plain door into it (scripted entry).
   Correction (legs to113, to113b): the west room of 229 sits behind a
   second $0B wall (16-19,18-20; kick 18,18 / 17,18 / 16,18 from the east),
   and 204's pit (25:66AE) only drops to 205 once $A3A4 >= 3. $A3A4 is 2
   here; 13:6C68 (map 133, the story 0x0A scene) stores 3, so the 204 way
   is for a later chapter. At story 7 the way to 113 is overworld: 229 ->
   10 (5,11) -> 277 (31,38) -> 110 (5,29) -> 108 (17,39) -> 279 cell
   34,21, whose script 2F:44DE goes to 122 at story 8/9 and to 112
   otherwise -> 112 (12,9, moving up) -> 113. The importer read garbage
   trigger lists for maps 40, 73 and 198 (an entry-scan false positive
   pointing at graphics); it now skips implausible lists.
   Leg to113c: 10's 5,11 door lands on the 277 geyser island (37,8; only
   doors to 7 and 10), so the overworld goal 31,38 is unreachable from
   there. Way back to the mainland: island 38,10 -> 7 (5,19) -> 5 (12,29)
   -> 4 (0,21) -> 3 (0,20) -> 277; leg to113d tries that chain.
   to113d reached 279 (16,5) via 277 31,38 -> 110 -> 108, but 279's 34,21
   cell sits in a pocket that only 121 opens onto: 279 32,26 -> 115
   (19,29) -> 120 (26,0) -> 121 (5,0) -> back on 279 -> 34,21 -> 112.
   Leg to113e runs that.
   Next objective, summarized (read-only, from the decomp): after the 229
   kick, the next story step is map 113's slot-2 NPC at 11,10 (talk from
   11,11 facing up). Selector 15:5CF9 picks 15:5D3D at $A224 = 0, and the
   talk is 15:5D7C (it goes on into 15:5A8B / 0E:66B3). The story word
   only goes past 7 at 22:6498 in map 74, the one script that stores
   story 8. Map 74 picks it once $A224 = 6, after the 105-107 and 210-213
   phases above.
   279's two halves only meet through the town-74 icon at 19-20,22, a
   kind-0 door (2F:4496) that always enters 74, picking the arrival cell
   by entry direction. Real play walks through the town: 74's east edge
   (59,19-23, kind 3) returns to 279 at 21,22, its west edge to 18,22 and
   its north edge to 19,21. Route: `279:19.22|32.26|34.21,74:59.21`.

### Harness notes

- `MN_NOENC=1` (debug only, off by default) stops wandering monsters
  (object slots 31+) from starting battles so a route leg can be tested
  without random battles eating its frames. Story step-on records still
  fire. A real route must still pass with encounters on.
- Map 120 (entered from 115 at 4,0) splits at a block field, 11-14,7-11:
  $09 blocks and $81 floor. A on a $09 cell with $A3A3 >= 1 runs the
  bank-$20 push script (DispatchCell*OnButtonA tail: $5597 up, $55BD
  down, $554B left, $5571 right), and WalkTwoCells* moves the block one cell
  onto an $81 far cell (StampTwoStepCells). The port has only the $0B kick
  (Kick.lua), so the 120 leg stops at 10,9. A naive search under that
  push model finds no way from the west side to 15+, so the intended
  approach to 120's 26,0 exit is from the east: 115's top door (22-26,0)
  -> 116 -> 116's bottom-right door (40-43,39) -> 117 -> 117's west edge
  (0,35-38) -> 120's east side (59,8) -> 26,0 -> 121. Leg `underneath`
  takes that way. Porting the push (Crystal Gloves on $09) is still to do.
- The farm (113): slot 2 at 11,10 is Gruk's shop (15:5B10 opens the $90
  list). A route leaves a $90 shop list with B (Boot.lua), which lets the
  talk go on to the basement-noises lines (15:5B60), and 15:5C08 sets
  $A125 bit 2. The basement (114, stairs at 113's 14,6) has a step line at
  2-5,10 (15:5E97 -> 15:5F06): with that bit set it writes $A224 = 1 and
  runs the kidnap scene back in 113, whose init (15:5D88) writes
  $A224 = 2. Leg `farm`.

- A `x.yD>next` goal with a lever (no text box) advances only after the
  repeat press shows the already-pulled message; give the next goal a cell
  that is reachable, or the planner idles silently.
- Snapshots stay out of git: ~/.local/state/interns/snaps/magirecomp/ ($INTERNS_STATE_DIR overrides)
  (override with MN_SNAP_DIR).
- A map listed twice in a route overwrites its first goals; use `|` for
  per-visit goals, e.g. `23:6.14u>11.21|0.6`.

## Story 7 legs (Underneath, after the 229 kick)

Leg runner: `/tmp/mnp/leg.sh` style (MN_NEWGAME, MN_GOD, MN_BAUTO, headless,
muted). Snapshots stay outside git.

- Farm and kidnap: Gruk's Mushroom Farm (113) talk, then the scene
  ($A224 1 -> 2).
- Ransom: entering the Underneath town (74) runs its init 22:620C, which
  stores $A224 = 3. The long way in from the farm side: 112 -> 279 33,23 ->
  121 (5,19) -> 120 (59,8) -> 117 (12,0) -> 116 (4,39) -> 115 (0,16) -> 279
  31,26 -> the town icon 19,22. The town snapshot needs MN_SNAP_TO=75,
  because the harness resolves the town icon's warp with an empty state
  (it names map 75).
- North of town: 74's north edge (11-14,0) -> 279 north half. 3,9 is the
  cave 105 (a dead end for the story; see docs/mn-secrets.md for its hidden
  spot). The story goes 279 16,4 -> 108 -> 108's 29,0 -> 110.
- Rock trap: 110's step cell 5,17 runs 19:4E24, which (story 7 and
  $A224 = 3) enters 19:5208; 19:5211 stores $A224 = 4. Confirmed headless
  (leg trap1, from to110.lua; route `110:5.17`).
- Tower: 110's north edge (36,0) -> 277 -> 277's 32,36 -> abandoned tower
  210 (17:4181 at $A224 = 4), then 211 (17:43C9, stores 5). The ring side
  room 212 leads back into 211 (door 17:44B5, to211.lua).
- Gruk rescue: in 211, talking to the figure at the south door 10,16
  (17:43A7) and stepping on its trigger 17:438F moves the scene into 210.
  The scene there (kidnappers flee, Gogor breaks in, Gruk is freed and
  suggests going back to town) stores $A224 = 6 at 17:42C3. Confirmed
  headless with MN_TALK=1 (gruk6.lua, door 17:437F into 210).
- Back to town: 210 -> 277 (31,38) -> 110 (5,29) -> 108 (16,39) -> 279 ->
  town icon 19,22 (MN_SNAP_TO=75, to75s8.lua). On arrival the town scene
  stores story word 8 at 22:6498 (watched on $A123). Both legs are in
  scripts/mn-route12.sh behind MN_TO211.
- Arrival scene: not a port bug. The town scene (22:4205 -> talk thread
  22:44EB .. 22:4B0D, then 22:441A .. 22:44EA) is long: the brother thanks
  Tony, a quake hits, the townsfolk argue, the sister arrives hurt by a
  Shadow creature, Gogor leaves and the sister asks Tony to wait at Gogor's
  house. With the autopilot's text pacing it runs to about frame 7200 from
  to75s8.lua; the old 4000-frame run stopped mid-dialogue. Control comes
  back at 41,14 (hide off) by frame ~7300.
- Story 8 scripts (ROM scan for story-word compares): the town init switch
  22:5962 (case 8 -> 22:5EE9), house 79 (1C:6098, case 8 -> 1C:625B), house
  80's init 1C:6670 (story 8 -> 1C:667E) and a talk at 1C:644D, and the 279
  record that enters the farm side (2F:44E1: story 8 or 9 -> 15:4BB4, whose
  switch sends 8 to 15:4C10, which stores story 9 at 15:4CCB). House 80 is
  the town door at 33,33 (rebase 32,11 / 33,19; to80s8.lua): at story 8 its
  init only swaps two glyph sets (1C:667E), no scene. The town elder's talk
  (1C:644C) has a story-8 line (he expects Gogor back) and a story-9 one.
- Story 8 -> 9, confirmed up to the pocket. The record is the step script
  2F:44DE (list 21:5599, entry 5), not a separate header at 2F:44E1. Its
  first opcode names the arrival cell on the next map (column 5, row 24).
  The expression is "story word is 8 or 9": that branch is 15:4BB4, whose
  story-8 case is 15:4C10 (loads map 122, and 15:4CCB stores story 9). Any
  other story word falls through to 15:5971, which loads the farm map 112.
  The only cell on 279 that runs 2F:44DE is 34,21. It is not on the west
  half (18,22 has no path) and not on the east half's town side (21,22
  reaches 32,26 in 15 steps, and neither 34,21 nor the 121 door at 33,23).
  121's north door (15:47B3) is what opens the pocket: it lands on 279 at
  33,22, two steps from 34,21.
- Route from house 80 at story 8 (to80s8.lua), behind MN_TO80S8 in
  scripts/mn-route12.sh. Each leg is one headless run of at most 3000
  frames and reloads the previous leg's door snapshot:
  80 far -> town 74 east edge 59,21 (22:41B2, lands 279 at 21,22) ->
  279 32,26 (2F:44D0, lands 115 at 0,16) -> 115 top 22-26,0 (15:4010,
  lands 116 at 2,39) -> 116 40-43,39 (15:41B9, lands 117 at 12,0) ->
  117 west 0,35-38 (15:4258, lands 120 at 59,8) -> 120 25-28,0 (15:4739,
  lands 121 at 7,19) -> 121 4-7,0 (15:47B3, lands 279 at 33,22).
  Maps 115, 116, 117 and 120 keep wandering monsters in slots 31 and 32.
  On 116 the walk meets one; the battle alone runs about 2300 frames, so
  with the 85-step walk it does not finish inside 3000. Those four legs
  set MN_NOENC=1. Story step-ons still fire. $A123 stays 8 the whole way.
- 116's path also steps on 15:4240 (a slot-2 anim, no story-word write)
  just before the door into 117.

## OPEN QUESTIONS

Story 9 is stored (fixed 2026-10-25). The pocket leg ends with control at
map 279, cell 33,22 (MN_FRAMES=3000, MN_NOENC=1, load of the 117->120 door,
route `120:26.0,121:5.0,279:34.21`). 279's entry 2F:44F9 at story 8 or 9
branches to 2F:453E, which fills slot 2 on 34,21 (handler $4A6B, anim
11:7604, behaviour 22:4005) and runs opcode $0B on it. The s9door leg then
logs `route far -> 34,21 (2 steps)`, `script 2F:44DE (step trigger)`,
`A123 <- 09 at 15:4CCB` and `enter map 122`, and prints `story 9 reached`.

The block was the port's sprite rule. The old Overworld step and planner
treated any live (non-dormant) sprite as solid. The real step code never
looks at records: ProbeCellsUp and its siblings (StepClassProbeTable, bank
5 $651E) read only the WRAM-5 cell map. A record makes its own cell solid
through MarkZeroMapCell (bank 1 $4AD5), which writes $08 there only when the
cell byte is $00, and ClearRecordHeadBit5 ($4AB6) puts the $00 back. 34,21
is the $C5 step cell, so slot 2 never blocks it. `World.blocks` now applies
that rule for the player's step and the route planner
(`tests/engine/mn_sprite_cell_test.lua`). Only RunTwoScriptsThenTouchCell
($4A8F, and the $63ED / $6405 heads that call it) runs MarkZeroMapCell;
$4A6B records like this one never mark a cell at all. The port does not
track head-word changes yet, so it keeps treating every live sprite on a
$00 cell as solid.

## Story 9 to 10 (geyser dungeon)

The s9door leg snapshots the 122 door (to122.lua). The door replays the
mouth scene and control returns at 122 6,19; the s9mouth leg walks to the
6,13 up-trigger and snapshots the entry hall (to125.lua).

- s9core: 125 pad 16,48 (state 1), east to 132, north to 130, 130 pads
  10,25 and 16,36, core pad 27,41 into 133 (to133.lua). The hall's north
  field is a dead end from the south.
- Core switches ($40-$43 at 30,17 / 13,6 / 2,21 / 2,31) are A-press
  one-shots (`$A125` bits). Each fresh press advances `$A225` and widens
  the west, east and south passages to the centre room by one cell; all
  four open it. From Ogar's room only 30,17 is reachable, so the legs
  s9sw1, s9sw3 and s9sw4in leave through the core pads and re-enter through
  132 (north room), 126 (west room) and 129 (south room). The galleries'
  gate pads are listed as route goals; `MN_AVOIDPADS=1` keeps the far
  planner off other trigger cells so `$A224` follows the plan.
- s9ogar: the last switch, then A on the stone at 18,20 from 18,21. Its talk
  13:697F ends at 13:699A, which posts $01 to Ogar's mailbox ($C6FC), so
  Ogar's thread 13:6C7E starts the duel (opponent $5A, level $14). The
  stone's record script 13:6C68 stores `A123 <- 0A at 13:6C74` (story 10),
  and the leg prints `story 10 reached`.

With 16000 frames (MN_GOD, MN_BAUTO) the duel ends `battle end: win`, the
win tail 13:6CD9 stores $0A again, and the game moves to map 279. That entry
is a script warp, not a door: the tail plants slot 0's anim 13:6D54, and that
slot's thread (2F:44F9, pc 2F:4508) loads 279 after the tail has ended.
`MN_SNAP_TO=s279` checkpoints script warps: Overworld:scriptSnapshot runs
before enterMap and records the last main script (`vm.started`, here
13:6CD9), not the thread doing the load. Replaying 6D54 alone stalls on its
$5C. to279w.lua is written on map 133, and loading it replays the tail into
279 in about 100 frames. A plain number in MN_SNAP_TO still means doors only.

s10map (story 10): 2F:44F9 refills slot 0 with handler $5B1E and Tony's
sprite 20:4F73. $5B1E is bank 1's pad direction-dispatch head, the sibling
of $5D81, so the record is the player itself. Overworld spawn used to treat
only $5D81 that way, so the duel's hidden stand-in stayed and the player was
never shown or moved. Both heads now drop the stand-in (test:
tests/engine/mn_player_record_test.lua). Control comes back at 33,21 in the
east pocket. Walking right crosses 34,21 (2F:44DE; story 10 falls through to
15:5971) into the farm 112, then 113 and 114.

Next goal (story $0A -> $0B, not routed yet): the town. 279's town records
enter 22:595E, whose story switch sends $0A to 22:67BD. That scene stages
slot 0 with 22:6977, which sets both duel tails to 22:6B1A, and 6B1A stores
story $0B. Later stores: $0C at 1A:76AF, $0D at 1E:75EA, $0E at 1E:5572.
From the pocket the way back to the town side is presumably 33,23 into 121
and back through 120..115 (the story-9 legs in reverse). That has not been
checked.

Resolved (decomp, 2026-10-27): $0A is stored on the Core Stone press.
Slot 2's talk handler in 13:6B33 runs 13:6C68, which stores $0A at 13:6C74,
sets the respawn triple 15:4812 and shows the Core Stone text. Only
after that does it stage the Ogar fight (13:6C7E). The win tail 13:6CD9
stores $0A again, which changes nothing. The port logs both stores, which
matches. There was no PyBoy cross-check: there is no harness or save at
that point. Talking to Ogar
(13:6ADF) directly loops and does nothing, which matches the mailbox design
(he waits for $01).

River leg (222 28,4): fixed. The stall reproduced on every seed tried
(1001-1004) and on older master, so it was not flaky. Cause: after the shake,
the talk record ($C71B) runs 1F:5EFB into 1F:5BD7, which refills $C71B with
22:4004 (op $5B at 1F:5BE0) from inside that same record. The port's $5B
waited for the talk thread to end before planting the new record, so the
talk thread waited on itself forever (MN_THR showed `talk@1F:5BE0` from f1800
on). On hardware the fill only overwrites the record and dispatch carries on
in the running script. ScriptVM now skips the self-wait when the talk record
runs $5B (only C6EE == 1 still holds it). The leg now enters map 40, writes
after40.lua at the west door into 0 and follows Eidon through 0, 1, 277 and
2 into 43 within 12000 frames. Regression check in
tests/engine/mn_ops_flow_test.lua.

## Story 10 to 11 (town duel, 2026-10-27)

`MN_LEGS=story10 bash scripts/mn-route12.sh` needs s9/to279w.lua (the pocket
after the geyser dungeon). All legs run with MN_NOENC=1.

- s10back: the pocket back to the town side. 279 33,23 (2F:44D7 -> 15:47BE)
  -> 121 -> 120 -> 117 -> 116 -> 115, using `map:far` in each cave (the far
  trigger cell is the next door). Writes s9/to115r.lua.
- s10town: 115 west into 279, then 20,22 into town map 75 (not 74), door
  2F:4496. Writes s9/to75s10.lua.
- s10duel: the town duel 22:5881 (magi $5F). Battle script 4C:4023 keeps
  re-summoning Borgor ($2E 09 0A 63 C8), so the duel is a scripted loss and
  never ends under MN_GOD=1. The leg sets MN_GOD=0. 22:6977 sets both duel
  tails to 22:6B1A, which stores story $0B (22:6BB9) and enters 1A:6FEA. The
  leg checkpoints the script warp into map 33 (s9/to33s11.lua) and fails if
  $0B is missing or $87 was skipped.
- s11map: from to33s11.lua, the cutscene hands back control on map 33
  (5,16, then 4,17 after the 32/33 walk).

Engine fix: 1A:6FEA opens with `$87 05 05 C8` x5, which refills Tony's
energy. The port only had $87 categories 0, 3 and 4. Categories 5 and 6
(bank 7 AddC9FEClampMapWord1/2) are now in mn.ops.Save.addMapWord: sMapWord1
$A005 (current) += count, clamped to sMapWord2 $A007 (max), and $A007 +=
count, capped at 999. Both are big-endian, in SRAM bank sramBank+1. The
regression test is tests/engine/mn_energy_refill_test.lua.

### Story 11 to 12 (walk to hub 280, 2026-10-27)

The static door graph ignores splits inside a map, so the route was found
with a region-aware BFS (flood-fill each map's walkable cells, follow each
trigger cell to its arrival cell via the trigger's rebase or the door
script's SC_SetC9A1Pair spawn).

- s11walk: 33 -> 32 -> 30 -> 27 -> map 11 (door 17:7310). Writes
  s9/to11s11.lua.
- s11cave: map 11's west and east halves are not connected; the way on is
  the hidden slot at 12,4 (1D:4205), reached by facing down and pressing A
  at 12,3 (`11:12.3d`). Then 13 -> 12 -> 277 37,54 into 159 south. Writes
  s9/to159s11.lua.
- s11road: 159 is split by walls at rows 9-10 and we arrive in the south
  half, so the road goes east: 159 19,22 -> 158 -> 156 -> 153, out 153's
  south edge (36,44) into 152, then 151 -> 150 -> 149 (west part) -> 148
  -> 147 -> 280 24,20 -> 145. 153's north door drops into a sealed pocket of
  149 (rows 33-49, x 27-38) whose only exit is back to 153. Writes
  s9/to145s11.lua.

### Story 12

1A:76AF stores $0C. 145 is a small hub; its C1 door (1A:7174) enters 146 at
5,11 through 1A:773B, which switches on the story word: $0B -> 1A:77E3,
$0C -> 788F, $0D -> 78D6. In 77E3, slot 2 stands at 4,7 and talks 1A:7844
-> 7887; the ask's yes branch (769E) falls into 76AF. $C6F7 there is only a
dialogue-phase counter, so no capture is needed first (an earlier note here
was wrong). Leg s12talk: `145:12.11,146:4.8u`, checkpoint s9/to146s12.lua
(door into 146), and it fails without `A123 <- 0C`.

### Story 13

1E:75EA needs story >= $0C plus ring $2A in $C726. Town 136's third trigger
(17:5DB2, 8,34) enters the forge, map 144. Leg s13walk: 146 -> 145 0,9 ->
280 19,19 -> 138 9,0 -> 135 0,30 -> 136 8,34, checkpoint s9/to144s13.lua.
Leg s13forge: A on the counter (cell $40 at 2,10, 1E:72AB) from 2,11; the
Forge/Equip/Power/Done menu (1E:74EE) takes Forge once (`MN_PICK=1E:7537!`,
then the autopilot's Done), the $8E window picks ring $2A (`MN_FORGE=2A`),
and 1E:75FD stores `A123 <- 0D`. Checkpoint s9/to136s13.lua.

### Story 14

With story $0D, 146's entry (1A:773B) runs 1A:78D6: Valkan's scene (bridge
collapse, the Agadon's boots plan), then a script warp 146 -> 134 -> 135 at
15,0 for the fire distraction. Leg s14walk: 136 19,32 -> 135 28,44 -> 138
4,19 -> 280 24,20 -> 145 12,11 -> 146, checkpoint s9/to146s14.lua; the scene
needs no input.

Fixed (483ba51d): the waiter is the planting script itself. Valkan's slot 2
jumps 28:711A -> 12:7367 (`$45`), which warps and then `$05`-plants slot 2 with
12:74FC (the conversation, 12:52C1) while it is still running in slot 2. The
port's `spawnThread` replaced the slot's thread, so the planter's tail (12:73F6
`$94`, 12:73F7 `$60 $0A`, `$45` 1E:6A49) was dropped. Now `$05` into the running
slot carries the planter on as its own thread (`carry2`), and the planted
script runs in the slot (`tests/engine/mn_record_carry_test.lua`). From
s9/to146s14.lua with no route, the scene runs through 135, carry2 warps to
Ashgar's house 141 (15,0 -> 11,14), "That key must be around here...", the
autopilot takes A on cell $40 (1E:620D, `got 0:29`, sets $A1A5 bit 3) and
control comes back at 13,10 (about 11,000 frames).

Checkpoint into 141: the warp is not a door, and an `s` spec would replay the
whole scene, so `MN_SNAP_TO=c<map>[:n]` checkpoints the n-th control
hand-back in a map (the first free frame after a script, text box, talk
thread or stand-in). It saves map, cell, the live trigger and A lists and
SRAM, and `Overworld.load` runs no script for it
(`tests/engine/mn_control_snapshot_test.lua`). Leg s14scene uses `c141:2`:
Tony on the exit cell 11,15 after 1E:61DC ("That key must be around
here...") and 141's init 1E:623C, before the key. Checkpoint
s9/to141s14.lua.

Leg s14exit (`141:13.10u>11.14>11.15`, about 4,000 frames): the key is the $40
cell at 13,9 (A from 13,10 facing up runs 1E:620D, `got 0:29`, $A1A5 bit 3),
then off and back onto 11,15: 1E:61DC with the key goes 1E:6204 -> 12:7608
(back to 135), and `A123 <- 0E at 1E:55E6`. `MN_ROUTE=141:far` alone loops on
11,15 without the key. After the store the scene goes on into 138 (1E:52C1)
and back to 135; story 15 is not routed. Story 15: the only `A9 0F 00`
(StoreScriptWordAtA123 $0F) sites in the ROM are 19:7838, 28:63BE and
2A:5115 (bank 19 is the likely script; the others may be data), and the
only $10 store is 1F:7B0B. Next step: find which map or trigger runs
19:7838.

$0E itself is stored at 1E:55E2, entered from 12:7608 when C6F9 reads $01;
12:7608 comes from 1E:6204 once $A1A5 bit 3 is set (1E:620D sets it). 1E:5572
is a separate map-init record behind hub 280's C0 door (2F:455E -> 138) and
does not store the story word.

## Story 15 ($0F) leg notes (s15, Oct 28)

Reconstructed from the s15 scratch legs (g1-g7, s2-s4b) and commits 32435720,
43a78022, 3118f251.

Start checkpoint `c180e.lua` (s15 scratch): map 180 at 0,11 facing left,
story word $A123 = $0E, after the story 14 scene hands control back.

Leg route used: `180:0.11,277:37.54|40.55,159:19.24|8.49,158:0.7,181:17.8l`
with `MN_PICK=2A:5255`, `MN_GOD=1 MN_BAUTO=1`. Map 180's step trigger 2A:516B
leads out to overworld 277; 277 trig16 2F:4072 -> 159, 159 1A:467D -> 158,
158 1A:460E -> 159, 159 1A:4686 -> 277, 277 trig17 2F:4079 -> 181.

- Battles on the way (g5): battle Animite was missing, so $A3A5 never grew;
  fixed in 32435720 ((D06C>>1)+1 per win, cap 999).
- Map 181 has the ferryman, slot 2 at 16,8 (talk 2A:58ED, use 2A:5CDE).
  Talking from 17,8 facing left (s4) stopped on `$A7 StoreLookupWordIntoSram`
  (unimplemented), the ferry fare. 3118f251 sizes and runs the $A5/$A6/$A7
  expression stores (`tests/engine/mn_expr_store_test.lua`), and `MN_SEED`
  seeds love.math so random battles on a leg replay the same.
- After the fix (s4b), the ferry pays and warps 181 -> 277 -> map 184 at
  15,4 (music $1E, many scheduled NPCs: a ferry/cutscene map).
- g7 (seed 4, `MN_WATCH=A2AD`, `MN_SNAP_TO=181,c183`): `A2AD <- 02 at
  2A:6276` during the ferry, and the c183 checkpoint was written: map 183 at
  18,7 facing left, $A123 still $0E (s15 scratch `c183.lua`). Map 183's only
  exit is trig0 2A:5FA9 -> 277.
- MN_ROUTE dead end (g2): `route far -> 21,39 (0 steps)` loops forever on
  277 when the target is an NPC cell; don't route onto NPC cells.

Story $0F store: of the three `A9 0F 00` hits, 2A:5115 is inside an
Opcode16 argument run at 2A:5102 (data, not a store). 19:7838 is real:
19:7834 ends a script (`MarkScriptDone21B2`), 19:7835
`StageNextScriptIfByteAtMostC6F7 03 02`, then 19:7838 stores $0F, followed
by 19:783B $07 / 19:783F $09 / 19:7844 `InstallParkedScript`. So the
entry is 19:7835, gated on C6F7 <= 3, but no trigger list or pointer in
the ROM names 19:7835 (it may be planted by a slot record; unresolved).

The real story 15 store is 28:63BE. Map 134's trigger list 21:49E9 (all
five 134 entries 28:68C1/6962/6A13/6DE1/7224 load it) is:
trig0 kind 2 28:63A9 -> 135 (cells 39,59 40,59), trig1 kind 1 28:63B2
(enters 28:69DA), trig2 kind 1 (moving up) 28:63B6: `A2B2 <- 00`, save
triple 28:63B6, `A123 <- 0F` at 28:63BE, Opcode01 0E 1C, then 1F:6241,
which warps 134 -> 185. 185's exits are 1F:5FA7 -> 134 and 1F:5FB6 -> 186,
and the $10 store 1F:7B0B is in the same bank, so story 15 is crossing
from 134 into 185 and story 16 follows in 185/186.

Map 42 (20x20, ten 2-3 cell pads, links to 219/277/83/280/282/134/113) is
a warp room: 2A:5107 (trig8) sets story $0B, $A3A3 = 2 and warps to 134;
2A:5115 (trig9) sets story $0F, $A3A3 = 3 and warps to 113. That is a
debug/test jump, not the story path; don't route through it.

Open problem: no cell in map 134's static block is $C2 (only the two $C0
cells at the bottom). The 28:68C1 entry gates a 4x9 rect copy
(`StageEightScriptBytes 04 D0 04 09 31 D4`, x 4-7 rows 0-8 -> 23,21) on a
$0E expression (`SRAMLookupInstallScript 13 04 05 0E`), and 28:6F9F..6FE5
/ 703A..70BA copy 4x1 rows (bridge building) into 23-26,21-28; none of
those templates hold $C2 either. So the $C2 cell comes from a script
we haven't found (or from a copy whose source rows we read wrong).
Next step: run a leg from the 135 checkpoint (s15 scratch c135.lua, story
$0E) up through 135's T0 (14,0 / 15,0, 12:4000 -> 28:68AA) into 134 with
`MN_TDBG=1` and watch for metatile/copy logs and any $C2 cell.

The g7 ferry loop (181 -> 184 -> 183 -> 277 -> 181) goes back to 181 and
does not move the story; the ferry side trip is not the story 15 path.

g7 result (finished, 22,000 frames): 180 -> 277 -> 159 (two encounters,
1A:4019) -> 158 -> 159 -> 277 -> 181, ferry 181 -> 277 -> 184 -> 277 ->
183 (talk slot 3 2A:60EE, then 2A:5FA9) -> 277 -> 181, ending on a ferry
`use slot 2` with $A123 still $0E. `A2AD` went 02 (2A:6276) then 03
(2A:5422). No engine stop. The ferry side trip does not lead to 134.

134's entry selector 28:68AE (`SelectScriptByExactWord` on $A123): $0B
and $0C -> 28:6961, $0E -> 28:68C0 (the entry with the $0E-gated rect
copy), else falls through. Leg h1 (`run8.sh`: c135.lua,
`MN_ROUTE=135:15.0u,134:far`, `MN_TDBG=1`, `MN_WATCH=A123`) reaches 134
and wrote checkpoint s15 scratch `c134.lua` (map 134 at 40,59, story
$0E). Next step: from c134.lua, read h1's log for the copy/metatile
lines, find the cell that becomes $C2 (or the script that writes it), and
route up onto it to fire 28:63B6 (`A123 <- 0F`) and warp to 185.
h1 result: 135 15,0 -> 12:4000 -> 134 (triggers 21:49E9), then
`134:far` found only the $C0 exit (39,59) and stopped at 39,58: no copy
or metatile logs and no reachable $C2 cell at story $0E. So the $C2 cell
needs an event first (an NPC/slot script in 134 or a prior story
step); dump 134's planted slots (Opcode05 records in 28:68C1) and their
use/talk scripts next.

Found the $C2 cell (engine bug). 134's entry 28:68C1 runs
`CallScriptUnpackIntoWRAM4And6` at 28:692D (metatile 73:5C69 skip 7 ->
WRAM 4, collision 7A:7BD2 skip 3 -> WRAM 6), then at story <= $0F the two
$7F blits 28:693C (7x19 from 7,0 -> 21,0) and 28:6945 (3x4 from 29,0 ->
23,16). The overlay collision has $C2 at 30,2, a 3x4 door template, so the
ROM places the trigger 2 cell at 24,18 (open floor at 24,19 below it).
The port skipped $68 and blitted a snapshot of the live planes, so the
door never appeared. Fix: `$68` now unpacks both streams from the full ROM
(`h.fullRom`, mn_cache/rom.bin) into the overlay planes;
`tests/engine/mn_ops_records_test.lua` covers it. Next leg (h2): c135.lua
-> 135:15.0u -> 134:24.18u with `MN_WATCH=A123`.

### The 24,18 door region is cut off at story $0E (blocker)

Leg h2 (`135:15.0u,134:24.18u`) stops with "route far: no path from 40,59",
and that is the map, not the $68 fix. With the ROM's 28:68C1 blits applied
(story $0E: the 6924 `$7E` 4x9 copy from 4,0 -> 23,21 runs, the 6956 blit is
skipped), the 40,59 entry region is 693 cells with only C0@39,59, and the
24,19 region (139 cells, x 18-32, y 3-24) holds C2@24,18. The only seam is
x 24-25: rows 23 and 27 are $00, row 24 is $02/$00 and rows 25-26 are
$02 $02. The 6924 copy is that broken pattern itself (it copies map cells
4..7,0..8), so this is the collapsed bridge from Valkan's scene, not a cell
the port forgot to write.

Where the bridge scene comes from: 28:6DD8 (134 entry: A2B2 <- 01,
FinishStartup, A2AD <- 01, NPCs, then 28:6F6C staging 4x1 rows into x 23-26,
rows 21-28) is entered only by four walk scripts 1A:791D/7931/7959/7971
(each ends `$45 28:6DD8`). They are picked by facing in 1A:79A1, which is the
talk script of slot 2 (3,8) in map 146's entries 1A:788F and 1A:78D6. 146's
init 1A:773B switches on the story word: $0B -> 77E3, $0C -> 788F,
$0D -> 78D6, $0E -> 7775 (no slot 2), others -> 7775 if $A1A5 bit 3 else
7A25. So the bridge scene is the story 14 scene already routed (s14walk);
at $0E 146 has no trigger for it.

Open question for the next leg: `World.walkable` blocks $02 outright, and
its own comment says $01-$03 are driven by $C12A/$C12B
(clear_c12a_set_c12b.asm, the record heads in bank 1) which the port does
not run. If the ROM lets Tony cross $02 cells (the Agadon's boots plan from
the story 14 scene), that is the engine gap: route `134:24.18u` needs $02
handled like the ROM, with a regression test. Check against a reference
run, or decode bank 1 $57F9/$5888/$5A5B, before changing walkability.

### What the ROM does with $01-$03 cells (story 15 work)

Decoded from bank 1 (decomp names, ~/Code/magination):

- `$C12A-$C131` is an 8-byte gate table indexed by cell value; ProbeCells*
  blocks a cell under `$08` when its byte is nonzero. The ground pattern is
  `00 FF FF 00 FF FF FF FF`: `$00`/`$03` open, `$01`/`$02` solid.
- A blocked step runs `Dispatch*ZeroStepCellRun` (01:51B6 down, 01:526A up,
  01:51F2 left, 01:522E right), which calls `CountCellRun` (01:517C) on the
  cells ahead. `$01` and `$02` continue the run (at `$C9A6 >= 4` only `$02`;
  a `$01` instead enters the `$01` layer via Plant5969WhenCellIs01). The run
  ends on `$00`/`$82` and keeps its count; any other end cell forces 3.
- Count 1: a free hop. Count 2: needs `$C9A6 >= 3`. Count 3+: needs
  `$C9A6 >= 5` and switches to the `$02`-layer record heads
  (ClearC12CAndSetC12A etc. rewrite `$C12A-$C12C` per layer).
- `$C9A6` is the walk copy of SRAM `$A3A3` (item level). Stores of `$A3A3`:
  3 at 19:7B66 (map 250 A-list 19:7B30, "Tony got Agadon's Boots!", also
  `$A224 = 3`), 3 at 1C:4168 ("Hey! This is my stuff!"), 3 at 2A:5118
  (debug room); 4 at 2F:4738; 5 at 19:63C3, 2A:50CE, 2A:5144.

Port: `World.cellRun`/`World.hop` mirror counts 1 and 2; Overworld takes the
hop on a blocked step, and the Boot route BFS adds the hop as an edge
(`World.mark()` reads `$C9A6`). The `$01`/`$02` layer walks (count 3+, mark
4+) are still not modelled. `tests/engine/mn_hop_test.lua` covers the rule.
Landing on the first `$00`/`$82` cell is inferred: the hop scripts
(`$56F9`, `$5813`, ...) are still INCBIN. No PyBoy reference: PyBoy is not
installed on kiss and there is no reference save at this point.

### Why 24,18 is cut off at story $0E

The x=25 seam into the 24,18 region is `$00` (row 24), `$02 $02` (rows
25-26), `$00` (row 27): a count-2 hop, so it needs Agadon's Boots. Checkpoint
c134 has `$A3A3 = 2`, so the route skipped the boots. Warp path to map 250:
134 -> 135 -> 138 -> 280 -> 147 -> 159 -> 277 (trig19 2F:4087) -> 257
(1B:488C) -> 255 (1B:4007) -> 241 (19:6B2C) -> 242 (19:6C89) -> 247
(19:6F64) -> 249 (19:71B7) -> 250 (A-list 21:5340 -> 19:7B30).

Scratch check of the hop (not a legal route): c134 with `$A3A3` forced to
3, `134:24.18u`, `MN_WATCH=A123`. The far search now takes hops and found
24,18 in 63 steps; the walk logged `hop 34,14 -> 31,14` (a second count-2
seam, east of the x=25 one) and ended at 24,17 on map 134 with no `$A123`
write. The live cells around 24,17 were all `$00`: the 28:6945 3x4 door blit
(C2 at 24,18) is missing from the live plane, so trigger 2 (28:63B6:
`$A2B2 <- 0`, `A123 <- 0F`, warp to 185) never fired. Next: find out why the
`$68` overlay is not in the live plane after an `MN_LOAD` into 134 (sim.lua
applies the blits by hand, the live run does not show them), then get the
boots legitimately (map 250) and rerun from a real checkpoint.

### Door missing after MN_LOAD: control checkpoints lose plane edits (fixed)

Cause: a control checkpoint (`MN_SNAP_TO=c<map>`) saved only the map, cell,
trigger lists and SRAM, and `Overworld.load` builds the map from the stored
record without rerunning the entry script (Boot skips "map entry" under
`MN_LOAD`). Everything 134's entry 28:68C1 did to the live planes (the `$68`
overlay unpack, the 28:693C / 28:6945 `$7F` blits with C2 at 24,18, the
28:6924 `$7E` bridge copy) was gone after a load. The old c134.lua also
predates a224af1a, so it never had the door even at save time.

Fix: `writeSnapshot` for kind `c` now stores `planes={i,col,mt,...}`, the
diff of the live collision/metatile planes against the stored map
(`Overworld.planeDiff`, base from `Overworld.baseMap`), and `Overworld.load`
puts it back through `applyPlanes` (also queued as draw patches).
`tests/engine/mn_control_snapshot_test.lua` covers save, restore and the
no-diff case. Snapshot-replay checkpoints (`s`/door) still rerun a script and
are unchanged.

New checkpoint s15 scratch `c134p.lua` (leg h3: c135.lua ->
`135:15.0u,134:far`, `MN_SNAP_TO=c134`): map 134 at 40,59, story `$0E`,
`$A3A3 = 2`, 76 plane cells including C2 at 24,18 and the `$02` seam at x 24-25.

Scratch check only (not the route): `c134pb.lua` = c134p with `$A3A3` forced
to 3, `134:24.18u`, `MN_WATCH=A123`: `hop 25,27 -> 25,24`, then trigger 2
28:63B6 fires, `A123 <- 0F at 28:63BE`, warp to 185 at 24,18. So the door
and the count-2 hop both work once the boots are real.

### The boots leg: the 159 -> 277 warp path is not walkable at `$A3A3 = 2`

Leg b1 (c134p -> `134:39.59,135:28.44,138:9.19,280:29.21,147:28.24,159:8.49,
277:58.45,...,250:10.6u`, seed 4) wrote control checkpoints k135 (135),
k280 (280) and k159 (159 at 4,0, story `$0E`, `$A3A3 = 2`), then sat in 159
fighting encounters without reaching the exit. Map 159 rows 9-10 (x 2-10) are a
full-width `$02 $02` band ending on `$00`: a count-2 hop, which needs
`$A3A3 >= 3`. So the north side (147) cannot reach 159's south exit 1A:4686
without the boots. g7 only crossed 159 from the south.

Map 277 (overworld sea) is no shortcut either: its land patches are islands in
`$01` water, and the boots-area door D3 (trig19 2F:4087 -> 257) sits on an
island at 54-58, 44-47 together with D6 (trig22 2F:409C -> 182). Map 182's
only door is back to that island (13:7A92), so the island is reached by a
script warp into 182. Its map-load operand (`$65 AA 4A 4F`) appears at
13:7A9A (182's own entry) and at three bank-2A sites: 2A:605F, 2A:6172 and
2A:654C. Bank 2A around there is the pirate ship 183 ("Swab the sails! Wax
the parrot! ..." talk 2A:60EE), and 2A:6040-605F tests `$A2B2`, `$A2AD` and
`$A2AB` before the load. So the real path to the boots is most likely
181 ferry -> 184 -> 183 (pirate ship) -> 182 -> 277 island -> 257 -> 255 ->
241 -> 242 -> 247 -> 249 -> 250, gated on the ship's `$A2AD`/`$A2AB` state.
g7 took the ship and came back to 181 with `$A2AD = 03`; what sets `$A2AB` (or
which branch of 2A:6040 loads 182) is the open question.

Next: decode 2A:6040-6060 and 2A:6150-6180 (the conditions in front of the
two 182 loads), find the 183 talk/use that satisfies them, then route
c183.lua -> 182 -> 277 (D3 at 58,45) -> ... -> 250 (`250:10.6u`, the `$40`
cell at 10,5, A-list 21:5340 #0 -> 19:7B30, `$A3A3 <- 3` at 19:7B66). Back at
134 the door is now live (c134p plus the plane fix), so the store needs only
the boots.

### Pirate ship -> 182 -> 257 for real; stuck in 255

Probe p1 (c183.lua, default planner with MN_TALK=1, seed 4): talking to 183
slot 2 (2A:60EE) and slot 3 (2A:671D) sails the ship onto 277 at 29,11, and
the walk then takes D6 (2F:409C) into 182. That wrote the control checkpoint
k182 (story `$0E`, `$A3A3 = 2`), so the ship is the real way onto the boots
island and no menu pick is needed.

Leg q1 (k182, `182:far,277:58.45,257:10.10,255:0.0,...,250:10.6u`) walked
182 -> 277 -> D3 at 58,45 -> 257 -> 255 and wrote k257 (257 at 8,18). Map 255
(24x20) is entered at 15,18. Its forward exit is C1 at 0,0/1,0
(1B:4007 -> 241), and C2 at 11,6 is a script cell (1B:4020, no warp). The
planner reports `route far: no path from 15,18` for both targets, so 255 has a
gate the walk model does not open: a hop, an A-list switch, or a step script.
Leg q2 saw step trigger 1B:488C and the init scripts 1B:406F, 1B:4109 and
1B:4195. Next: read those and 255's A-list, find the passable cells, and route
on to 241 -> 242 -> 247 -> 249 -> 250.

Scratch checkpoints on kiss (/tmp/mn-s15, not in the repo): k182, k257 (real,
story `$0E`).

### Map 255's gate is the wall switch at 17,4 (not a walk-model gap)

The "no path from 15,18" in q1/q2 was for the goal 0,0. The 255 cell grid
(24x20) has two parts: the room (x 6-20, y 5-15, joined to the 257 door C0 at
15,19 by the 15,16-18 corridor) and a sealed pocket at x 0-1, y 0-3 holding
the 241 exit C1 (0,0 / 1,0, trigger 2 1B:4007) over floor at 0-1,2-3. No walk
rule joins them, and the room itself is fully walkable (probe r1 reached C2 at
11,6 in 16 steps). Nothing in the port was wrong here.

The gate is a scripted switch on SRAM `$A125` bit `$02`:

- 255's init scripts 1B:406F, 1B:4109 and 1B:4195 (`$A1`
  PlantParkedHandlerWhenLCDOff) pick the A-press handler and the metatile for
  the cells at WRAM `$D071` / `$D070` / `$D06F` = 17,4 / 16,4 / 15,4 (the
  `$40 $41 $42` row), from `$A125` bits `$02` / `$04` / `$08`.
- 17,4 is the wall switch: "Click!", a camera pan (`$83` deltas), then a
  `$7E` 2x2 cell copy onto 10,6 (`$D09A`). Setting the bit (1B:40BF,
  "What the?....") copies the pocket's top-left block (`$D000`, the C1 C1 exit
  row) onto 10-11,6; clearing it (1B:407A, "Hmmmm...") copies the pocket floor
  (`$D030`) back. So with the bit set, 10-11,6 is the door to 241.
- 16,4 and 15,4 are bookshelves (joke books, "Pranks to Play on Blonde Haired
  Strangers" / "Hey...! Wait a minute!") that toggle bits `$04` and `$08`.
- C2 at 11,6 (1B:4020) checks `$A125 == $02` exactly; otherwise it prints the
  hint "That's odd, I just felt a gust of wind...". So leave the shelves alone.
- Coming in from 241 (19:6B06) ORs `$02` in, so the way back is always open.

Route: `255:17.5u>11.6` (face the switch, press A, then step onto the copied
C1 at 11,6 -> 241).

### 255 -> 241 -> 242 -> 247 -> 249 for real; 249's exit to 250 is behind a pirate scene

Leg r2 (k257, `257:10.10,255:17.5u>11.6,241:22.31,242:47.7,247:27.49,...`):
the A press on 17,4 ran 1B:406F (metatile 17,4 -> `$A0`), the copied C1 at
11,6 took 1B:4007 into 241, and the walk went 241 (19:6B2C) -> 242 (19:6C89)
-> 247 (19:6F64) -> 249 at 0,7. New control checkpoints (story `$0E`,
`$A3A3 = 2`, in `~/.local/state/interns/snaps/magirecomp/s15/`): k255 (255 at
15,18), k241 (241 at 7,6), k249 (249 at 0,7).

Map 249 (36x30): the 250 exit C1 sits at 33-34,28, sealed. The way out is a
`$7E` copy of the 3x2 block at 32-34,27-28 (`$D3EC`) onto 26-28,1-2 (`$D03E`),
which puts C1 at 27-28,2 above the row-3 ledge. Three of 249's entry scripts
(19:7751, 19:7784, 19:77F2) do that copy at load; the one that runs at story
`$0E` from 247 (19:78CE, A-list 21:5332, pirate in slot 2 at 24,4 with talk
19:7256 and anim 19:7977) does not. At story `$0E` the copy comes from:

- C2 at 18-19,5 (trigger 3, 19:71C1): `$A224 == 0 && story == $0E` ->
  19:790A, a scene (player thread 19:7918, music `$17`, `$0B 02` wakes slot 2).
  The pirate's anim 19:7977 stores `$A224 = 1`.
- The `$40` cell at 27,2 (A-list entry 19:71D1): `$A224 == 1 && story == $0E`
  -> 19:71E1: `$A224 = 2`, then the `$7E` copy that opens C1 at 27-28,2.
- Talk 19:7256 is the pirate ("Har har har... No luck, eh Toney?"; later
  "Ye've helped me ... take this. A horn?" via `$87 00 1E 01`).

19:7838 (`$A123 <- $0F`) is also here, in entry 19:77F2, gated on the `$C6F7`
phase; the route's real `$0F` store is still 134's 28:63BE.

Harness note: a control checkpoint does not keep NPC records, so from k249
the 18,5 scene wakes nothing and `$A224` stays 0 (probe r5). Legs through 249
must start from k241 or earlier.

### 249 pirate scene from k241 (runs r6/r7)

- Starting from `k241` (so NPC records exist), the 249 leg loads the pirate in slot 2 at 24,4
  (talk 19:7256, anim 19:7977, beh 19:7A49). Walking over C2 at 18,5 fires 19:71C1 and music `$17`,
  and the pirate anim stores `$A224 <- 01` at 19:797B (seen with `MN_WATCH=A224`). So the scene half
  works in the port.
- The next goal, 27,3 facing up (the A press on the `$40` cell at 27,2, 19:71D1), is never reached. The
  router logs `stuck at 25,3 next 26,3`, gives up and moves on to 24,5. 26,3 is blocked, most likely
  by the pirate standing on it while the 7977 walk runs, or because the walk never finishes. 19:71E1
  never runs, so `$A224` stays 1 and C1 to 250 stays sealed.
- Next: dump obj/NPC positions during frames after 71C1 to see whether the pirate parks on 26,3, then
  either wait it out (add a hold goal before 27,3), path around via 27,4u, or fix the anim/beh
  interpreter if the walk is stuck. Note: `MN_WATCH` takes one hex address only.

### 249 switch reached (run r9): the pirate parks on 26,3

- `MN_STUCKDBG=1` now also prints the live object records and the cell under 26,3. From k241 (9000
  frames) the stuck line reads `objs 2@26,3 cell26,3=00`: the pirate's 7977 walk ends standing on
  26,3 and stays there, which is correct behaviour (the original parks him beside the switch), not an
  interpreter bug.
- The router's stuck replan then paths 25,3 -> 25,4 -> 26,4 -> 27,4 -> 27,3 (4 steps), faces up, and
  the A press runs 19:71D1 -> 19:71E1, `A224 <- 02 at 19:71E1`. So the route needs no engine fix, only
  enough frames for the scene (r7's shorter leg replanned to 24,5 before the scene finished).
- Door checkpoints (`MN_SNAP_TO=249`, no `c`) replay the 247 -> 249 door script, so they rebuild the
  NPC records; use those instead of the control checkpoint k249 for legs through 249.

### 249 -> 250 for real; the boots chest runs (runs r11/r12, from door checkpoint k249d)

- New door checkpoint `k249d` (247 -> 249 door, replays 19:6F64 so 249's NPC records exist) and
  control checkpoint `k250` (250 at 9,19, story `$0E`, `$A3A3 = 2`), both in
  `~/.local/state/interns/snaps/magirecomp/s15/`.
- Harness fix (Boot.lua): a ">" chain only counts a text box or cell script as "the goal's talk" once
  Tony is standing on that goal. Before, the 18,5 pirate scene's box on the way to 27,3 marked the
  goal done, so the chain skipped the A press and looped `no path from 27,3` (r11).
- r12, route `249:27.3u>27.2,250:10.6u`: 19:71C1 scene, `A224 <- 01 at 19:797B`, replan around the
  pirate on 26,3, A on 27,2 runs 19:71D1, `A224 <- 02 at 19:71E1`, C1 at 27,2 (19:71B7) -> 250 at
  9,19 (init 19:7B30 / 19:7B74), 19 steps to 10,6, A runs 19:7B30, metatile 10,5 := `$FF` (chest
  open), `A224 <- 03 at 19:7B62`. `$A3A3 = 3` (19:7B66) is not confirmed yet (the run watched
  `$A224`); next leg loads k250 with `MN_WATCH=A3A3`, then 250 -> back to 134 and `$0F` at 24,18u.

### Agadon's Boots for real (r13/r14)

- From k250, `250:10.6u`: A runs 19:7B30, `A3A3 <- 03 at 19:7B66`. The boots are stored for real
  (story still `$0E`).
- Control checkpoint `k250b` (`MN_SNAP_TO=c250:2`, the hand-back after the chest): 250 at 10,6,
  story `$0E`, `$A3A3 = 3`.
- Next: k250b -> back to 134 (159's two-tile hop band should now pass with `$A3A3 = 3`), then `$0F` at
  24,18 moving up with `MN_WATCH=A123`.

### Back from the boots: 250 -> 249 landed on 5,5 inside a wall (fixed)

- Leg t1 (k250b, `250:9.19,249:0.7,...`) crossed 250's C0 (19:7AFC) into 249 and stuck at 5,5 with
  "route far: no path". 5,5 is a `$08` wall.
- 19:7AFC: `$A224 == 4 && story == $0E` -> 19:77ED (no rebase); otherwise `$02 08 1A 13 02` (9,19 ->
  27,2) then 19:7744 -> 19:78BF -> (`$A224 > 0`) 19:777F, whose `$93` falls into entry 19:7784: `$65`
  load 249, slot-0 `$05` template at 5,5, `$00`, then the `$7E` copy of the C1 block onto 26-28,1-2
  (the same copy that opens the 250 exit), `$94`.
- The port dropped the pair when the slot-0 `$05` ran because 27,2 was still a wall then (the
  ringsmith rule, 14:7DD2). In the original `$00` copies the pair to `$C18E` regardless, so Tony
  stands on 27,2 once the copy has run. Fix (ScriptVM): a pair blocked at `$05` is kept as
  `pairWall` and applied at the entry's `$94` / park if its cell is open by then; `$65` clears it.
  Ringsmith is unchanged (its cell stays a wall). Test: `tests/engine/mn_door_rebase_test.lua`.
- Harness: the aff7e0f7 ">" rule moved to `mn.boot.RouteGoal.talkEndsGoal` with
  `tests/engine/mn_route_goal_test.lua`. `MN_STUCKDBG` now also prints the live 15x11 cell window
  around Tony once per stuck spell.

### 241 -> 255 door is up-only (harness fix)

- From k241r the goal `241:7.6` was reached from 8,6 moving left and nothing fired: 241's
  trigger 0 (6-7,6, script 19:6B06 -> 255) is kind 1, which World.gate only fires moving up.
- The far planner now enters a goal that sits on a direction-gated step trigger (kind 1-4) only
  from the side it fires on. Probe t3d: 7,7 -> 7,6 up ran 19:6B06, "door crossed -> map 255 at
  11,5".

### Back across the island to 182 (leg t4, k241r)

- `241:7.6,255:15.19,257:8.19,277:55.46` from k241r: 241 (19:6B06) -> 255 at 11,5 -> 257 (1B:4000)
  at 15,19 -> 277 (1B:4876) at 10,19 -> D6 at 55,46 (2F:409C) -> 182 at 29,11. New control
  checkpoints (story `$0E`, boots): k255r, k257r, k182r.
- The island is not walkable to 159 (277 is sea; the 241-276 cluster + 257 only connects through
  the 277 island's D3/D6 and 182). In 182 MN_TALK talked to slot 2 (10,11, talk 2A:60EE) and
  slot 3 (6,11, talk 2A:671D); neither moved the ship in 9000 frames. Next: OPLOG 2A from k182r
  with a route onto 10,12u / 6,12u to read what those talks gate on (likely `$A2AB`/`$A2AD`).

### Why the ship does not sail from 182 (static read, k182r)

- The 182 pirate talks gate on nothing that moves the ship. Slot 2 (10,11): behaviour 2A:60BC is a
  dance loop, talk 2A:60E6 -> 60EE is flavour text. Slot 3 (6,11): talk 2A:671D checks
  `$A1B0 & $40` (set -> 2A:67A7 "Thanks again"); otherwise it sets the bit and gives item `$15`.
- The 277 -> 182 D6 (2F:409C -> 2A:6041) sets `$A2B2 = 1`, then:
  - `$A2AD >= 3`: `$A2AB = 1`, FollowScriptWord 2A:6204 -> 2A:6205 (183, ferry waiting at the dock,
    ferryman talk 2A:58ED).
  - `$A2AD < 3` -> 2A:6056: story `== $0F` -> 2A:6171/6172 (182 `$0F` variant, "Hey! The ferry's
    gone! How will I get back!?", `$A1AC |= $10`); otherwise 2A:605E -> 605F (the pirate variant).
- `$A2AD` writers: 28:6DDD (1), 2A:6276 (2, 183 arrival entry 2A:627A), 2A:6446 (3, pay 300 from
  the 183 talks 2A:63C0 / 2A:6516; `$A3A5 < 300` -> 2A:6489 "not enough Animite"), and the 181
  mainland ferryman 2A:5422..5863 (3, pay 600). k182r has `$A2AD = 2` and 159 Animite: the 300 was
  never paid, so the ferry left. `$A2AB` writers: 2A:5C88 (2), 2A:5C9F (0), 2A:604F (1).
- Way home is the horn, not the ferry: 250's C0 19:7AFC runs 19:77ED (`$A2B2 = 1`, entry 19:77F2)
  when `$A224 == 4 && story == $0E`. 77F2 is the 249 scene whose pirate talk 19:7281 -> 72D8 gives
  item `$1E` (the horn, "If yer ever in trouble... I'll be comin' to help") and stores
  `A123 <- $0F` at 19:7838.
- `$A224 = 4` is 19:7C99, the end of talk 19:7B9A ("Is that a...", "You're welcome"), the pirate
  in 250 slot 2 (entry 19:7CF8, spawn 9,21, walk-in 19:7D34 installs talk 7B9A). He is woken by
  250's second entry script 19:7B14 -> 19:7B24 (`$A224 == 3 && story == $0E`, Opcode0B 02), which
  only runs on a fresh entry into 250 after the chest. Run u2 (k249d, chest only) ended with
  `$A224 = 3` and slot 2 still parked (talk 19:7CA7).
- So the order is: chest (`$A224 = 3`) -> leave 250 -> re-enter 250 -> talk to the pirate
  (`$A224 = 4`) -> leave 250 (77ED/77F2 in 249) -> horn + `$0F` -> 182 `$0F` variant 2A:6172.
  No script read of `$A3C5` (the horn's item byte) was found by a `C5 A3` byte search yet.
- Run u4 (k250b, `250:9.19,249:27.3u>27.2`, `MN_WATCH=A224`): 250 -> 7AFC -> 249 at 27,2 -> 71B7 ->
  250 at 9,19 again. The re-entry ran only init 19:7B30 / 19:7B74; 19:7B14 (pointer at 21:533E,
  next to 7AFC's at 21:533A) never ran, so 19:7B24 / Opcode0B 02 did not wake the pirate and
  `$A224` stayed 3. Blocker: find how the original runs the 21:533E script on entry to 250 (which
  map-record slot it is and who walks it) and port that with a failing-then-passing test. Run u3
  (k249d, route with two separate 249 legs) stuck at 1,7 with no path; not followed up.

### 250 pirate wake: 19:7B14 is the `$C1` step trigger, not an entry script (story `$0F`)

- 250's live trigger list is 21:5337 (`trig=21303` in k250b): count 2, `[02 19:7AFC]` (`$C0`),
  `[02 19:7B14]` (`$C1`). The init list follows at 21:5340 (`[01 19:7B30] [01 19:7B74]`). So
  21:533E is trigger `$C1`'s pointer, not a second entry script. Map 250's block has `$C1` at
  9,16 and 10,16 (`$C0`, the exit, at 9-10,19). Both are kind 2: World.gate fires them only when
  Tony steps onto the cell moving down.
- 19:7B14 is `$43` on `AND($A224 == 3, story == $0E)` -> 19:7B24 (`$07`, `$09`, `$0B 02`). Run u4
  did run it, on the walk out from k250b, but slot 2 does not exist on that visit; it is spawned
  (parked at 9,21, walk-in 19:7D34) only by the fresh entry from 249. After re-entering at 9,19
  the route walked up over row 16 (no fire) and never stepped down onto it again.
- No engine change was needed: the port already matches. Regression test
  `tests/engine/mn_down_trigger_wake_test.lua` pins the condition and the down-only gate
  (synthetic bytes). All 42 `tests/engine/mn_*` pass.
- Run w2 (k250b, `250:9.19|9.16d,249:27.3u>27.2`): 250 -> 249 -> 250 at 9,19, route 7 steps to
  9,16 entering from 9,15 down, 19:7B14 fires, the pirate walks in, MN_TALK -> `A224 <- 04` at
  19:7C99.
- Run w3 (same, `250:9.19|9.16d>9.19`, `MN_WATCH=A123`): after the talk, 9,19 -> 19:7AFC -> 249
  scene (slot 0 talk 19:7281 at 27,2), "got 0:30 x1" (item `$1E`, the horn) and
  `A123 <- 0F` at 19:7838. Control returns in 249 at 24,4. New checkpoints (s15 snaps):
  k250w (250 at 9,16, `$A224 = 4`, story `$0E`) and k249h2 (249 at 24,4, story `$0F`, horn).
- Next: from k249h2 back across the island to 182 (k241r's leg t4 route: 241 -> 255 -> 257 ->
  277 D6 -> 182) to check the 2A:6172 `$0F` scene ("The ferry's gone!", `$A1AC |= $10`), then on
  toward `$10` (Shadow Geyser).

### Story `$0F` back at 182 (leg w4, k249h2)

- `249:0.7,247:0.7,242:12.0,241:7.6,255:15.19,257:8.19,277:55.46` from k249h2: 249 -> 247 -> 242
  -> 241 (19:6C6E) at 22,31 -> 255 (19:6B06) at 11,5 -> 257 (1B:4000) at 10,11 -> 277 (1B:4876) ->
  D6 2F:409C -> 182 at 29,11. With story `$0F` the D6 took the 2A:6172 variant: slot 0 at 11,3
  (talk 2A:61CF, "Hey! The ferry's gone!...") and `A1AC <- 11` at 2A:61AC. Control at 11,3.
- New control checkpoints (story `$0F`, horn): k241h, k255h, k257h, k182h.
- Toward `$10`: the only `A9 10 00` store is 1F:7B0B, in handler 1F:7AEE (record planted from
  1F:7A9E) of map 189 (trigger list 21:4F5A, entries 1F:79E5 / 1F:7AAC; 1F:7AAC's slot templates
  at 15,16 and 12,16). Map-cache doors into 189 come from 187 and 188. Next: OPLOG 2A from k182h
  (talk 2A:61CF and what it plants), then find the walk or horn use that leads to 187/188.

### Toward `$10`: off the island is 257, not the horn (k182h)

- Talk 2A:61CF is Tony's own line, not an NPC: slot 0 in the 2A:6172 `$0F` variant is the
  cutscene stand-in (template `$4A6B`, behaviour 2A:61B1: walk 20:4FDD/20:50BF, then the
  61CF text, `$13 $5D81` hands control back). It plants nothing; the only state it leaves is
  `A1AC |= $10` (2A:61AC). OPLOG 2A (run x3, k257h -> 182) shows that order.
- `A1AC & $10` is read in one other place: 257's entry 1B:4E6A (from 255 trig0 1B:4000 and 277 D3
  2F:4087) sets `$A2B2 = 1` and picks by story word (`$4B`): `$0E`/`$0F` -> 1B:4FDE, `$12`/`$13` ->
  1B:4EEA, `$14` -> 1B:4F0D. 1B:4FDE is `AND(story == $0F, $A2AD == 2, $A1AC & $10)` -> 1B:5042:
  257 with slot 2 at 7,12 whose talk 1B:509A walks Tony and enters 2A:6547 (a 182/183 scene with
  four 6B4A stand-ins that ends in 1B:46B4). That is the way off the island at `$0F`. Run w4
  crossed 257 before the 182 scene, so the flag was not set yet.
- Engine bug found on the way: k182h left Tony at 11,3, inside the 182 wall (only row 11 is
  floor). The `$0F` entry fills slot 0 as a stand-in at its template cell 11,3, then `$00`
  copies the D6 pair 29,11 to `$C18E`, which is slot 0's record cell. The port moved only the
  player, so the stand-in walked from 11,3 and released control there. Fix: `$00` also moves a
  live slot-0 stand-in (`moveStandIn`). Test `tests/engine/mn_standin_pair_test.lua` fails
  before, passes after; all 43 `tests/engine/mn_*` pass. k182h is stale (wall cell); use k257h
  and replay the D6 leg.
- Route to the `$10` store (graph from the trigger lists): 134 -> 185 (28:63B6) -> 186 ->
  187 (1F:628F..62BC) -> 189 (1F:694F/6958), or 187 -> 188 (1F:6946/6961/6993) -> 189
  (1F:74F5). In 189, 1F:7A99 stores `$A3A4 = 4` and 1F:7A9D installs 1F:7AEE (record 1F:6271,
  walk 50B5/505D, then 1F:7B0B `$A123 = $10`, door pair 24,18, enter 28:721F).

### Leaving the island at `$0F` (legs x5-x8, k182f -> k257g -> 256)

- With the `$00` stand-in fix, k257h -> 277 D6 -> 182 releases Tony at 26,11 on the bridge row:
  checkpoint **k182f** (story `$0F`, `A1AC = $11`, `A2AD = 2`). Route note: two `277:` keys in
  one MN_ROUTE overwrite each other (the later wins), which looped 257 <-> 277 in x4; use
  `277:55.46|58.45` for per-entry goals.
- From k182f, `182:29.11,277:58.45,257:7.13u` reaches 257 entry 1B:5042 (boatman, slot 2 at
  7,12). In the original, using him runs his record 1B:509A: `$5B` plants talk 1B:4D16 ("I guess
  you're stuck here..."), whose tail `$9A $58 01` posts C6FC -> C6FD; the record's `$4B` branch
  waits on C6FD == 1, then 1B:50ED walks him and enters 2A:6547 (`A2B2 = 1`, the crossing).
- Engine bug 2: the port only ran a record script on use when it did not start with `$5B`, so
  every `$5B` record ran just its talk and 509A's wait-and-branch tail never ran (x5: sixteen
  4D16 talks, no scene). Fix: `Overworld.useRunsRecord` runs the record as the slot thread unless it
  is exactly `$5B bank ptr, $42` (plain NPC talk). Test `tests/engine/mn_use_record_test.lua`;
  all 44 `tests/engine/mn_*` pass. x8: `use slot 2 -> 1B:509A`, then 182 (scene) -> 256 at 22,11
  -> 256 at 12,4. k257g (snapshot at 257 entry) does not respawn the boatman on load; replay from
  k182f instead.
- Next: from 256 (checkpoint k256a if saved), map the 256 exits toward 134 -> 185 -> 186 -> 187
  -> 189 with MN_WATCH=A123.
