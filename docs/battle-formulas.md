# Battle formulas (first battle) — derived from real-game behaviour in PyBoy

Method: forced battle (record `14 76 40 66 0A` written to C706 in an overworld state, after
Pruitt's `$2C 1C 02` gives Tony the Furok); energies read from bank-7 battle records each frame
(Tony species byte D149, Furok D1B7, enemy D293; record = 16-byte command entry + 2 + creature
data). Stats poked into the slot records, then a fixed A-press sequence. Tools:
`out/mn/emu/dmg2.py`, `sweep.py`, `case.py`. States: `g3/s7.state` (Furok's command menu vs Weebo).

## Records (offsets from species byte)
| off | meaning | evidence |
|---|---|---|
| +2 | level | Weebo 01, Furok 02 |
| +6/+7 | energy (LE) | changes with every hit/heal on screen |
| +8 | max energy | Furok 16h=22, HUD "022:022" |
| +9 | strength (Fight damage) | sweep below |
| +0C | defence | sweep below |
| +16.. | 4 move pointers (bank 5) | Furok EE62=Scratch |

## Move/command entries (bank 5, 16 bytes: handler lo/hi, **cost**, flags…, 7-char name)
Scratch `0C 4D 05 …` (handler 4D0C, cost 5 = HUD "Scratch 005"), Heal `E6 4A 03` (cost 3),
Maul 0A, Impale 0A, Flock 23h, Mend 05, Spore 0F, Wreck 14h; commands Fight (517D, cost 0),
Summon, Spell, Item, Run at 05:5EAE–5EEE.
**Byte +2 is energy cost, not power.** Proof: the mysterious constant "3 damage" outcome is Weebo
casting Heal (99→96 on the frame "Weebo uses Heal" appears, then capped back to 99) — `case.py 1`.

## Fight damage (Furok → Weebo, Weebo def 3)
Strength sweep S→damage: 0:1 1:2 2:2 3:3 4:3 5:4 6:4 7:5 8:5 9:6 10:6 11:6 12:7 16:9 17:9 18:10
19:10 20:11 21:11 22:11 23:12 24:12 28:14 32:16; ≥48 wraps (8-bit).
Defence sweep (S=8): def 0–24 → 5, 31–48 → 4, 64 → 3, 96 → 2.
**Model:** `dmg = max(1, floor(S/2) + 1 − floor((Def+1)/32))` — exact for S≤8 and most points;
off by ±1 at S=9, 24, 28, 32 (likely a fractional multiply; not chased further).

## First battle, finished (v13) — what the real game does
Method: natural (unpoked) rounds from `g3/s7.state` / `nat5/tm.state` (Tony's menu with Furok out),
RNG varied by 0..120 idle frames before the round (`out/mn/emu/sweep2.py`, `sweep3.py`; raw results in
`out/mn/emu/{focus,scr2,scratch,str2}.txt`), screenshots read frame by frame. Energies are bank-7
battle records (Tony D149+6, Furok D1B7+6, Weebo D293+6). D0DB.. is a scratch copy of whichever
creature is acting (poking the slot record alone is undone when the round resolves).

**Verified = seen in PyBoy; estimated = rates from the sweeps; guessed = not observed.**

| item | port | status |
|---|---|---|
| Round order | Tony's action first, then Furok and Weebo in random order | verified (T+ always first; F/W order varies) |
| Focus | gain = clamp(rand 0..9, 1, 8) | values verified 1..8; distribution estimated (120 rounds: 1 and 8 each ~20%, 2-7 each ~9%) |
| Furok Fight vs Weebo | 5, or 8 (~44%) | values verified; rate estimated |
| Furok Scratch | costs 5 Furok energy, 6 or 9 (~40%) damage | cost + values verified (40 rounds); rate estimated |
| Weebo Fight vs Furok | 2 (74%), 3 (12%), 4 (15%) | values verified; rates estimated (34 hits) |
| Weebo Fight vs Tony | 2 or 3 | values verified (loss runs) |
| Weebo misses | "Weebo / missed!", no damage, p=0.10 | message verified; rate guessed |
| Weebo Heal | ~50% of its turns, cost 3, then +2..16 capped at max | cost verified; gain range estimated (seen 2,4,6,8 and capped 3/8/14) |
| Weebo target | Furok if Furok was out when the round began, else Tony | verified (summon round: "Weebo fights Tony") |
| Summon | Summon → list "Furok 022" → slot hand → "Furok / was summoned."; takes Tony's action; Furok acts from next round; A does nothing if Tony < 22 | verified |
| Summon refund | when the battle ends with Furok alive, Tony gets Furok's *current* energy + 1 (22→+23, 10→+11), capped at 100; silent, between "Tony gains 2…" and "You got 001 Animite!" | verified (poked Furok to 10 in both slot and scratch copy) |
| Win | Weebo eliminated (sparkle on its card) → "Tony gains 2 / energy for the / defeat." → refund → "You got / 001 Animite!" → "<11>Weebo / found!" → "Tony wins!" → white fade → overworld | verified |
| Furok at 0 | sparkle on Furok's card, "Furok / is eliminated." | verified |
| Loss | checked at round end: Tony 0 with no creature → "Tony was / defeated." → white fade → back on the overworld at the encounter (no game over); Tony stays at 0 | verified with Tony clamped to 0 (natural losses are rare: Focus out-gains Weebo); Tony 0 with Furok alive continues the battle (verified) |
| Run | "Tony escapes." → back to overworld; available in this battle | verified; refund on escape guessed |
| Cursor memory | Tony's and Furok's menus reopen on the last choice | verified for Tony (Focus) |
| Messages | the game's own line breaks (e.g. "Weebo / uses Heal / on itself"), typewriter 1 glyph/2 frames, 3rd line scrolls up | breaks verified; auto-scroll without A guessed |
| Battle intro | none — starts at Tony's menu | not observed (captured states start mid-battle) |
| Damage text | none ("Weebo loses N" was invented in v12, removed) | verified |

Graphics (all from PyBoy frame captures as ROM tile offsets, `src/mn/data_battle_scenes.lua`):
Tony's small sprite (6 OAM tiles), hand cursor (menus, target, summon slot), summon sparkle,
acting-creature brackets, Tony's portrait (5×4 cells, only on "Tony gains…" messages) and Furok's
portrait (4×4, Furok's menu), the three attack animations (Furok→Weebo, Weebo→Furok, Weebo→Tony;
120 frames each, per-line scroll) and the elimination sparkle. Renderer: `src/mn/PpuFrame.lua`,
Python twin `out/mn/emu/ppu.py` (0 px diff on battle-screen frames; ~6% of pixels differ in the jungle
bands of attack animations — a mid-frame effect not captured yet, see below).

Still missing / guessed: Scratch reuses the Fight animation (Scratch anim not captured); Weebo's
Heal has no effect animation; Tony's defeated pose (his sprite changes before "Tony was defeated.");
summon flash is a plain white fade; elimination sparkle on Furok's card reuses Weebo's offset by 48 px;
box open/close slide not reproduced; post-loss recovery point (where Tony's energy is restored) unknown.

## Older notes (v12)
- Summon Furok: Tony −22 (100→78) = Furok max energy.
- Focus: "Tony gains N energy by focusing", N seen 1,1,8,8 → port uses 1.
- Weebo Fight on Furok: 4 (Weebo S=3 predicts 2; port uses the observed 4).
- Weebo Heal: −3 cost, +4, capped at max.
- Turn order: varies between rounds → port: coin flip per round.
- Win: "Tony gains 2 energy for the defeat", "You got 001 Animite!", "Weebo found!", "Tony wins!".
- Scratch damage: not measured; port = Fight + 3 (guess; the "8" outcomes may be 5+Heal-cost).

## Keyboard play check (v13)
`MN_BATTLE_TEST=1` boots straight into the map-3 Weebo battle in normal (non-test) mode;
`MN_KEYS="w30,z,w20,down,..."` pushes `keypressed`/`keyreleased` events through `love.event`, so the
same handlers as a real keyboard run (Z/Enter = A, X/Backspace = B, arrows). Scripts were built by
`out/mn/v13/drive_keys.py` (replays a fixed `MN_SEED` and reacts to the battle log) and replayed by
`out/mn/v13/replay.sh`; logs `out/mn/v13/keys_{fight,scratch,run,loss}.log` all end in `battle end`
(win / win via Scratch / run / loss with `MN_TONY_START=1`, seed 6). Not a human play session.

## Dev mode: `MN_GOD=1` (testing only)
Off unless `MN_GOD=1` is set. When it is on, the summoned Furok gets 999:999 energy and every
Furok Fight/Scratch takes the target's full energy, so the fight ends in one hit. Action costs
(summoning, Scratch, and spells once they go through `Battle:spend`) are never paid, so Tony's energy
never runs out from attacking. A GOD fight does not write Tony's energy back to the field, and
nothing goes to SRAM (field energy only lives in dev snapshots). A red "GOD" tag sits in the top-right corner of the field and battle
screens while it is on. Its only use is getting through Glade encounters fast when testing story
beats; it is not a gameplay option.
