# Magi-Nation port: enhancement backlog

Optional, **non-canon** features for the Magi-Nation (GBC) port. Each one is
off by default. None of them changes the original game's behaviour unless the
player turns it on. Addresses are bank:CPU address, the same as the rest of the
`mn-*` docs. This file describes ROM structures. It does not reproduce ROM
data.

---

## 1. Shadow creatures and Hyrens on the player side

### Question

Can the player get Shadow (Core-region) creatures or Hyrens? If not, could
the port add them?

### Short answer

The original game already lets you get them. Shadow creatures and Hyrens go
through the same ring forge as every other creature, and nothing in the
code checks a creature's region or class. They are hard to reach, though:

- you need that creature's own infused animite, which only drops from
  beating that creature in battle;
- you have to be at the right regional forge;
- their forge entries carry a much higher requirement byte (see below).

In the port today none of this can happen. The forge UI and the
post-battle animite drop are not ported yet (see `recomp-coverage`:
shops/Forge/Equip/Power are missing). So the first job is canonical port
work. The non-canon toggles listed below are optional extras on top.

### How the player gets creatures (original game)

1. **Battle win: animite and a creature drop.** Every enemy creature you
   defeat adds its reward to the battle animite byte (`$D06C`). It also
   records its species id in an 8-slot list at `$D0B8`.
   - At the end of a won battle, `ApplyHalfD06CThenMaybeScan` (5:42F6)
     adds `$D06C/2 + 1` to the animite currency word (SRAM `$A3A5`,
     capped at 999).
   - It then makes two random rolls from the divider. The first passes
     about half the time, the second about 5 times in 16. Each roll that
     passes calls `PickD0B8EntryOrFF` (5:5762), which picks one of the
     species you defeated. `CopyNameAndAddScanC` then adds 1 to that
     species' **infused animite** count (SRAM `$A4A6 + species id`). The
     "got X" text is bank $4C `$43F9`.
   - Neither step looks at region, element mask or class. A Shadow
     creature or Hyren you defeat can drop its infused animite like any
     other creature.
2. **Ring forge: making a creature ring.**
   - Opcode `$8E` (`CallBank4_5494ThenEnterScript`) carries a
     length-prefixed recipe block in the script. `CopyPrefixedBlockToD000`
     (`$1EF5`) copies it to WRAM6 `$D000`. `StageCopiedBlockWindow`
     (4:5926) opens the Forge window.
   - `LoadWram6ChoiceRows` (4:5F1A) pages 8-byte rows into `$CD22`.
     `StampWindowChoiceMarks` (4:569E) draws them.
   - `TryAffordOtherChoice` (4:5A5B) checks the costs, and
     `CommitOtherChoiceFive` (4:5CB3) pays them. If you're short, you get
     `ShowUnaffordableChoice` (4:5DF5); the prompt is `ShallIMakeRingText`
     (3:481A).
   - Row layout (inferred from the code plus the block shape):

     | byte | meaning |
     |---|---|
     | 0 | creature id (the ring made) |
     | 1–2 | infused animite id and count; the id is always the creature itself |
     | 3–4 | optional second infused animite id and count; `$FF` means none |
     | 5–6 | animite currency cost (word) |
     | 7 | unknown requirement. Low for starter creatures, much higher for Hyrens and late Shadow creatures. Most likely a level gate; the INCBIN half of the forge path still needs confirming. |

3. **Script gifts.** Opcode `$87` (`CopyThreeBytesCallBank7`, table
   7:5D7F) gives items, spells and animite currency. None of the gifts we
   traced so far gives a creature ring directly.
4. **Power.** The `$8F` list (`SpendSramListChoice` 3:729A,
   `CommitBoughtSramRecord` 3:731C) spends infused animite on creatures
   you already own. It isn't a way to get new creatures.

### Forge rosters (seven `$8E` blocks found by a structural scan)

| bank | region (by roster) | Hyrens offered | Shadow creatures |
|---|---|---|---|
| $14 | Naroom | Leaf, Timber | none |
| $15 | Underneath | Mush, Cave (plus Ormagon) | none |
| $18, $1B | Orothe (two copies of one list) | Coral, Deep | none |
| $1A | Arderial | Bolt, Thunder | none |
| $1E | Cald | Magma, Flame | none |
| $25 | Core | Core Hyren | all 21 Shadow-mask species (Core Hyren included) |

So every Hyren and every Shadow creature has a forge entry. No region or
type filter exists anywhere. In practice the limits are reaching the Core
forge, actually finding and beating these creatures, and the byte-7
requirement. Hyrens only show up in hidden areas: see `mn-secrets.md`.
Their encounter scripts still haven't been found.

### Data feasibility

All 86 creatures have full data:

- a species record (bank 4 `$415B`, stride `$2D`): stats, four move
  pointers, glyph pointer;
- a name (bank 6 `$5AA6`);
- an infused-animite slot at `$A4A6`.

Nothing is missing for a player-side version: no ring item id is absent, and
no special deck-slot case is needed. Rings are just species ids, and party
slots (`$A025 + k*$25`) take any id.

### What the port needs first (canonical, not a toggle)

- Forge window for `$8E`: parse the block and add Forge/Equip/Power to the
  shop strip. Today the autopilot just takes the exit.
- The end-of-battle reward: the half-`$D06C` currency add and the two
  infused-animite rolls over `$D0B8`. `battle/Engine.lua` already fills
  `$D06C` and `$D0B8` but never commits the drop to `$A4A6`.
- The meaning of byte 7, confirmed against the INCBIN forge code.

### Proposed optional toggles (non-canon, default off)

Grouped under `mn.enhancements`. Each entry is labelled "non-canon" in any
menu that shows it.

| key | effect |
|---|---|
| `shadow_hyren_forge_everywhere` | Each regional forge also offers the Core-forge Shadow rows and every Hyren row. The original row data is reused as-is, so costs stay canon. |
| `relaxed_rare_requirements` | Skips the byte-7 check for Hyrens and Shadow creatures only. |
| `guaranteed_rare_drop` | Beating a Hyren or Shadow creature always adds one infused animite of that species, instead of the 50% / 31% rolls. |

Implementation sketch:

- **New** `src/mn/Enhancements.lua`. It holds the defaults (all false),
  reads the save-side settings, and accepts `MN_ENH=key1,key2` for
  harness runs.
- `src/mn/ui/` gets a new Forge window module (needed anyway for canon).
  When `shadow_hyren_forge_everywhere` is on, it appends extra rows from a
  table built at boot by scanning the seven `$8E` blocks. That reuses ROM
  data at runtime and ships nothing.
- `src/mn/battle/Engine.lua`: the reward commit honours
  `guaranteed_rare_drop`. Shadow species are found by their element mask
  in the species record, and Hyrens by name/class.
- `src/mn/ScriptVM.lua`: wire the `$8E` handler to the Forge window.
- Settings UI: one "Enhancements (non-canon)" page. Saves record which
  toggles were on.

**Effort.** The canonical forge plus the battle reward is about 2–3 days,
including harness checks against PyBoy. The three toggles add about half a
day on top. Everything touches `src/mn/*`, so schedule it after the current
route work in that tree lands.
