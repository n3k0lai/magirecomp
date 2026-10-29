# Door pair, slot-0 cell and the saved pair (WRAM model)

The port keeps exactly the WRAM the original keeps. There is one player cell and
one door pair; there is no "template" position and no wall test.

## The fields

| WRAM | what it is |
|---|---|
| `$C18E/$C18F` | slot 0's record cell. The slot record table at ROM0 `$0303` starts at `$C189` (stride `$1B`), and FillScriptRecord0808 writes a record's cell at +5/+6, so slot 0 +5/+6 **is** `$C18E/$C18F`: the player's map cell. |
| `$C9A1/$C9A2` | wScriptPair, the door pair (column, row). |
| `$A015/$A016` | sSavedScriptPair (SRAM), the pair saved by `$96`. |
| `$C186/$C187` | a record head word (Opcode10), read by run_head_word_script and run_two_scripts_then_replace_head_word. Not a position. |

The earlier notes described a "two-position model" (a `$05` template cell plus a
pending pair, with a wall rule picking one). That was wrong: slot 0's `$05` and
`$00` write the same field.

## Every literal reader and writer (ROM-wide scan of the asm)

Writers of `$C9A1/$C9A2`:

- Opcode01: pair := b1, b2.
- Opcode02: pair := `$C18E - b1 + b2`, `$C18F - b3 + b4` (8-bit wrap).
- Opcode25 (battle setup): pair := `$C18E/$C18F`.
- LoadSRAMScriptAndDispatch: pair := sSavedScriptPair.

Readers of `$C9A1/$C9A2`: only Opcode00 (bank 1 `$4423`).

Writers of `$C18E/$C18F`:

- Opcode00 (bank 1 `$4423`): `$C18E/$C18F` := pair, then wBank5Ptr :=
  `$D000 + row * stride + col` and `$FF` into `$C6DE`. It runs unconditionally,
  whatever the cell holds, and it never clears the pair.
- Opcode05 with slot 0 (FillScriptRecord0808 through the `$0303` record pointer).

Readers of `$C18E/$C18F`: Opcode02, Opcode25, CenterFineScrollOnScriptBase (`$82`),
StageSavedScriptPair (`$92`), SaveScriptTriple (`$96`, which writes the cell to
sSavedScriptPair and then jumps to INITIAL_SCRIPT_HANDLER),
plant_tail_script_head_when_cell_matches and plant_bank22_script_on_zero_byte.

## How doors come out of this

A door script is `$01` or `$02` (sets the pair) followed by `$45` into the map's
entry script. The entry fills slot 0 with `$05` (the cell is now the template),
loads the map with `$65`, and an entry that ends with `$00` moves the player to
the pair. An entry with no `$00` keeps the `$05` cell. So:

- Ringsmith (map 59) entry has no `$00`: the player is always on the `$05` cell.
- Map 15's entry (reached from the 26 door, `$02` then `$45`) has `$05` and later
  `$00`: the player lands on the rebased pair (10,27 from 9,0).
- Map 182 story `$0F`: `$05` places the stand-in, `$00` copies the pair (29,11)
  and the stand-in moves with it once.
- A later `$00` with no new `$01/$02` reuses the stale pair; nothing clears it.

## Port

`src/mn/ScriptVM.lua` writes `$C9A1/$C9A2`, `$C18E/$C18F` and `$A015/$A016` in
the opcodes above; `VM:playerCell()` reads the host's live cell (else `$C18E`).
The guessed rules (pairNeedsMap, pairWall, template wins on a wall, the `$82`
pending pair) are gone.

Checks: `tests/engine/mn_pair_wram_test.lua` (made-up bytes: ringsmith and 182
shapes, stale pair, `$25`, `$02` from the `$05` cell),
`tests/engine/mn_door_rebase_test.lua`, `tests/engine/mn_standin_pair_test.lua`.
