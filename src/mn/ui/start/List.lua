-- List mode, IndexedSetup index $0B (indexed_setup.asm). SRAM counts live at
-- $A4A6. CopyIndexedName (bank 6 $5A60) supplies the ten-byte name for that
-- offset. An empty row is eleven $80 tiles from $9C66 (column 6). Tile $80
-- is solid palette-7 colour 0, so the fill is that colour.
-- Harness name: start.List
local Group = require("mn.ui.start.GroupList")
local Draw = require("mn.ui.start.Draw")

local SPEC = {
  mode = 0x0B, base = 0xA4A6, bank = 6, home = 0x0D, scale = 0x01,
  nameAt = 0x5AA6, nameBlank = 0x5A9C, nameLen = 10,
}

local M = {}

local function paper(ctx)
  local ow = ctx.ow
  local pal = ow and ow.def and ow.def.pal7
  local c = pal and pal[0] or { 1, 1, 1 }
  return c[1], c[2], c[3]
end

-- IndexedSetup index $0B: $CC5A + row == 0 blanks $9C66 + row * $20, 11 tiles.
local function blankEmpty(ctx, mach)
  local r, g, b = paper(ctx)
  love.graphics.setColor(r, g, b, 1)
  for i = 0, 4 do
    if (mach.flags[0x0D + i] or 0) == 0 then
      love.graphics.rectangle("fill", 6 * 8, (3 + i) * 8, 11 * 8, 8)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function M.new(ctx, mach)
  local scr = Group.new(ctx, SPEC, mach)
  function scr:draw()
    Draw.chrome(self.ctx)
    Draw.group(self.ctx, self.mach)
    blankEmpty(self.ctx, self.mach)
    Draw.cursor(self.ctx, self.mach)
  end
  return scr
end

return M
