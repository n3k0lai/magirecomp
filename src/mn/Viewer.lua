-- Map viewer state: browse all cached maps (left/right), overlay the cell plane.
local Importer = require("mn.MnImporter")
local M = {}
M.__index = M
function M.new(i) local s = setmetatable({ i = i or 0, ox = 0, oy = 0, overlay = false }, M); s:load(); return s end
function M:load() self.def = Importer.loadMap(self.i); self.ox, self.oy = 0, 0 end
function M:key(k)
  if k == "right" then self.i = (self.i + 1) % 369; self:load()
  elseif k == "left" then self.i = (self.i - 1) % 369; self:load()
  elseif k == "tab" then self.overlay = not self.overlay end
end
function M:draw()
  love.graphics.clear(0, 0, 0)
  love.graphics.draw(self.def.image, -self.ox, -self.oy)
  if self.overlay then
    for y = 0, self.def.h - 1 do for x = 0, self.def.w - 1 do
      local v = self.def.block[y * self.def.w + x + 1]
      if v == 8 then love.graphics.setColor(1, 0, 0, 0.35)
      elseif v >= 0xC0 then love.graphics.setColor(0, 1, 1, 0.6)
      elseif v ~= 0 then love.graphics.setColor(1, 1, 0, 0.5) else love.graphics.setColor(0, 0, 0, 0) end
      love.graphics.rectangle("fill", x * 16 - self.ox, y * 16 - self.oy, 16, 16)
    end end
    love.graphics.setColor(1, 1, 1)
  end
  love.graphics.print(("map %03d %dx%d"):format(self.i, self.def.w, self.def.h), 2, 2)
end
return M
