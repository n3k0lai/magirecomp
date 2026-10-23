#!/usr/bin/env bash
# Headless story route: new game (map 216) through control after the Korg duel
# (map 8, beat 12). Each leg is one `mn-headless` run. A leg that is not the
# first resumes with MN_LOAD from the previous leg's door snapshot.
# Snapshots and logs stay in /tmp/mn-route12. Frame PNGs stay in
# /tmp/mn-route12/frames and are deleted at the start of each leg.
#
#   bash scripts/mn-route12.sh
#   MN_ROM=/path/to/magination.gbc bash scripts/mn-route12.sh
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
BEATS=(
  "1|script 2A:6CB5"
  "2|script 1F:5D95"
  "3|enter map 40"
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

# run_leg NAME FRAMES ROUTE SNAP_TO SNAP_FILE [LOAD]
run_leg() {
  local name="$1" frames="$2" route="$3" snap_to="$4" snap_file="$5" load="${6:-}"
  local log="$SNAP/${name}.log"
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
run_leg into222 8000 \
  "219:far,220:12.0,221:36.0" \
  222 "$SNAP/into222.lua"

# Later legs append below. Beats 2 and 3 are reached on the crystal leg.

require_beats
echo "route12: ${printed} beat(s) confirmed"
