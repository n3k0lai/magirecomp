-- IndexedSetup indexes 3 and 4 (indexed_setup.asm). Index 3 reads SRAM from
-- $A5A5 (spell). Index 4 reads from $A3A7 (items). Five nonzero bytes are
-- the visible rows; the byte is the count and the offset is the name id.
-- Names are 13 glyph indexes, 12 bytes into the $22-byte bank-7 record.
local Machine = require("mn.ui.start.Machine")
local Draw = require("mn.ui.start.Draw")
local Commit = require("mn.ui.start.Commit")

local M = {}
M.__index = M

M.spell = { mode = 3, base = 0xA5A5, addend = 0x6FF5, bank = 7, home = 0x06, scale = 0x22 }
M.items = { mode = 4, base = 0xA3A7, addend = 0x5DFF, bank = 7, home = 0x0D, scale = 0x22 }

function M.new(ctx, spec, mach)
  if not mach then mach = Machine.boot(ctx) end
  mach:refreshList(spec, true)
  return setmetatable({ ctx = ctx, spec = spec, mach = mach }, M)
end

function M:update()
  self.mach:blink()
  local btn = self.mach:take(self.ctx.input)
  local ev = btn and self.mach:press(btn)
  if ev == "redraw" then self.mach:refreshList(self.spec, false) end
  if ev == "menu" then return { action = "back" } end
  if ev == "close" then
    self.mach:leave()
    return { action = "close" }
  end
  if ev == "save" then return Commit.run(self.ctx) end
  return nil
end

function M:draw()
  Draw.chrome(self.ctx)
  Draw.group(self.ctx, self.mach)
  Draw.cursor(self.ctx, self.mach)
end

return M
