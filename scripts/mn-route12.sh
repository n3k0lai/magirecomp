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

require_beats
echo "route12: ${printed} beat(s) confirmed"
if [ ! -f "$SNAP/beat12.snap" ]; then
  echo "beat 12: NOT REACHED (no $SNAP/beat12.snap)" >&2
  exit 1
fi
echo "beat 12 reached"
