# Magi-Nation inventory: puzzle engines, cutscenes, transitions (2026-11-01)

Static, from the decomp and the ROM's reachable script graph (`tools/mn_inventory.py`,
built on `tools/mn_secrets.py`). No emulation. Tables carry addresses, map ids and
opcode ids only.

## Puzzle engines

All 15 engines in `docs/mn-engines.md` (push $09, kick $0B, talk/use cells, plain cell,
hop, `$01`/`$02` layer walks, step triggers $C0+, grass, `$47` picks, `$80`/`$81` cell
writes, `$1A` cell waits, `$A4` chests, `$87`/`$88` gives, `$11` cave-in scatter,
hidden `$B0` spots) plus the boat (01:60E7/5F25/6405/641D), pixel motion and conveyors
`$A0`-`$A7` are implemented from the asm and **match**, each with a made-up-bytes test
named there. No lever/ice/switch engine exists in the asm: those puzzles are map
scripts, so they are covered by the cutscene/script rows below. Map re-entry resets are
`$93` FinishStartup (docs/mn-transitions.md), ported as the DEFAULTS table.

## Cutscenes

`docs/mn-inventory/cutscenes.tsv`: every reachable script block (entry points overlap,
so one scene can appear under several starts) with camera (`$82 $83 $84 $86`), scripted
motion (`$15 $16 $4C $4D $4F $99 $9B`) or screen effects (`$30 $6C`) and 4+ ops.

| status | blocks | meaning |
|---|---|---|
| matches | 2455 | every op has a decomp-read port handler |
| diverges | 1151 | 2026-11-01 snapshot tag: mailbox ops (`$53`-`$62`) or `$16` camera ride |
| missing | 0 | no reachable scene uses `$29` (the only logged-only op) |

Divergent ops in that snapshot: `$58` 713, `$62` 264, `$56` 158, `$60` 132, `$16` 74, rest under 40.
The mailbox half is closed. `VM:tickThreads` copies each source into its shadow every frame, zeros
included, as `AddAndShiftUnknown` does (docs/mn-parity.md, `mn_mailbox_frame_test`). `$16` is still
a documented divergence. `cutscenes.tsv` was not regenerated; `tools/mn_inventory.py` still lists
the mailbox ops so a re-run reproduces this snapshot.

## Transitions

`docs/mn-inventory/transitions.tsv`: every reachable `$65` map load (710).

| type | count | asm path |
|---|---|---|
| startup | 583 | `$93` earlier in the block: LCD-off door, defaults reinstalled |
| live | 123 | no `$93` in the same block. Classified in `live-transitions.tsv` |
| spiral | 4 | `$30` 07:56ED 22x20 spiral wipe (mn.Spiral, `mn_spiral_test`) |

Arrival facing carries through record byte 0 (port keeps `self.facing`); fade timing
for `$93` is the LCD-off path.

`docs/mn-inventory/live-transitions.tsv` is one row per live `$65` (`lcd`, `via`,
and the `chains()` path). `chains()` splits a root at the `$65`, so an empty
chain is not "no earlier `$93`". The walk that classifies them follows the
decomp's `Script_` labels through `$93`/`$94` and only trusts a target that
lands on an instruction.

| lcd | rows | meaning |
|---|---|---|
| off | 114 | a `$93` runs earlier on every path (LCD still off). `via=fallthrough-93` (105) is the previous instruction; `via=prior-93` (9) is earlier in the script or in the only caller |
| data | 9 | not an executed `$65`: `via=strip` (`1B:4E4E`, `23:6C26`) or `via=not-insn` (operand `16:7CE7`, leftover `1B:6EFD` at `7153`/`715E`/`7862`/`7891`/`7B7C`/`7D64`) |

No executed row loads with the LCD on. `loadArea` now does the `$2F37` clears
and does not snap (test: `mn_load65_test`).

## Audit queue (workers, 2026-11-01)

1. Mailbox latch: done. One-frame copy in `VM:tickThreads`. Proof per site class in docs/mn-parity.md. No reachable post of 0 and no `$60`-`$62` match of 0.
2. The 123 `live` transitions: done. See `live-transitions.tsv` and `mn_load65_test`.
3. Camera split (fix/mn-cam-split): `$84` ClampMapCamera from the asm, rebase on master.
4. `$30`/`$6C` fades and palette timing vs 07:56ED and 5C00.
5. Secrets: map-40 data runs, Hyren chains, map 167 (docs/mn-outliers.md).
6. Routed stories (docs/mn-story-graph.md) against the code; rework divergences.

Outliers go to `docs/mn-outliers.md`; nothing is guessed.
