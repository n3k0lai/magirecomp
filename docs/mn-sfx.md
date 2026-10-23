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

## What Ene wires

`Sfx.host(ow, h)` sets `h.sfx`, `h.sfxSlot`, and `h.sfxRequest`. The
overworld needs `ow.vm.rom` or `ow.rom`. Each audio callback should call
`ow.sfx:render(n)` and queue the samples. Do not also call `step`.

`ScriptVM` already calls `h.sfxSlot` for opcodes `$1B` and `$1C`, and
`h.sfx(2)` for `$1D`. `$1E` (`wSoundRequest = 4`) and `$21`
(`wSoundRequest = 1`) only write the VM's own RAM. Point those at
`h.sfx(4)` and `h.sfx(1)`. Menus and battle that store `$C921` / `$C922`
directly need `sfx:request("slotA"|"slotB", id)` at those sites. The
call-site list is in the job report.

Music notes and SFX share channels in the ROM driver. This module does
not drive `MnMusic`, so a slot does not steal a song channel. `sfx:routed()`
is the current `NR51` byte if the mix should duck those channels.
`InstallSoundIndex` records the song pointer, but the countdown reader at
`$3D4A` is still unlifted, so songs do not advance here.
