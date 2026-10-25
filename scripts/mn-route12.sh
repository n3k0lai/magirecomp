#!/usr/bin/env bash
# Headless story route: new game (map 216) through control after the Korg duel
# (map 8, beat 12). Each leg is one `mn-headless` run. A leg that is not the
# first resumes with MN_LOAD from the previous leg's door snapshot.
# Snapshots and logs stay in /tmp/mn-route12. Frame PNGs stay in
# /tmp/mn-route12/frames and are deleted at the start of each leg.
#
#   bash scripts/mn-route12.sh
#   MN_ROM=/path/to/magination.gbc bash scripts/mn-route12.sh
#   MN_FROM=town bash scripts/mn-route12.sh   # reuse earlier legs' snapshots and logs
#   MN_LEGS=bracelet bash scripts/mn-route12.sh  # only the bracelet legs, from into15.lua
#
# Prints one "beat N: ..." line when that beat's log marker appears.
# Exits nonzero if a beat marker is missing or a snapshot was not written.
set -uo pipefail
cd "$(dirname "$0")/.."

ROM="${MN_ROM:-$HOME/Code/magination/roms/magination.gbc}"
HEAD="${MN_HEADLESS:-$HOME/Code/interns/bin/mn-headless}"
SNAP=/tmp/mn-route12
FRAMES=/tmp/mn-route12/frames
mkdir -p "$SNAP" "$FRAMES"

# Beat markers, in story order. Each is a fixed substring of a [mn-test] log
# line (map entry or script start). Addresses are the decomp routines the
# checklist names; nothing from the ROM is printed beyond those lines.
# Beat 2's crystal talk is the npc record on map 222 (1F:5D95), logged when
# that map's entry spawns it. The pickup that starts the cave-in is 1F:5EAE.
# Beat 3 is the scripted fall into map 40 (2A:4774). Beat 4 is map 40's west
# exit after the river scene. Legs after beat 6 checkpoint on doors (snapshot
# files) until the next beat's marker is known. See docs/mn-route12.md.
BEATS=(
  "1|script 2A:6CB5"
  "2|talk=1F:5D95"
  "3|enter map 40"
  "4|door crossed -> map 0"
  "5|enter map 2 "
  "6|enter map 63 "
  "7|script 14:700F"
  "8|script 28:5918"
  "9|got 3:1 x1"
  "10|got 0:45 x1"
  "11|door crossed -> map 5 at"
  "12|player control at 8,8"
)

LOGS=()

# Print any beat whose marker is now in the logs and that we have not printed.
printed=0
report_beats() {
  local spec n pat f hit
  for spec in "${BEATS[@]}"; do
    n="${spec%%|*}"
    pat="${spec#*|}"
    if [ "$n" -le "$printed" ]; then continue; fi
    hit=""
    for f in "${LOGS[@]}"; do
      hit=$(grep -m1 -F "$pat" "$f" || true)
      if [ -n "$hit" ]; then break; fi
    done
    if [ -z "$hit" ]; then return; fi
    echo "beat $n: ${hit#*\[mn-test\] }"
    printed=$n
  done
}

require_beats() {
  local spec n pat f hit missing=0
  for spec in "${BEATS[@]}"; do
    n="${spec%%|*}"
    pat="${spec#*|}"
    hit=""
    for f in "${LOGS[@]}"; do
      hit=$(grep -m1 -F "$pat" "$f" || true)
      if [ -n "$hit" ]; then break; fi
    done
    if [ -z "$hit" ]; then
      echo "beat $n: NOT REACHED ($pat)" >&2
      missing=1
    fi
  done
  return "$missing"
}

# MN_FROM=NAME: legs before NAME are not run again when their snapshot and log
# from an earlier run are still in $SNAP.
FROM="${MN_FROM:-}"

# run_leg NAME FRAMES ROUTE SNAP_TO SNAP_FILE [LOAD]
run_leg() {
  local name="$1" frames="$2" route="$3" snap_to="$4" snap_file="$5" load="${6:-}"
  # Optional extra VAR=value settings for this leg only (e.g. MN_TALK=1).
  local extra=("${@:7}")
  local log="$SNAP/${name}.log"
  if [ "$name" = "$FROM" ]; then FROM=""; fi
  if [ -n "$FROM" ] && [ -f "$log" ] && { [ -z "$snap_to" ] || [ -f "$snap_file" ]; }; then
    echo "leg $name: reused"
    LOGS+=("$log")
    report_beats
    return
  fi
  find "$FRAMES" -name 'frame_*.png' -delete 2>/dev/null || true
  if [ -n "$load" ] && [ ! -f "$load" ]; then
    echo "leg $name: missing snapshot $load" >&2
    exit 1
  fi
  echo "leg $name: $frames frames"
  # An empty MN_LOAD is still set, and Lua treats any set value as truthy.
  if [ -n "$load" ]; then export MN_LOAD="$load"; else unset MN_LOAD; fi
  if [ -n "$snap_to" ]; then export MN_SNAP_TO="$snap_to" MN_SNAP_FILE="$snap_file"; else unset MN_SNAP_TO MN_SNAP_FILE; fi
  set +e
  env \
    MN_NOMUSIC=1 \
    MN_NEWGAME=1 \
    MN_GOD=1 \
    MN_BAUTO=1 \
    MN_FRAMES="$frames" \
    MN_START=216 \
    MN_ROUTE="$route" \
    "${extra[@]}" \
    "$HEAD" love . --mn --rom "$ROM" --mn-test "$FRAMES" >"$log" 2>&1
  local ec=$?
  set -e
  LOGS+=("$log")
  if [ "$ec" -ne 0 ]; then
    echo "leg $name: love exited $ec" >&2
    exit "$ec"
  fi
  if [ -n "$snap_to" ] && [ ! -f "$snap_file" ]; then
    echo "leg $name: snapshot $snap_file was not written" >&2
    grep -F "[mn-test] final player" "$log" >&2 || true
    exit 1
  fi
  grep -F "[mn-test] final player" "$log" || true
  report_beats
}

# Bracelet legs (after beat 12): the floor-lever puzzle from map 15 to map 24.
# They start from into15.lua (the door into 15) and keep their checkpoints in
# $BSNAP (MN_SNAP_DIR overrides). The puzzle bits are $A125 bits 0-3; see
# docs/mn-route12.md, "Bracelet legs".
BSNAP="${MN_SNAP_DIR:-$HOME/Code/interns/state/snaps/magirecomp}"
run_bracelet() {
  mkdir -p "$BSNAP"
  # levers: 20's two levers (1A:62AB 9,14 and 1A:6304 16,15), then 19's lever
  # (1A:6234 5,22) by way of 16 -> 17 -> 18; ends on 18's door into 23 (1A:61C4).
  MN_WATCH=A125 run_leg levers 18000 \
    "15:0.13|10.0|0.13,16:8.0|23.10|0.10,19:23.16|12.23|5.21d>0.4,20:9.15u>0.16|16.16u>16.23,17:10.0,18:25.5|16.0" \
    23 "$BSNAP/into23.lua" \
    "$BSNAP/into15.lua"
  # corridor: 23's lever (1A:6533 6,13, bit 3), back out through 18 into 19's
  # upper half, 19's east door into 20 (1A:6222, init 1A:6324 opens column 14),
  # then 20's north door into 21, 21 -> 22 -> the 23 corridor -> 24.
  MN_WATCH=A125 run_leg corridor 14000 \
    "23:6.14u>11.21|0.6,18:25.5,19:23.5,20:15.0,21:0.7,22:0.6" \
    24 "$BSNAP/into24.lua" \
    "$BSNAP/into23.lua"
  # gate24: talk to 24's NPC at 6,15 (1A:6645 -> 1A:5C7D, $A126 bit 2), back
  # through 23 to 22's lever (1A:64AF 13,2: $A125 bit 4 and $A126 bit 3), then
  # 23 -> 24, where init 1A:65D7 opens the wall, and 24's north door into 25.
  MN_WATCH=A126 run_leg gate24 12000 \
    "24:6.16u>19.18|7.1,23:23.6|0.6,22:13.3u>0.6" \
    25 "$BSNAP/into25.lua" \
    "$BSNAP/into24.lua"
  # duel25: talk to 25's slot 2 (1A:672C, story word 6), then step on 25's exit:
  # with story 6 its door (1A:668E) runs the guardian scene (1A:66A3 -> 1A:674C in
  # slot 0) into the director duel at 1A:5F88 (won with MN_GOD; its length varies
  # with the seed). The win script 1A:67C7 leads through 9 into the small room 10,
  # whose south door into 277 writes out10.lua (10:down; "far" waits on slot 0).
  MN_WATCH=A123 run_leg duel25 17000 \
    "25:5.6u>5.11,10:down" \
    277 "$BSNAP/out10.lua" \
    "$BSNAP/into25.lua"
  # in229: the same duel, then room 10's north door (5,4) into 229 (writes in229.lua).
  MN_WATCH=A225 run_leg in229 20000 \
    "25:5.6u>5.11,10:5.4,229:far" \
    229 "$BSNAP/in229.lua" \
    "$BSNAP/into25.lua"
  # a225: A on 229's $40 cell from 50,9 (13:7372, $A225 = 1), back through 10 and
  # out of the 277 enclosure into 7 (a225g7.lua). The Geyser step-on at 37,8 is
  # only live while the story word is 3..5 (2F:41F4), so it no longer fires here.
  MN_WATCH=A225 run_leg a225 16000 \
    "229:50.9u>44.24,10:5.11,277:38.10" \
    7 "$BSNAP/a225g7.lua" \
    "$BSNAP/in229.lua"
  # to225: 7 -> 5 -> 4 -> 3 -> 277's west half -> 223 -> 225 (a225in225.lua).
  run_leg to225 22000 \
    "7:5.19,5:12.29,4:0.21,3:0.20,277:18.36,223:23.21" \
    225 "$BSNAP/a225in225.lua" \
    "$BSNAP/a225g7.lua"
  # bracelet: 225's 8,4 NPC from 9,4 facing left ($A225 = 2), out at 7,11, then
  # 223's 22,22 NPC from 22,23 facing up (1D:465D: story 7, $A3A3 = 2).
  MN_WATCH=A3A3 run_leg bracelet 7000 \
    "225:9.4l>7.11,223:22.23u" \
    223 "$BSNAP/out225.lua" \
    "$BSNAP/a225in225.lua"
  # to229: out225.lua is written on the door into 223, before the bracelet talk
  # ($A3A3 still 1), so talk to 223's 22,22 NPC first ($A3A3 = 2), then
  # 223 -> 277 -> 3 -> 4 -> 5 -> 7 -> the 277 enclosure, over 37,8 (Geyser
  # not taken at story 7) into room 10 (37,7), north door into 229 (to229in229.lua).
  run_leg to229 36000 \
    "223:22.23u>22.38,277:37.13|37.7,3:far,4:far,5:21.0u,7:far,10:5.4" \
    229 "$BSNAP/to229in229.lua" \
    "$BSNAP/out225.lua"
  # kick: first bracelet kicks on 229's $0B wall: A from 41,13 facing left clears
  # 40,13, A from 40,13 clears 39,13, then walk through to 38,13 (no snapshot).
  run_leg kick 6000 \
    "229:41.13l>40.13l>38.13" \
    "" "" \
    "$BSNAP/to229in229.lua"
  grep -q "kick 39,13" "$SNAP/kick.log" && grep -q "final player 38,13 map 229" "$SNAP/kick.log" || {
    echo "leg kick: the wall at 39-40,13 was not kicked through" >&2
    exit 1
  }
  # The legs from the kick to the Underneath world map (279) and into the caves
  # are not scripted yet; they were run by hand and left to120.lua (map 120's
  # west side, entered from 115 at 4,0). Without it the next two legs are skipped.
  if [ ! -f "$BSNAP/to120.lua" ]; then
    echo "underneath legs: skipped (no $BSNAP/to120.lua)"
    return
  fi
  # underneath: 120's west side is cut off by the $09 block field (11-14,7-11)
  # until the Crystal Gloves push is ported, so go back out through 115, its top
  # door into 116, 116's bottom-right door into 117, 117's west edge into 120's
  # east side, 120's 26,0 into 121, 121's top door onto the 279 pocket, then
  # 279's 34,21 into 112 and 112's 12,9 into the farm (113, to113.lua).
  run_leg underneath 44000 \
    "120:5.0|26.0,115:22.0,116:40.39,117:0.36,121:5.0,279:34.21,112:12.9,113:11.11" \
    113 "$BSNAP/to113.lua" \
    "$BSNAP/to120.lua"
  # farm: talk to Gruk (the farm's shopkeeper) at 11,10 from 11,11 (the route
  # leaves his shop with B); the talk sets $A125 bit 2 (15:5C08). 113's stairs at 14,6 lead to
  # the basement (114), whose line at row 10 (15:5E97 -> 15:5F06) sets $A224 = 1
  # and runs the kidnap scene; back in 113 the init (15:5D88) sets $A224 = 2.
  MN_WATCH=A224 run_leg farm 6000 \
    "113:11.11u>14.6,114:3.10" \
    114 "$BSNAP/to114.lua" \
    "$BSNAP/to113.lua"
  grep -q "A224 <- 02" "$SNAP/farm.log" || {
    echo "leg farm: \$A224 did not reach 2" >&2
    exit 1
  }
}
if [ "${MN_LEGS:-}" = bracelet ]; then
  run_bracelet
  echo "bracelet legs: bracelet given, first kick done (farm legs need to120.lua)"
  exit 0
fi

# Leg 1. New game, Tavel Gorge, cave to the door into map 222.
# 219:far only advances text (slot 0 owns the player until the script warps).
# 220 north lip is 12,0; 221 north lip is 36,0 (both kind-1, walked onto upward).
# The gorge cutscene on 219 has no door of its own; 3000 frames is still
# inside it (player hidden at 6,14), so this leg stays one 8000-frame run.
run_leg into222 8000 \
  "219:far,220:12.0,221:36.0" \
  222 "$SNAP/into222.lua"

# Leg 2. From the map 222 door, stand beside the crystal (29,4) and face it.
# 1F:5EAE plays the cave-in and the fall into map 40 (2A:4774). The river
# scene (2A:4837 .. 2A:4C51) has no door inside it, so this leg runs until
# Tony walks out of map 40's west exit (live list 21:4228/21:4231 -> map 0)
# and snapshots that door; the default planner then follows Eidon through
# 0, 1, 277 and 2 into Vash Naroom (43).
run_leg river 12000 \
  "222:28.4r" \
  0 "$SNAP/after40.lua" \
  "$SNAP/into222.lua"

# Leg 3. Vash Naroom (43). Entry 1 is Eidon's scene from the stairs; it ends
# with a second entry at 2,46. Only after that entry ("@43#2") does the route
# take over: up through the step trigger at 6,38 (16:4026) to the north exit
# at 9,0 (live list 16:4271 entry 1, 16:401D -> map 44).
run_leg town 8000 \
  "@43#2,43:9.0" \
  44 "$SNAP/into44.lua" \
  "$SNAP/after40.lua"

# Leg 4. From the 44 door: north exit 13,0 (16:52ED -> 51), then 51's east
# exit 29,2 (2B:4B3E -> 53). The default planner takes 53 -> 54 -> 63, and
# the leg snapshots the 54 door into Orwin's house (28:50D8).
run_leg orwin 6000 \
  "44:13.0,51:29.2" \
  63 "$SNAP/into63.lua" \
  "$SNAP/into44.lua"

# Leg 5. Out of Orwin's house (14,9 -> 54), back west through 53 and 51 to 44,
# then 44's east exit (23,5 -> 48) and 48's door at 12,2 (16:6D7F -> 59).
# A on the ringsmith's counter cell (10,9 from 10,10) runs 14:700F, which
# gives the ring and 50 Animite. The leg snapshots 59's exit 8,13
# (14:7006), the second door into 48 in this run.
run_leg ring 11000 \
  "63:14.9d,54:3.9d,53:0.27l,51:13.23d,44:23.5r,48:12.2u,59:10.10u>8.13d" \
  48:2 "$SNAP/after59.lua" \
  "$SNAP/into63.lua"

# Leg 6. From 48 west to 44 (0,6), 44 west to 47 (0,5), 47's door 8,4
# (16:67EF -> 55). Poad's talk (28:5918, from 7,14 facing up) offers the rest;
# the rest scene ends with control at 16,5. Then 55's exit 14,17 (28:541F)
# is the second door into 47 in this run. The fireplace Remedy Drink (60) is
# left for the historian leg.
run_leg inn 7000 \
  "48:0.6l,44:0.5l,47:8.4u,55:7.14u>14.17d" \
  47:2 "$SNAP/after55.lua" \
  "$SNAP/after59.lua"

# Leg 7. Evu's chain, all keyed on the story-phase byte $A224 (story word 2):
# Evu (60, slot 2 at 15,5, record 2B:479E) picks his talk by $A224. At 1 (set
# by the ringsmith) his talk 2B:41CB sets 2. With $A224 = 2, 55's init
# (28:5BDF) loads another scene: slot 2 at 7,13 whose record 28:5C27 sets 3.
# Back in 60 at 3, his talk asks for the jellybeans; picking 2B:43F0 sets 4
# and gives spell 3:1. 52 is entered four times; the fourth is the exit from
# 60 after the trade (52:4, after60.lua).
MN_PICK=2B:43F0 MN_WATCH=A224 run_leg evu 10000 \
  "47:19.7r|8.4u|19.7r,44:13.0u|0.5l|13.0u,51:0.12l|13.23d|0.12l,52:4.1u|17.5r|4.1u,60:14.5r>6.9d|14.5r>6.9d,55:7.14u>14.17d" \
  52:4 "$SNAP/after60.lua" \
  "$SNAP/after55.lua"

# Leg 8. Eidon's training (beat 10): from 60's exit, walk back down through
# 51 and 44 into 43. Entering 43 sets $A224 to 5 (16:510C) and the Eidon scene
# moves to the training grounds (61), which hands over the Awl (0:45, control
# at 10,9). Stepping on 61's west cell 0,9 (13:4163) runs the quake (13:5D5F,
# story word 3); the goal has no facing, so the autopilot steps off and back
# on and the second step takes the door (13:4000) into 2 (after61.lua).
run_leg train 7000 \
  "52:17.5r,51:13.23d,44:12.16d,43:far,61:0.9" \
  2 "$SNAP/after61.lua" \
  "$SNAP/after60.lua"

# Leg 9. The Glade (beat 11): the quake scene in 2 (14:50BA) ends with control
# at 12,8. 2's south door 6,15 (14:49B0) leads to 277, whose cell 37,13
# (2F:4010) is the Glade entrance (3). 3 and 4 are walked with the far
# planner. 5's far exit is the side clearing 6 (0,6), so 5 takes its north
# door 21,0 (14:6141) into 7 (after5.lua). MN_GOD covers the wild battles.
run_leg glade 6000 \
  "2:6.15d,277:37.13,3:far,4:far,5:21.0u" \
  7 "$SNAP/after5.lua" \
  "$SNAP/after61.lua"

# Leg 10. The Korg duel (beat 12): 7's far exit is the north door (14:63F4)
# into 277. Its goal 37,8 is the step-on record 2F:4210 that moves
# the scene into the Shadow Geyser (8, 14:6A95). The duel (14:4174) is won
# with MN_GOD (the battle length varies with its seed, so the leg has slack);
# its win tail (14:6B30) ends with control at 8,8. Then 8's far
# exit leads back into 277, and that second door into 277 writes beat12.snap.
run_leg korg 12000 \
  "7:far,277:37.8,8:far" \
  277:2 "$SNAP/beat12.snap" \
  "$SNAP/after5.lua"

require_beats
echo "route12: ${printed} beat(s) confirmed"
if [ ! -f "$SNAP/beat12.snap" ]; then
  echo "beat 12: NOT REACHED (no $SNAP/beat12.snap)" >&2
  exit 1
fi
echo "beat 12 reached"

# Story 7 tail (optional). The legs from beat 12 to the tower are not scripted
# yet; set MN_TO211 to a snapshot taken on the door from 212 into 211
# (17:44B5, the ring side room) to run the last two legs.
if [ -n "${MN_TO211:-}" ]; then
  # Leg S7a. The Gruk rescue: with MN_TALK the autopilot talks to the figure
  # at 211's south door 10,16 (script 17:43A7), whose step trigger 17:438F
  # moves the scene into tower 210. The scene there stores $A224 = 6 at
  # 17:42C3 (Gruk is freed); the second door into 210 writes gruk6.lua.
  run_leg gruk 6000 "" \
    210:2 "$SNAP/gruk6.lua" \
    "$MN_TO211" MN_TALK=1 MN_WATCH=A224
  # Leg S7b. Back to town: 210 -> 277 (31,38) -> 110 (5,29) -> 108 (16,39)
  # -> 279 -> the town icon 19,22. The town's arrival scene stores story
  # word 8 at 22:6498. The snapshot needs MN_SNAP_TO=75 (see the doc).
  run_leg home 9000 \
    "210:1.0,277:31.38,110:5.29,108:16.39,279:19.22" \
    75 "$SNAP/to75s8.lua" \
    "$SNAP/gruk6.lua" MN_WATCH=A123
  grep -qF "A123 <- 08 at 22:6498" "$SNAP/home.log" || { echo "story 8: NOT SET" >&2; exit 1; }
  echo "story 8 set (22:6498)"
fi

# Story 8 -> 9 (optional). Set MN_TO80S8 to a snapshot on the town door into
# house 80 at story 8 (1C:6645, to80s8.lua). The story-9 store is the step
# on 279's 34,21 (2F:44DE -> 15:4BB4, case 8 -> 15:4C10, store at 15:4CCB).
# That cell sits in the south pocket: east out of town, 279's 32,26 into 115,
# the long cave way to 121, and 121's north door back onto 279 at 33,22.
# Cave maps 115-120 have wandering monsters; one battle on 116 is longer than
# the frame cap, so those legs set MN_NOENC=1. 279's entry puts a slot-2
# sprite on 34,21; it does not block the $C5 cell (World.blocks, see
# docs/mn-route12.md).
if [ -n "${MN_TO80S8:-}" ]; then
  S9=/tmp/mn-story9
  mkdir -p "$S9"
  # Out of house 80, across town, east edge 59,21 (22:41B2) onto 279 at 21,22.
  run_leg s9east 2000 \
    "80:far,74:59.21" \
    279 "$S9/to279e.lua" \
    "$MN_TO80S8"
  # 279's 32,26 (2F:44D0) into 115 at 0,16.
  run_leg s9c115 1500 \
    "279:32.26" \
    115 "$S9/to115.lua" \
    "$S9/to279e.lua" MN_NOENC=1
  # 115's top door (15:4010, goal 24,0; the line is 22-26,0) into 116 at 2,39.
  run_leg s9c116 1800 \
    "115:24.0" \
    116 "$S9/to116.lua" \
    "$S9/to115.lua" MN_NOENC=1
  # 116's bottom-right door (15:41B9) into 117 at 12,0.
  run_leg s9c117 2800 \
    "116:41.39" \
    117 "$S9/to117.lua" \
    "$S9/to116.lua" MN_NOENC=1
  # 117's west edge (15:4258) onto 120's east side at 59,8.
  run_leg s9c120 2000 \
    "117:0.36" \
    120 "$S9/to120e.lua" \
    "$S9/to117.lua" MN_NOENC=1
  # 120's 26,0 (15:4739) into 121, then 121's 5,0 (15:47B3) onto 279 at 33,22.
  run_leg s9pocket 2500 \
    "120:26.0,121:5.0" \
    279 "$S9/to279p.lua" \
    "$S9/to120e.lua" MN_NOENC=1
  # 34,21 is the story door. Slot 2 stands on it, but a sprite only blocks a
  # $00 cell (MarkZeroMapCell), so the step reaches 15:4CCB.
  run_leg s9door 1500 \
    "279:34.21" \
    "" "" \
    "$S9/to279p.lua" MN_NOENC=1 MN_WATCH=A123
  grep -qF "A123 <- 09 at 15:4CCB" "$SNAP/s9door.log" || { echo "story 9: NOT SET" >&2; exit 1; }
  echo "story 9 reached"
fi
