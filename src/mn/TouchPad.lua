-- TouchPad: minimal on-screen D-pad + A/B/Start/Select for the Magi Nation
-- rebuild on touch screens (Android/iOS).  It only turns touches into the
-- same key events the keyboard path already uses (arrows, z, x, return,
-- rshift); it adds no game logic.
--
-- Copyright (C) 2026 MagiRecomp contributors
-- Licensed under the GNU General Public License version 3 with the
-- Additional Terms in LICENSE.MD.

local TouchPad = {}
TouchPad.__index = TouchPad

-- name -> key fed to love.keypressed / love.keyreleased
TouchPad.KEYS = { up = "up", down = "down", left = "left", right = "right",
  a = "z", b = "x", start = "return", select = "rshift" }

function TouchPad.new(send)
  return setmetatable({ send = send, owner = {}, down = {}, shown = false }, TouchPad)
end

-- Button rectangles for a w x h window: D-pad bottom-left, A/B bottom-right,
-- Start/Select bottom-centre.
function TouchPad.layout(w, h)
  local s = math.floor(math.min(w, h) * 0.12)
  local by = h - s * 3.4
  local r = {}
  local dx, dy = s * 0.4, by
  r.up    = { dx + s, dy, s, s }
  r.left  = { dx, dy + s, s, s }
  r.right = { dx + 2 * s, dy + s, s, s }
  r.down  = { dx + s, dy + 2 * s, s, s }
  r.a     = { w - s * 1.5, dy + s * 0.4, s * 1.1, s * 1.1 }
  r.b     = { w - s * 2.9, dy + s * 1.3, s * 1.1, s * 1.1 }
  r.select = { w / 2 - s * 1.3, h - s * 0.8, s, s * 0.5 }
  r.start  = { w / 2 + s * 0.3, h - s * 0.8, s, s * 0.5 }
  return r
end

function TouchPad.hit(rects, x, y)
  for name, q in pairs(rects) do
    if x >= q[1] and x < q[1] + q[3] and y >= q[2] and y < q[2] + q[4] then return name end
  end
end

function TouchPad:_set(name, on)
  local was = (self.down[name] or 0) > 0
  self.down[name] = math.max(0, (self.down[name] or 0) + (on and 1 or -1))
  local is = self.down[name] > 0
  if is ~= was then self.send(TouchPad.KEYS[name], is) end
end

function TouchPad:press(id, x, y, w, h)
  self.shown = true
  local name = TouchPad.hit(TouchPad.layout(w, h), x, y)
  if name then self.owner[id] = name; self:_set(name, true) end
  return name
end

function TouchPad:move(id, x, y, w, h)
  local name = TouchPad.hit(TouchPad.layout(w, h), x, y)
  local old = self.owner[id]
  if name == old then return end
  if old then self:_set(old, false) end
  self.owner[id] = name
  if name then self:_set(name, true) end
end

function TouchPad:release(id)
  local old = self.owner[id]
  self.owner[id] = nil
  if old then self:_set(old, false) end
end

function TouchPad:draw(w, h)
  if not self.shown then return end
  local g = love.graphics
  for name, q in pairs(TouchPad.layout(w, h)) do
    g.setColor(1, 1, 1, (self.down[name] or 0) > 0 and 0.45 or 0.2)
    g.rectangle("fill", q[1], q[2], q[3], q[4], 8, 8)
    g.setColor(1, 1, 1, 0.7)
    g.printf(name:upper(), q[1], q[2] + q[4] / 2 - 7, q[3], "center")
  end
  g.setColor(1, 1, 1, 1)
end

return TouchPad
