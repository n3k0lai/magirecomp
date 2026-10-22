# tools/mn_fx: SM83 -> Lua translator for the battle-scene generator

`src/mn/fx/Blocks.lua` holds the Magi Nation routines the battle-scene generator
(`src/mn/fx/Gen.lua`) runs, translated one basic block per Lua function with
per-access cycle timing (PyBoy's, `pyboy_timing.json`). It is code only: blocks
are translated just for the code the generator's runs enter (`executed.txt`),
and graphics, maps and palettes are read from the player's ROM at run time.

Rebuild (needs your own ROM; nothing from it is committed):

    python3 tools/mn_fx/build.py roms/magination.gbc tools/mn_fx/seeds.txt /tmp/full.lua
    luajit  tools/mn_fx/executed.lua roms/magination.gbc /tmp/full.lua tools/mn_fx/executed.txt
    python3 tools/mn_fx/build.py roms/magination.gbc tools/mn_fx/executed.txt src/mn/fx/Blocks.lua --only tools/mn_fx/executed.txt

`seeds.txt` lists routine entry points to start the full translation from.
The test `tests/engine/mn_battle_scenes_test.lua` (with `MN_ROM` set) runs the
generator and checks its scenes.
