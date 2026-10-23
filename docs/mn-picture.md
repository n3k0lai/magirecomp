# Travel-card picture

`src/mn/Picture.lua` is the background the travel cards and the attract
slideshow put on the LCD. It is not a menu screen. The field stays in
charge of input. The picture only replaces what `draw` paints until the
script loads a map again.

## What fills it

`$6A` (`call_script_map_records_then_fill_c72b.asm`) names two records.

- The first is a `CopyMapRecords` list (`copy_map_records.asm`, `$2FC0`).
  `CopyOneVRAMRecord` (`copy_one_vram_record.asm`, `$2FE5`) copies each
  7-byte record into VRAM bank 0, then the second count does the same for
  bank 1. A row stays in one `$100`-byte page (`inc c`). The next row
  starts `$100` bytes later. Bit 4 of the tiles byte steps the source by
  `$100`; otherwise the step is `swap(tiles)`.
- The second record is `$40` bytes. `FillC72BFromBCThenBank7` copies them
  to `$C72B`, and index `$07` copies those 32 words to `$C7AB`.
  `CopyC7ABToBGPalettes` is the eight BG palettes (RGB555). The opcode
  already writes both blocks. The picture reads the same bytes from the ROM.

`$63` (`call_banked_word_then_resume.asm`) calls `UnpackScriptMapsAt9800`
(`$2D14`). `UnpackBytes` (`unpack_bytes.asm`) writes the first stream to
the `$9800` attribute plane (VRAM bank 1) and the next stream to the tile
ids (VRAM bank 0). A short length of zero ends a stream.

Both opcodes publish one shared picture:

```lua
if vm.host.picture then vm.host.picture(pic) end
```

`$86` (`seed_camera_loop.asm`) does not build the picture. `clamp_map_camera.asm`
stores SCX at `$FF43` and SCY at `$FF42`. `Picture:draw` reads those live
bytes when the picture still has its vm. `$63` and `$6A` do not write them.

`draw` uses LCDC `$E3` (`turn_on_lcd.asm`): BG map `$9800`, tiles in the
`$8800` method, window map `$9C00`. `setup_window.asm` leaves the window at
WX 7, WY `$90`, which is the first line below the picture, so the card is
the BG. Attribute bits match `paint_map_attrs_seed_slot.asm` (palette,
VRAM bank, horizontal flip, vertical flip).

## WRAM the opcodes already touch

No new writes. `$6A` still copies 64 bytes to `$C72B` and `$C7AB`, and sets
`$C9D8` to 7 and `$C831` to 1. `$86` still owns the camera bytes. The
picture only reads `$FF42` and `$FF43`.

## What Ene wires

`Overworld:host`, next to the other callbacks:

```lua
picture = function(pic) s.picture = pic end,
```

`opcode $65` in `ScriptVM.lua` (`LoadFiveBankedMapSources`, the field
return) must clear it. One line, before `h.loadMap`:

```lua
if h.picture then h.picture(nil) end
```

`Overworld:draw` paints the picture instead of the field, and keeps the
fade and the text box, which `drawField` already draws after the map:

```lua
function M:drawField()
  if self.picture then
    self.picture:draw()
  else
    -- existing map, sprites, and player
  end
  -- existing fade ($C6F3 and $6E/$6F) and text box stay on top
end
```

`picture(nil)` sets `s.picture` to nil. The vm keeps the VRAM object so
the next card writes over it, which is what the LCD does.

## Still open

`DrawMetatileWindow` is the field's own `$9800` fill. It is not this
layer. Sprites are not drawn on the card. A long `UnpackBytes` count of
zero wraps to 65536, matching the decrement; retail streams do not use it.
