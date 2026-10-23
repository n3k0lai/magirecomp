-- Save slot on its own. The field menu reaches it by moving right from the
-- first row (slot record 0's right candidate, $24 on the real table).
-- Harness name: start.Save. A arms the latch ($CD80); A again commits.
local Machine = require("mn.ui.start.Machine")
local Draw = require("mn.ui.start.Draw")
local Commit = require("mn.ui.start.Commit")

local M = {}
M.__index = M

function M.new(ctx)
  local mach = Machine.boot(ctx)
  mach:press("right")
  return setmetatable({ ctx = ctx, mach = mach }, M)
end

function M:update()
  self.mach:blink()
  local btn = self.mach:take(self.ctx.input)
  local ev = btn and self.mach:press(btn)
  if ev == "save" then return Commit.run(self.ctx) end
  if ev == "close" then
    self.mach:leave()
    return { action = "cancel" }
  end
  return nil
end

function M:draw()
  Draw.chrome(self.ctx)
  Draw.cursor(self.ctx, self.mach)
end

return M
