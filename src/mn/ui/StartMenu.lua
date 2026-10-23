-- Field Start menu. HandleStartPress (bank 6) runs only when $C6EE is 0,
-- bit 1 of $FFAB is set, $C716 is 0 and $CCA6 is 0. The loop is AfterStartLoop
-- at 06:673B. This screen keeps a child for the spell and item lists and
-- forwards update/draw to it. A on Rings opens the mode-7 entry
-- (DrawIndexedEntry) the same way.
--
-- A on Glyph and List does nothing:
--   TODO(DrawIndex9Map): mode 9
--   TODO(IndexedSetup): mode $0B
local bit = require("bit")
local Machine = require("mn.ui.start.Machine")
local Group = require("mn.ui.start.GroupList")
local Rings = require("mn.ui.start.Rings")
local Draw = require("mn.ui.start.Draw")
local Commit = require("mn.ui.start.Commit")

local M = {}
M.__index = M

function M.canOpen(vm)
  if vm:rd8(0xC6EE) ~= 0 then return false end
  if bit.band(vm:rd8(0xFFAB), 0x02) == 0 then return false end
  if vm:rd8(0xC716) ~= 0 then return false end
  if vm:rd8(0xCCA6) ~= 0 then return false end
  return true
end

function M.new(ctx)
  return setmetatable({ ctx = ctx, mach = Machine.boot(ctx) }, M)
end

function M:update()
  if self.child then
    local r = self.child:update()
    if r == nil then return nil end
    if r.action == "back" then self.child = nil; return nil end
    if r.action == "save" then return r end
    return r
  end
  self.mach:blink()
  local btn = self.mach:take(self.ctx.input)
  local ev = btn and self.mach:press(btn)
  if ev == "close" then
    self.mach:leave()
    return { action = "close" }
  end
  if ev == "save" then return Commit.run(self.ctx) end
  if ev == "spell" then self.child = Group.new(self.ctx, Group.spell, self.mach) end
  if ev == "items" then self.child = Group.new(self.ctx, Group.items, self.mach) end
  if ev == "rings" then self.child = Rings.new(self.ctx, self.mach) end
  return nil
end

function M:draw()
  if self.child then self.child:draw(); return end
  Draw.chrome(self.ctx)
  Draw.cursor(self.ctx, self.mach)
end

return M
