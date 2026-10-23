# Title boot

Reset (`src/reset.asm`) fills WRAM, runs SetupDefaultState (`src/default_state.asm`), checks the cartridge RAM (`src/check_save_signature.asm`), and plants script bank `$22` pointer `$418E` with handler `$0A66`. It then jumps to FinishStartup (`src/finish_startup.asm`, called ContinueStartup from reset). That runs the script.

`22:418E` (`src/evscripts/bank22/414C.asm`) is one lookup into `2A:7247` (`$86`, `src/seed_camera_loop.asm`). The bytes after it are the attract slideshow (`src/evscripts/bank2A/7248.asm`). `2A:734B` polls Start: `$C932` bit 3, the new-press mask from `src/read_joypad.asm`. A set bit goes to `2A:735B`, which fades and loads map 216, then `2A:7368` stores `$CCA6` = 1 and tests `$A017`. Zero takes `2A:73D8` (new game). Nonzero is the continue side of that same script (sound slot, staged copy). The warning text at `2A:6D44` sits on the bank-21 list `$5051` installed as the map's trigger list; it is not dispatched at boot.

## What boots the title

The keyboard boot (no `MN_NEWGAME`, no `--mn-test`, no `MN_LOAD`, no `MN_BATTLE_TEST`) calls `Title.start(ow, data)`.

- `data` is the raw `mn_save/slot1.sav` (32768 bytes, four SRAM banks) or nil. `MN_SAVE_LOAD` names another file and is preferred when set. `MN_NEWGAME=1` passes nil.
- A file that passes the stamp check is installed into the VM and not resumed. The saved script at `$A012` stays for the title script.
- A missing or rejected file leaves SRAM unread, so `$A017` is 0.

`MN_NEWGAME=1` without `MN_TITLE` is unchanged: Continue is called and returns without starting a script. `--mn-test` without `MN_TITLE` is unchanged. `MN_TITLE=1` runs this same title boot under `--mn-test` (and on the keyboard path). `MN_LOAD` and `MN_BATTLE_TEST` still win.

## Bytes

`Title.applyDefaults` writes the reset block the script can observe: `$C6DE` = `$FF`, callback `$C6E4` = `$29A4`, vblank `$C6E2` = `$2A49`, STAT `$FF99` = `$2AB7`, `$C9FF` = `22 06 40`, `$C6EF` = 3, `$FFAA`/`$FFAB` = 3, `$CCA5`/`$CCA6`/`$C6F3` = 0, and `00 00 02 14` at `$C70E`, `$C715`, and `$C71C`. `$C932` is cleared with the other joypad bytes; while the main script sits on `2A:734B`, a read of `$C932` is Start's new-press bit (bit 3) and a miss waits one frame.

The script, not the boot helper, writes `$CCA6` = 1 and reads `$A017`. Continue's install copies the active SRAM bank, including `$A012`–`$A017`, and does not write them itself.

## Still open

The slideshow pictures are `host.picture` (another job). Until that lands the attract frames are the map under the script.
