# Magi-Nation battle tables (located for the battle-system port)

## Move / command table — bank 5 `$5EAE..$651E`
103 records, 16 bytes each (record ptr = `$5EAE + 16*i`):

| off | field |
|---|---|
| +0..1 | handler pointer (LE, bank 5); all 103 distinct |
| +2 | energy cost |
| +3 | target code (`$14`+ = group target) |
| +4 | menu flags |
| +5 | kind |
| +6 | element |
| +7 | power |
| +8 | accuracy |
| +10..15 | 6-char name |

The first 7 are Tony / generic commands: FIGHT `$5EAE`, SUMMON `$5EBE`, SUMMONX `$5ECE`,
ITEM `$5EDE`, RUN `$5EEE`, SPELL `$5EFE`, FOCUS `$5F0E`.

Species move lists: creature entries at bank 4 `$415B`, entry bytes 18..25 = four LE
pointers into the table above; per-slot unlock flags at battle record `+$20..+$23`.

## Spells and items — bank 7, `$22`-byte group records
- items: `$5E21..$6195`, ptr = `$5DFF + id*$22`
- spells: `$7017..$727B`, ptr = `$6FF5 + id*$22`
- copied to `$CD91`; `+2` amount, `+3` stat index, `+4` cost, `+5` target,
  `+$0C` 13-byte name (leading icon glyph), `+$19..$1B` message script (bank `$4C`),
  `+$1F..$21` animation.
- save data (SRAM bank `C727+0`): spells known `A5A5+id` (value = cost), item counts `A3A7+id`.

## Battle records
WRAM `D147 + slot*$37`: slot 0 Tony, 1–4 player creatures, 5–8 enemy creatures, 9 Magi.
SRAM party: Tony `$A000` (`$25` bytes), creatures `$A025 + k*$25`.
