#!/bin/sh
# Replay every recorded oracle trace under $TRACES through the Lua engine.
#   ROM=path/to/magination.gbc TRACES=path/to/emu sh tools/mn_battle/audit/replay_all.sh
set -e
cd "$(dirname "$0")/../../.."
: "${ROM:?set ROM}" "${TRACES:?set TRACES}"
T=$(find "$TRACES" -name '*.json' | sort | xargs grep -l '"rounds": \[{')
luajit tools/mn_battle/replay.lua --rom "$ROM" "$@" $T
