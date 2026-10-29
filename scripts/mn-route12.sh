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
#   MN_LEGS=story9 MN_TO80S8=to80s8.lua bash scripts/mn-route12.sh  # story 8 -> Ogar -> 279
#   MN_LEGS=story10 bash scripts/mn-route12.sh  # story 10 -> town duel (needs s9/to279w.lua)
#   MN_LEGS=story15 bash scripts/mn-route12.sh  # story 14 -> 15 (needs s15/r15-135.lua or MN_TO135S14)
#
# Prints one "beat N: ..." line when that beat's log marker appears.
# Exits nonzero if a beat marker is missing or a snapshot was not written.
set -uo pipefail
cd "$(dirname "$0")/.."

ROM="${MN_ROM:-$HOME/Code/magination/roms/magination.gbc}"
HEAD="${MN_HEADLESS:-$HOME/Code/soul/skills/intern/scripts/interns/bin/mn-headless}"
ISTATE="${INTERNS_STATE_DIR:-$HOME/.local/state/interns}"
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

# snaps_written FILES: true when every file in the comma list exists
# (MN_SNAP_FILE may pair a comma list of files with MN_SNAP_TO).
snaps_written() {
  local f files
  IFS=, read -ra files <<<"$1"
  for f in "${files[@]}"; do [ -f "$f" ] || return 1; done
}

# run_leg NAME FRAMES ROUTE SNAP_TO SNAP_FILE [LOAD]
run_leg() {
  local name="$1" frames="$2" route="$3" snap_to="$4" snap_file="$5" load="${6:-}"
  # Optional extra VAR=value settings for this leg only (e.g. MN_TALK=1).
  local extra=("${@:7}")
  local log="$SNAP/${name}.log"
  if [ "$name" = "$FROM" ]; then FROM=""; fi
  if [ -n "$FROM" ] && [ -f "$log" ] && { [ -z "$snap_to" ] || snaps_written "$snap_file"; }; then
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
  if [ -n "$snap_to" ] && ! snaps_written "$snap_file"; then
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
BSNAP="${MN_SNAP_DIR:-$ISTATE/snaps/magirecomp}"
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
# Story 8 -> 9 (optional). Set MN_TO80S8 to a snapshot on the town door into
# house 80 at story 8 (1C:6645, to80s8.lua). The story-9 store is the step
# on 279's 34,21 (2F:44DE -> 15:4BB4, case 8 -> 15:4C10, store at 15:4CCB).
# That cell sits in the south pocket: east out of town, 279's 32,26 into 115,
# the long cave way to 121, and 121's north door back onto 279 at 33,22.
# Cave maps 115-120 have wandering monsters; one battle on 116 is longer than
# the frame cap, so those legs set MN_NOENC=1. 279's entry puts a slot-2
# sprite on 34,21; it does not block the $C5 cell (World.blocks, see
# docs/mn-route12.md).
run_story9() {
  S9="${MN_S9_DIR:-/tmp/mn-story9}"
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
  # The leg snapshots that door (to122.lua); the 279:34.21 goal ends here, so
  # the planner does not bounce back out of 122 after the mouth scene.
  run_leg s9door 1500 \
    "279:34.21" \
    122 "$S9/to122.lua" \
    "$S9/to279p.lua" MN_NOENC=1 MN_WATCH=A123
  grep -qF "A123 <- 09 at 15:4CCB" "$SNAP/s9door.log" || { echo "story 9: NOT SET" >&2; exit 1; }
  echo "story 9 reached"
  # Geyser mouth (122). The door replays 2F:44DE -> 15:4C10 (the mouth scene);
  # control comes back at 6,19. The up-trigger at 6,13 (15:481D) enters the
  # entry hall (125) at 14,49. See docs/mn-dungeons.md for the door graph.
  run_leg s9mouth 3000 \
    "122:6.13" \
    125 "$S9/to125.lua" \
    "$S9/to122.lua" MN_NOENC=1
  # Entry hall to the core. The four colored gates share SRAM $A224 (one color
  # open at a time; see docs/mn-dungeons.md). The 125 pad at 16,48 (state 1)
  # opens the row-46 $06 gate; the hall's north field is a dead end from the
  # south, so the path is east to 132, north to 130, then the 130 pads at
  # 10,25 (state 4) and 16,36 (state 3) open the way to the core pad at 27,41.
  # A ">" goal on a plain pad cell advances once the pad script has run.
  run_leg s9core 4000 \
    "125:16.48>29.28,132:7.0,130:10.25>16.36>27.41" \
    133 "$S9/to133.lua" \
    "$S9/to125.lua" MN_NOENC=1
  # Core switches. The four $40-$43 cells (30,17 / 13,6 / 2,21 / 2,31) each
  # advance $A225 once and widen three passages (west, east, south) by one
  # cell; after all four the centre room is open. Only the first switch is
  # reachable from Ogar's room, so the tour leaves through the core pads and
  # comes back in through 132 (north), 126 (west) and 129 (south). The galleries'
  # gate pads are listed in the goals; MN_AVOIDPADS keeps the planner off the
  # others so $A224 matches the plan.
  run_leg s9sw1 14000 \
    "133:30.18u>32.37|13.7u>32.5,130:16.36>28.31>28.9>10.25>8.46|6.20>0.8,132:27.9|9.0,129:13.10>22.46" \
    126 "$S9/to126.lua" \
    "$S9/to133.lua" MN_NOENC=1 MN_AVOIDPADS=1
  run_leg s9sw3 8000 \
    "126:5.9|23.6>23.0,133:2.20d>2.7,129:19.36" \
    129 "$S9/to129b.lua" \
    "$S9/to126.lua" MN_NOENC=1 MN_AVOIDPADS=1 MN_WATCH=A225
  grep -qF "A225 <- 03" "$SNAP/s9sw3.log" || { echo "core switch 3: NOT PRESSED" >&2; exit 1; }
  run_leg s9sw4in 4000 \
    "129:19.36>10.46|4.38,128:4.15>13.1,133:2.32" \
    133 "$S9/to133s.lua" \
    "$S9/to129b.lua" MN_NOENC=1 MN_AVOIDPADS=1
  # Last switch, then A on the stone (18,20): its talk 13:697F posts $01 to
  # Ogar's mailbox and starts the duel (opponent $5A). The stone's record
  # script 13:6C68 stores story $0A; the duel's win tail 13:6CD9 stores it
  # again and the game leaves the dungeon for the Underneath map 279 (a script
  # warp, not a door: MN_SNAP_TO=s279 checkpoints the script that loads 279,
  # and to279w.lua replays the win tail from map 133).
  run_leg s9ogar 16000 \
    "133:2.32u>18.21u" \
    s279 "$S9/to279w.lua" \
    "$S9/to133s.lua" MN_NOENC=1 MN_AVOIDPADS=1 MN_WATCH=A123
  grep -qF "A123 <- 0A" "$SNAP/s9ogar.log" || { echo "story 10: NOT SET" >&2; exit 1; }
  grep -qF "battle end: win" "$SNAP/s9ogar.log" || { echo "Ogar duel: not won" >&2; exit 1; }
  grep -qF "enter map 279" "$SNAP/s9ogar.log" || { echo "Ogar duel: no exit to 279" >&2; exit 1; }
  echo "story 10 reached (Ogar beaten)"
  # After Ogar (story $0A): replay the win tail from to279w.lua. Its slot 0
  # thread (2F:44F9) loads 279 and plants the $5B1E pad head with Tony's
  # sprite, which hands control back at 33,21 (east pocket, next to the farm
  # cell 34,21; with no route the autopilot walks on into the farm 112-114).
  # Next goal (not routed yet): the town at story $0A, where 22:595E case $0A
  # (22:67BD) stages the duel 22:6977 whose tails 22:6B1A store story $0B.
  run_leg s10map 2000 "" "" "" "$S9/to279w.lua"
  grep -qF "player record at" "$SNAP/s10map.log" && grep -qF "enter map 112" "$SNAP/s10map.log" ||
    { echo "after Ogar: no control on 279" >&2; exit 1; }
  echo "story 10: control on 279"
}
run_story10() {
  local S9="${MN_S9_DIR:-$BSNAP/s9}"
  # Back through the caves from the 279 pocket (to279w.lua, story $0A):
  # 279 33,23 (2F:44D7 -> 15:47BE, 121 at 5,1) -> 121 south 7,19 -> 120
  # 26,0 -> 120 east 59,7 -> 117 0,35 -> 117 12,0 -> 116 43,39 -> 116 2,39
  # -> 115 26,0 -> 115 west 0,18 -> 279 31,26. Each map's "far" trigger is
  # the reverse door. The leg snapshots the door into 115.
  run_leg s10back 6000 \
    "279:33.23,121:far,120:far,117:far,116:far" \
    115 "$S9/to115r.lua" \
    "$S9/to279w.lua" MN_NOENC=1
  # 115 west door onto 279 (31,26), then onto the town icon 20,22 (map 75).
  # The leg snapshots that door (to75s10.lua).
  run_leg s10town 2500 \
    "115:far,279:20.22" \
    75 "$S9/to75s10.lua" \
    "$S9/to115r.lua" MN_NOENC=1
  # Town at story $0A: 22:67BD stages the townsfolk, then slot 0 (22:6977)
  # walks up and starts the duel 22:5881 (magi $5F). Its battle script
  # (4C:4023) re-summons Borgor ($2E 09 0A 63 C8: 99 spends, 200 energy), so
  # the fight is a scripted loss; 22:6977 sets both tails to 22:6B1A, which
  # stores story $0B and enters the 1A:6FEA cutscene. MN_GOD=0 lets Tony lose
  # (with MN_GOD=1 the battle never ends).
  # 1A:6FEA opens with $87 05 05 C8 x5 (refill Tony's energy, sMapWord1 up to
  # sMapWord2), then loads map 33; the leg checkpoints that script warp.
  run_leg s10duel 9000 \
    "" \
    s33 "$S9/to33s11.lua" \
    "$S9/to75s10.lua" MN_NOENC=1 MN_WATCH=A123 MN_GOD=0
  grep -qF "A123 <- 0B" "$SNAP/s10duel.log" || { echo "story 11: NOT SET" >&2; exit 1; }
  ! grep -qF "unimplemented \$87" "$SNAP/s10duel.log" || { echo "story 11: \$87 skipped" >&2; exit 1; }
  echo "story 11 reached"
  # Story 11 from the map-33 checkpoint: the cutscene hands control back.
  run_leg s11map 8000 "" "" "" "$S9/to33s11.lua" MN_NOENC=1 MN_WATCH=A123
  grep -qF "player control at" "$SNAP/s11map.log" || { echo "story 11: no control" >&2; exit 1; }
  echo "story 11: control after the town duel"
  [ -n "${MN_STORY10_ONLY:-}" ] && return
  # Story 11 -> 12: the Lava Arboll ask sits in building 145 off hub 280
  # (door C1, 2F:4565 -> init 1A:717B; list 21:4C07 runs 1A:7174 -> 773B,
  # story $0B -> 1A:77E3). Door path from the house: 33 9,19 -> 32 east ->
  # 30 south -> 27 east -> 11. Map 11's west half is cut off from its east
  # door; the way on is the hidden slot at 12,4 (1D:4205; face down + A at
  # 12,3) into cave 13 (init 1D:4097) -> 12 -> 277 37,54 -> 159. 159 is
  # split by a wall at rows 9-10; the south half leaves east (19,24) into 158
  # -> 156 -> 153 -> 149 -> 148 -> 147 -> 280 24,20.
  run_leg s11walk 8000 \
    "33:9.19,32:49.9,30:39.49,27:39.10" \
    11 "$S9/to11s11.lua" \
    "$S9/to33s11.lua" MN_NOENC=1
  run_leg s11cave 6000 \
    "11:12.3d,13:11.4,12:15.5,277:37.54" \
    159 "$S9/to159s11.lua" \
    "$S9/to11s11.lua" MN_NOENC=1
  run_leg s11road 22000 \
    "159:19.24,158:39.12,156:43.0,153:36.44,152:41.0,151:0.4,150:0.4,149:0.4,148:0.8,147:6.24,280:24.20" \
    145 "$S9/to145s11.lua" \
    "$S9/to159s11.lua" MN_NOENC=1
  # Story 12: 145's C1 door (1A:7174) enters 146 at 5,11 via 1A:773B, which
  # on story $0B runs 1A:77E3. Slot 2 there (4,7) talks 1A:7844 -> 7887; the
  # ask's yes branch (769E -> 76AF) stores $0C. No capture is needed first.
  run_leg s12talk 9000 \
    "145:12.11,146:4.8u" \
    146 "$S9/to146s12.lua" \
    "$S9/to145s11.lua" MN_NOENC=1 MN_WATCH=A123
  grep -qF "A123 <- 0C" "$SNAP/s12talk.log" || { echo "story 12: NOT SET" >&2; exit 1; }
  echo "story 12 reached"
  # Story 13 (1E:75EA) is the ring forge in map 144: town 136's third trigger
  # (17:5DB2, 8,34) enters 1E:76E0. Path from 146: 145 0,9 -> 280 19,19 ->
  # 138 9,0 -> 135 0,30 -> 136 8,34.
  run_leg s13walk 16000 \
    "146:4.8u>5.12,145:0.9,280:19.19,138:9.0,135:0.30,136:8.34" \
    144 "$S9/to144s13.lua" \
    "$S9/to146s12.lua" MN_NOENC=1 MN_WATCH=A123
  grep -qF "A123 <- 0C" "$SNAP/s13walk.log" || { echo "s13walk: story 12 not set" >&2; exit 1; }
  # The forge counter is cell $40 at 2,10 (A-list index 0, 1E:72AB). Forge is the
  # 1E:7537 choice (once, then the autopilot's Done); MN_FORGE=2A picks ring $2A in the $8E window, which 1E:75EA
  # wants in $C726 with story $0C before it stores $0D.
  run_leg s13forge 9000 "144:2.11u>6.12" 136 "$S9/to136s13.lua" "$S9/to144s13.lua" \
    MN_NOENC=1 MN_WATCH=A123 MN_PICK='1E:7537!' MN_FORGE=2A
  grep -qF "A123 <- 0D" "$SNAP/s13forge.log" || { echo "s13forge: story 13 not set" >&2; exit 1; }
  echo "story 13 reached"
  # Story 14 ($0E, 1E:55E2). The forge's last line sends Tony to Valkan: with story
  # $0D, 146's entry (1A:773B) runs 1A:78D6, Valkan in slot 2 at 3,8 (1A:79A1).
  # Path back: 136 19,32 -> 135 28,44 -> 138 4,19 -> 280 24,20 -> 145 12,11.
  run_leg s14walk 16000 "136:19.32,135:28.44,138:4.19,280:24.20,145:12.11" \
    146 "$S9/to146s14.lua" "$S9/to136s13.lua" MN_NOENC=1 MN_WATCH=A123
  # Entering 146 runs the Valkan scene on its own (bridge collapse, the Agadon's
  # boots plan, then a script warp 146 -> 134 -> 135 15,0 for the fire
  # distraction). In 135 the carried planter (carry2, 483ba51d) warps Tony to
  # Ashgar's house 141 at 11,14; 1E:61DC on the exit cell 11,15 says "That key
  # must be around here..." and 141's init 1E:623C installs the A list. The
  # second hand-back in 141 (Tony on 11,15, key not taken yet) is the
  # checkpoint: MN_SNAP_TO=c141:2 writes to141s14.lua (map, cell, trigger
  # lists, SRAM), so later legs skip the ~11,000-frame scene.
  run_leg s14scene 12000 "" c141:2 "$S9/to141s14.lua" "$S9/to146s14.lua" \
    MN_NOENC=1 MN_WATCH=A123
  # The key is the $40 cell at 13,9 (A from 13,10 facing up: 1E:620D,
  # "got 0:29", $A1A5 bit 3). Then off and back onto 11,15: 1E:61DC with the
  # key goes 1E:6204 -> 12:7608 (back to 135), which stores story $0E at 1E:55E2.
  run_leg s14exit 4000 "141:13.10u>11.14>11.15" "" "" "$S9/to141s14.lua" \
    MN_NOENC=1 MN_WATCH=A123
  grep -qF "got 0:29" "$SNAP/s14exit.log" || { echo "s14exit: no key (0:29)" >&2; exit 1; }
  grep -qF "A123 <- 0E" "$SNAP/s14exit.log" || { echo "story 14: NOT SET" >&2; exit 1; }
  echo "story 14 reached"
}
# Story 14 -> 15 ($0E -> $0F), from 135 at 28,44 (MN_TO135S14, a control
# checkpoint taken after s14exit). Checkpoints go to $BSNAP/s15
# (MN_S15_DIR overrides). See docs/mn-route12.md, "New-game regression to
# the ferry" and "Story 15".
run_story15() {
  local S15="${MN_S15_DIR:-$BSNAP/s15}"
  mkdir -p "$S15"
  # The road south: 135 -> 138 -> 280 -> 147 ... 156 -> 158, then the door
  # into 159 (1A:460E). A door checkpoint replays the entry, so 159's wild
  # monsters (slots 31/32, beh 1A:4019) exist on load.
  # 156's step trigger 1A:45C5 is a $47 pick (1 in 6 runs 1A:45D9, which
  # leaves for 157). The port's rDIV is love.math.random, so the seed picks
  # the outcome; seed 4 hits 1A:45D9 after the f40dee7c timing merge, seed 5
  # does not (docs/mn-outliers.md, rDIV reads).
  run_leg s15road 14000 \
    "135:28.44,138:4.19,280:29.21,147:far,148:far,149:far,150:far,151:far,152:far,153:far,156:far,158:far" \
    159 "$S15/to159s15.lua" \
    "${MN_TO135S14:-$S15/r15-135.lua}" MN_SEED=5 MN_NOENC=1
  # The 181 ferryman's "Pay 300" (2A:5255) checks $A5A3 >= $012C at 2A:5256.
  # The road has no battles, so 159 is farmed (MN_CHASE_MIN) until 300
  # Animite, then 159 8,49 -> 277 -> 181, pay, ferry 277 -> 184 -> 277 -> 183.
  run_leg s15ferry 60000 \
    "159:chase,277:40.55,181:17.8l" \
    277,c183 "$S15/to277s15.lua,$S15/to183s15.lua" \
    "$S15/to159s15.lua" MN_SEED=4 MN_CHASE_MIN=300 MN_CHASE_THEN=159:8.49 MN_PICK=2A:5255
  grep -qF "enter map 184" "$SNAP/s15ferry.log" || { echo "s15ferry: no ferry" >&2; exit 1; }
  # 183 -> 182 -> 277 58,45 -> 257 -> 255 (talk) -> 241 -> 242 -> 247, then
  # the step trigger 19:6F64 into 249.
  run_leg s15ship 8000 \
    "@182,182:far,277:58.45,257:10.10,255:17.5u>11.6,241:22.31,242:47.7,247:27.49" \
    c182,249 "$S15/to182s15.lua,$S15/to249s15.lua" \
    "$S15/to183s15.lua" MN_SEED=4
  # 249 -> 250: the talks there store story $0F at 19:7838.
  run_leg s15horn 30000 \
    "249:27.3u>27.2|27.3u>27.2|27.3u>27.2,250:10.6u>9.19|9.16d>9.19" \
    "" "" "$S15/to249s15.lua" MN_SEED=4 MN_TALK=1 MN_WATCH=A123
  grep -qF "A123 <- 0F" "$SNAP/s15horn.log" || { echo "story 15: NOT SET" >&2; exit 1; }
  echo "story 15 reached"
}
if [ "${MN_LEGS:-}" = story15 ]; then
  run_story15
  exit 0
fi
if [ "${MN_LEGS:-}" = story10 ]; then
  run_story10
  exit 0
fi
if [ "${MN_LEGS:-}" = story9 ]; then
  [ -n "${MN_TO80S8:-}" ] || { echo "MN_LEGS=story9 needs MN_TO80S8" >&2; exit 1; }
  run_story9
  exit 0
fi
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

# Leg 3. Vash Naroom (43). Entry 1 is Eidon's scene from the stairs; control
# comes back at 8,50 and the route takes over ("@43"). The step trigger at
# 6,38 (16:4026) runs a scene whose $65 hops go 43 -> 2 -> 43 inside the
# script (no door crossing is counted), so control returns at 2,46 on the
# same entry; the route then goes on to the north exit at 9,0 (live list
# 16:4271 entry 1, 16:401D -> map 44). The scene's talk thread needs the $94
# C6F3 latch (FinishStartup's script loop) to run.
run_leg town 8000 \
  "@43,43:9.0" \
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
# Stepping on 0,9 first asks whether Tony has trained enough (talk 13:418C,
# a $9C No / Yes choice); the autopilot's first option is No (13:41CB),
# which loops back, so the leg picks Yes (13:420F). The 43 scene before
# 61 now runs its full text (about 6500 frames), so the leg gets 10000.
MN_PICK=13:420F run_leg train 10000 \
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
# 277 uses per-entry goals: first visit steps on 37,8; the second visit (back
# from 8 after the win) parks at 38,9. Reusing 37,8 would re-fire 2F:4210
# (2F:41F4 still takes the geyser slot while story is 3..5; post-duel is 4).
run_leg korg 20000 \
  "7:far,277:37.8|38.9,8:far" \
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

if [ -n "${MN_TO80S8:-}" ]; then run_story9; fi
