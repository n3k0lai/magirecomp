# Magi-Nation SRAM save

One save. The cartridge RAM is four banks of 8 KiB. Banks 0 and 1 are one copy of the save; banks 2 and 3 are the other copy. There is no second player slot. The file in the LÖVE save directory, `mn_save/slot1.sav`, is those four banks packed in order (bank 0 first), 32768 bytes, with no extra header.

The active bank number is 0 or 2 and is stored at `$A000` of bank 0. On a load the engine checks that flag and the stamp, then copies the pair the flag names onto the other pair. After that copy the active bank is the pair that was just written. A flag other than 0 or 2 is rejected.

The stamp is sixteen bytes. They must sit at `$A002` of bank 0, and the same bytes reversed must sit at `$BFF0`. The game compares them to the sixteen bytes at `$4000` in ROM bank 7, which is the bank mapped when the title screen's Continue runs the check. A mismatch rejects the file. The game itself would wipe SRAM; this port leaves the file untouched and starts a new game.

Continue is that check followed by the saved script. `$A012` is the script bank. `$A013`–`$A014` are a little-endian pointer. A zero pointer does not resume. `$A015`–`$A016` are the player cell, restored before the script runs. The title screen reaches this through the script opcode that calls the bank-7 check and then dispatches that pointer.

The game writes the save from a script, not from a separate menu. One opcode stores the resume script (bank and pointer). The save opcode then stores the player cell, optionally copies a map word in the next SRAM bank, mirrors the two pairs, and this port writes the file. A fresh game has no file. `MN_NEWGAME=1` ignores a file that is present. Tests can pass `MN_SAVE_LOAD=<file>` on the headless `--mn-test` path to resume from a file instead of the map-entry script.
