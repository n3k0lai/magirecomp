-- Harness probe for the UI screen contract (docs/mn-ui.md). Not part of the game:
-- three rows, up/down move, A returns { pick = row }, B returns { pick = 0 }.
local M = {}
M.__index = M

function M.new(ctx)
  return setmetatable({ ctx = ctx, cur = 1, lastDir = nil }, M)
end

function M:update()
  local inp = self.ctx.input
  local d = inp("dir")
  if d and d ~= self.lastDir then
    if d == "up" then self.cur = (self.cur + 1) % 3 + 1 elseif d == "down" then self.cur = self.cur % 3 + 1 end
  end
  self.lastDir = d
  if inp("a") then return { pick = self.cur } end
  if inp("b") then return { pick = 0 } end
  return nil
end

function M:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", 40, 40, 80, 64)
  love.graphics.setColor(0, 0, 0)
  for i = 1, 3 do love.graphics.rectangle(i == self.cur and "fill" or "line", 48, 40 + i * 16, 64, 10) end
  love.graphics.setColor(1, 1, 1)
end

return M
