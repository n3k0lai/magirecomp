# Sound effects

`src/mn/Sfx.lua` is the SFX half of the bank $30 driver. It does not call
`love.audio`. Playback stays with the host.

Songs stay on `MnMusic`. That renderer reads the same stream command set
as instrument programs and mixes a finished buffer. It is not an APU, so
SFX keeps its own register model. Duty widths, the pulse and wave clocks,
and the noise shift register are the same formulas `MnMusic.renderGB` uses.

## Clock

`RunDefaultVBlank` runs the command at `wSoundCommand` when bit 2 of the
vblank flags is set, then `UpdateSound`. `finish_frame` stores flags `$07`
and calls `SelectSoundCommand` first, so a playing game steps the driver
once per vblank (about 59.73 Hz). The timer interrupt is masked on the
LCD-on path. `StartSoundTimer` can enable it; `render` then also runs
`TimerOverflow` at the timer rate.

`sfx:step()` is one vblank slice. `sfx:select()` is `SelectSoundCommand`.
`sfx:render(n)` does both, at 44100 Hz, and returns `n` mono samples.

## Requests

| call | WRAM | command |
|---|---|---|
| `request("slotA", id)` | `$C921` | `SoundSlotA` → `OpenSlotChannel` |
| `request("slotB", id)` | `$C922` | `SoundSlotB` (same opener) |
| `request("request", 1 or 2 or 4)` | `$C91F` | bit 1 drops the music gate; bit 2 latches it; any other nonzero value takes the bit-1 command |
| `request("active", index)` | `$C920`, `$C91E` | `SoundActive` → `InstallSoundIndex` |
| `request("select", bits)` | `$C92A` | fade commands in `sound_select_*.asm` |

Slot ids are the 4-byte records `OpenSlotChannel` indexes (count byte at
`$5A7D`). The record's tag is a `SoundStreamTable` index (`$5A88`). A
stream that starts with `snd_skip` uses that byte as the channel and the
following bytes as the program. `RunSoundStream` stops on a zero cursor
(`snd_end` / `snd_release`). `snd_wait` is the only command that ends a
tick early. `snd_loop` with count 0 repeats forever (`SfxStream03`,
`SfxStream21`).

## Playback

`src/mn/SfxOut.lua` owns one `Sfx`. The field builds it in `Overworld.new`
(same ROM as the script VM; bank `$30` is inside `scripts.bin`) and
`Sfx.host(ow, h)` from `Overworld:host`, so `ow.sfx` is `ow.sfxOut.sfx`.
`Overworld:update` calls `sfxOut:update(1/60)` once. That renders the
samples due at 44100 Hz and queues one mono 16-bit buffer on a
`QueueableSource` with four slots. Do not also call `step`.

Muted, and it never creates a source or calls `play`, when
`SDL_AUDIODRIVER` is `dummy`, or `MN_NOMUSIC` or `MN_MUTE` is set, or
`love.audio` / `love.sound` cannot build the queue. The driver still
renders, so a request is consumed on the same vblank it would be with a
device. `mn-headless` is always muted.

## What Ene wires

`Sfx.host` sets `h.sfx`, `h.sfxSlot`, `h.sfxRequest`, and `h.sfxSelect`.
`h.sfxSelect(sel, c928, c929, c92c)` writes `$C928`, `$C929`, `$C92C`,
then `request("select", sel)` for `$C92A`. The driver does not share the
VM's memory, so a bare `vm:wr8` does not reach it.

Opcodes `$1B`, `$1C`, `$1D`, `$1E`, `$21`, `$22`, and `$23` already copy
into the driver. These still write the VM only:

| site | bytes | hook |
|---|---|---|
| `ScriptVM` `$1F` | `$C920` / `$C91E` when the index changes, then `$C92A = 0`, `$C92C = $0F` (also `h.music`). It does not touch `$C928` / `$C929` | `request("active", id)` on change, then `sfx:wr` of `$C92A` and `$C92C` only |
| `ListChoice.commitCopied` | `$C91F = 1` on a buy, index, `$C92A = 0`, `$C92C = $0F` | `h.sfx(1)`, `request("active", id)`, then the same two `sfx:wr`s |
| `ListChoice.deny` | `$C921 = 2` | `h.sfxSlot(1, 2)` |
| `ui/start/Machine.lua` `openBytes` and `leave` | `$C92C`, `$C928 = 0`, `$C929 = 0`, `$C92A = 4` | `h.sfxSelect(4, 0, 0, c92c)` |
| `ui/start/Commit.lua` save tail | same mix restore, `$C92C = $0F` | `h.sfxSelect(4, 0, 0, 0x0F)` |

Music notes and SFX share channels in the ROM driver. This module does
not drive `MnMusic`, so a slot does not steal a song channel. `sfx:routed()`
is the current `NR51` byte if the mix should duck those channels.
`InstallSoundIndex` fills the step (`$577F`) and seeds the countdowns
(`$3D65`), and `D.update` ends with `StepSoundCountdowns` (`$57FC`) as
update_sound.asm does, so an installed song advances: the upper countdowns
(`$58AF`), the lower ones (`$5921`, `$596A`) and the lower expiry (`$599D`,
which reads the song stream through `$3E3A`/`$3E78`/`$3ED4`/`$3F0E`/`$3FB0`
and opens a channel through `OpenChannelForTag`). A `$20` sound therefore
holds `$C924` until its song ends, and `SoundCountdownIdle` (`$074F`) then
restores the saved driver state (tests/engine/mn_music_seq_test.lua).

Lengths from the ROM, counted with `Sfx` from the `$20` frame to the frame
`$C924` reads 0: index 00 580 frames, 01 63, 02 117, 03 185, 04 7928,
05 13006, 06 7245. Indices 07-28 (41 songs) loop ($FE) and never end, as
in the asm, so a `$20` on one holds `$C924` set.

Which `$20` indices the scripts use (static, from the decomp's evscripts
walk of 5179 streams plus the leftover files): one `SC_ArmCountdown`, in
bank `$21` at `$78EB`, with an index past the 41-song limit. That stream is marked unused (only
the unused-script list reaches it; no lifted reader runs it), and that index
installs nothing and `$074F` restores on the
next frame. One more `$20` byte sits in the bank-`$1B` leftover bytes at
`$7F29`, which nothing reads. So no reached script plays a `$20` song, and
none lands on a looping one. The walk is static (streams found by the ok
walks); a `$20` reached only through a computed jump would not show.
`SC_ArmCountdown1AE8AndDecFFA6` is a different opcode.

The field song pauses for a `$20` song. `$072D` drops the gate, saves
`$DFA6`-`$DFF7` and installs the song; `$074F` copies the bytes back when it
ends, so the field song carries on where it stopped. The port's field song
is `MnMusic`, so the driver sets `songHold` at `$072D` and clears it at the
`$074F` restore, and `Overworld:musicHoldFrame` pauses `MnMusic` for that
span and resumes it after (log lines `music held ($20 song)` and
`music resumed`; tests/engine/mn_music_seq_test.lua checks the frames, muted).

Limits:
- `D.SEQ_GUARD` (4096) caps the per-frame refill loops in `$596A`, `$5921`
  and `$57FC`. The asm has no cap; a hit counts in `s.seqGuardHits` and the
  first logs an outlier. None of the ROM songs above hits it.
- `ScaleCountdownStep` (`$576B`) has no driver caller found, so it is not
  lifted.
- `ScriptVM` `$1F` still plays field music through `MnMusic`, not this
  driver. A `$1F` during a `$20` song installs the field song over it in the
  asm (`$0670`), and `$C924` then stays 1. Here the new `MnMusic` song plays
  at once (`musicHeld = "replaced"`, not paused again), and the driver still
  restores its saved bytes when the `$20` song ends. No reached script does
  this (see the `$20` list above). Not checked by ear (no audio is played on
  the build machine).

Opcode `$26` (sound_command_trigger_tag.asm) passes its first operand as the
channel hint C on both paths, and D is `$DFE4 + slot`. With bit 1 of
`$DF09 + slot` set it goes through `$4F15` (B = the slot's priority, D = 1)
and runs the same prime stores as `$4F1A` before setting bit 1 on the
channel it opened (tests/engine/mn_sfx_trigger_tag_test.lua). No ROM stream
runs `$26` in a probe of slot A, slot B and request ids 0-255 and songs
0-40 (counts only).
