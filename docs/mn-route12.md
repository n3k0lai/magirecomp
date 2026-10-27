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

Open: the port also runs the stone's record script 13:6C68 (story $0A at
13:6C74) on the A press, before the duel. Whether hardware stores $0A only
in the win tail has not been checked against PyBoy. Talking to Ogar
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
