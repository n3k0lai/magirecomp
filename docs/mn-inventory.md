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
| diverges | 1151 | uses a documented divergence: mailbox latching (`$53`-`$62`) or `$16` camera ride |
| missing | 0 | no reachable scene uses `$29` (the only logged-only op) |

Divergent ops: `$58` 713, `$62` 264, `$56` 158, `$60` 132, `$16` 74, rest under 40.
The mailbox latch only changes behaviour if a waiter relies on a post expiring after one
frame; that audit is queued (below), not assumed.

## Transitions

`docs/mn-inventory/transitions.tsv`: every reachable `$65` map load (710).

| type | count | asm path |
|---|---|---|
| startup | 583 | `$93` earlier in the block: LCD-off door, defaults reinstalled |
| live | 123 | no `$93` in the same block: either one in a calling block, or an LCD-on scene change |
| spiral | 4 | `$30` 07:56ED 22x20 spiral wipe (mn.Spiral, `mn_spiral_test`) |

Arrival facing carries through record byte 0 (port keeps `self.facing`); fade timing
for `$93` is the LCD-off path. The 123 `live` rows are the open audit.

## Audit queue (workers, 2026-11-01)

1. Mailbox latch: find any `$5D`-`$62` waiter that depends on a one-frame post.
2. The 123 `live` transitions: trace each to its `$93` or prove LCD-on, check the port path.
3. Camera split: done. ClampMapCamera is `mn.MapCamera`; `$82`/`$84`/`$86` and the `$16` split are in docs/mn-transitions.md. Open items: docs/mn-outliers.md, Camera split (2026-11-01).
4. `$30`/`$6C` fades and palette timing vs 07:56ED and 5C00.
5. Secrets: map-40 data runs, Hyren chains, map 167 (docs/mn-outliers.md).
6. Routed stories (docs/mn-story-graph.md) against the code; rework divergences.

Outliers go to `docs/mn-outliers.md`; nothing is guessed.
