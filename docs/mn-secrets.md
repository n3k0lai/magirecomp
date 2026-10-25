# Magi-Nation optional content (secrets)

Optional areas, rare creatures, hidden items and optional duels that the
main route passes but does not take. One row per find: place name, how it
is gated, where the decomp handles it, and whether the port supports it.
Everything is paraphrased; no game text is reproduced here.

Status words: **yes** (works in the port), **partial**, **no**, **?** (not
tested yet).

## Hyrens (the "Hydras")

Hyrens are rare optional creatures found in hidden areas. The decomp has
hint lines about them; the encounter scripts themselves are not pinned
down yet.

| Place | What | Gate | Decomp | Port |
|---|---|---|---|---|
| Naroom, tunnel from the Weave toward the Underneath | Naroom Hyren area: first fork, dig spot, stairs down, a cracked wall that needs a Blast Urn | dig skill, Blast Urn | encounter script not found yet | ? (cracked-wall Blast Urn use untested) |
| Cald, lava tube north of Valkan's house | Cald Hyren: a white whirlpool shows up in the low blue area | unknown | encounter script not found yet | ? |
| (hint NPC) | someone spots a Flame Hyren | none | script 1E:48EA | ? |
| (hint NPC) | someone brags about a big Thunder Hyren | none | script 1B:4631 | ? |
| (hint NPC) | says greater Hyrens live only in hidden areas | none | script 25:6946 | ? |
| (item text) | Hyren's Claw, a Strength-raising item | unknown | script 2E:4E7B | ? |

Places come from public guides; the map numbers still need to be matched
to the decomp map tables.

## Passed on the main route

| Place | What | Gate | Decomp | Port |
|---|---|---|---|---|
| Tunnels north of the Underneath town (map 105), top of the cave at 15,3 | hidden spot on a `$B0` cell under the rock face; map-entry fallback script 19:4BE0 checks for action `$2A` on that cell, then sets `$A1AE` bit 6 and runs 19:4BFF (gives something and opens 15,2, the way up into map 106 and on to 107) | unknown action/item `$2A` | 19:4BE0, 19:4BFF, replay 19:4C7F | ? (pressing A there does nothing in the port) |
| Tunnel cave between the Underneath map and the rock-trap cave (map 108), 16,19 | another lone `$B0` cell, likely the same kind of hidden spot | ? | not traced | ? |
| Cave east of map 103 (map 101) | lone `$B0` cell | ? | not traced | ? |

## Todo

- Find the Hyren encounter scripts (battle setup with the Hyren creature
  ids) and the maps that own them.
- Add a row each time a route leg passes an optional room, chest or duel.
