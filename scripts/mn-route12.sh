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

require_beats
echo "route12: ${printed} beat(s) confirmed"
if [ ! -f "$SNAP/beat12.snap" ]; then
  echo "beat 12: NOT REACHED (no $SNAP/beat12.snap)" >&2
  exit 1
fi
echo "beat 12 reached"
