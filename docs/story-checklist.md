# Magi-Nation story checklist (paraphrased from a GameFAQs walkthrough)

Source: GameFAQs FAQ #12490 (local copy policy: docs/ref/, gitignored; the
page 403'd to curl and was read once via the fetch tool, not stored verbatim).
Order of beats, our map ids where known, and port status.

| # | Beat | Maps | Port |
|---|------|------|------|
| 1 | New game, Tavel Gorge, kids dare Tony into the cave | 216, 219 | yes |
| 2 | Cave maze to the crystal; cave-in, Tony trapped | 220-222 | yes: route leg 2 reaches the crystal talk 1F:5D95 and runs 1F:5EAE |
| 3 | Fall to the Moonlands: Furoks find Tony at a river | 40 | yes: route enters map 40 (2A:4774); the river leg finishes the scene in 12000 frames |
| 4 | Korg, Zet and Eidon scene; translation ring | 40 | yes: route12 river leg leaves through the west exit (snapshot after40.lua) |
| 5 | Follow Eidon up and left along the river to the stairs | 40 (west exit 0,10) -> 0 -> 1 -> 277 -> 1 -> 277 -> 2 (stairs; Korg/Zet line) | yes (auto-route, this round) |
| 6 | Vash Naroom: climb to the town square, meet Orwin with Eidon | 43 (town), houses 44, 47, 55, 58; also seen in PyBoy: 48, 51, 65, 67 ; Orwin's house 63 via 43 -> 44 -> 51 -> 53 -> 54 -> 63 (entry 23:7358) | yes (route_cur.txt) |
| 7 | Ringsmith forges a first Furok ring free | 59 (from 48 door at 12,2; counter cell $40 at 10,9 -> 14:700F -> 14:71DB) | yes: ring, 50 Animite, Evu hint |
| 8 | Save/rest house gives Jelly Beans; Remedy Drink at a fireplace | 55 (inn: Poad, jellybeans, $9C Yes/No save, get-up rendezvous ends Tony at 16,5), 60 (fireplace: Remedy Drink, item 0:13) | yes: e2e text matches PyBoy gt/b8_evu1, b8_poad2, b8_inn_save |
| 9 | Trade Jelly Beans to the historian for info and a spell | 60 (historian Evu; spell 3:1 Leaf Cut) | yes: e2e matches gt/b9_evu2 except a PyBoy-only bush search off the route |
| 10 | Eidon takes Tony out to train with Yaki | 43 -> 61 (training grounds, 13:57E6; Eldritch Awl 0:45; control at 10,9) | yes: e2e matches gt/b10_train (20/20 lines) |
| 11 | Earthquake; go east to the Glade (first wild Dream Creature battles) | 61 (leave west at 0,9: Eidon's No/Yes, quake 13:5D5F sets A123=3, Yaki 13:5DBF) -> 2 (14:50BA quake scene: Orwin/Eidon/townsman, control 12,8) -> 277 (37,13) -> Glade 3 -> 4 -> 5 (6 is a side clearing; 7 exits north) | yes: e2e text matches gt/b11_quake (9/9), b11_after (8/8); wild Weebo fights run with MN_GOD; Yaki's optional tutorial (gt/b11_yaki) not routed |
| 12 | End of the Glade path: Korg/Zet return, Orwin vanishes, Korg duel | 7 -> 277 (step-on record at 37,8, 2F:4210) -> 8 (Shadow Geyser 14:6A95; duel 14:4174, win tail 14:6B30: Orwin, Energy Band; control 8,8) | yes: text matches gt/b12_scene (16/16) and gt/b12_duel (20/20); the duel itself still uses the stub battle (Korg's creature shows as Weebo), won with MN_GOD |
| 13 | Orwin's bracelet (kick blocks), Seer, Cloud Frond quest, Weave, Gia, Core Glyph | | no |
| 14 | Shadow Geyser 1, Core Keeper Togoth | | no |

Dream creatures early on: Furok (first ring); Glade wild: Weebo, Furok, Twee,
Bhatar, Plith. Items: crystal, translation ring, Furok ring, Jelly Beans,
Remedy Drink.

Dev mode for battle testing: `MN_GOD=1` (see docs/battle-formulas.md). Never on by default.

Story word 8 -> 9 (after the Underneath town arrival): the store is
15:4CCB, reached by stepping on world-map 279 cell 34,21 (2F:44DE). The
walk there is in scripts/mn-route12.sh (MN_TO80S8) and stores story 9.
The sprite 2F:453E puts on the cell does not block it (a record only marks
a $00 cell solid). Next: the map-122 scene, see docs/mn-route12.md.
