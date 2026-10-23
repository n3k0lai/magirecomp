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
| `ScriptVM` `$1F` | `$C920`, `$C91E`, `$C92A = 0`, `$C92C = $0F` (also `h.music`) | `request("active", id)` and `h.sfxSelect(0, 0, 0, 0x0F)` |
| `ListChoice.commitCopied` | `$C91F = 1` on a buy, index, `$C92A = 0`, `$C92C = $0F` | `h.sfx(1)`, `request("active", id)`, `h.sfxSelect(0, 0, 0, 0x0F)` |
| `ListChoice.deny` | `$C921 = 2` | `h.sfxSlot(1, 2)` |
| `ui/start/Machine.lua` `openBytes` and `leave` | `$C92C`, `$C928 = 0`, `$C929 = 0`, `$C92A = 4` | `h.sfxSelect(4, 0, 0, c92c)` |
| `ui/start/Commit.lua` save tail | same mix restore, `$C92C = $0F` | `h.sfxSelect(4, 0, 0, 0x0F)` |

Music notes and SFX share channels in the ROM driver. This module does
not drive `MnMusic`, so a slot does not steal a song channel. `sfx:routed()`
is the current `NR51` byte if the mix should duck those channels.
`InstallSoundIndex` records the song pointer, but the countdown reader at
`$3D4A` is still unlifted, so songs do not advance here.
