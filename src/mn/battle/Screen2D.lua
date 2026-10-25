-- 2D subscriber for mn.battle.Bus. It shows frame 1 of a clip inside onEvent (no
-- yield). Battle:spend shows the later frames and calls finish() when the budget
-- ends, so the yield count stays in play().
local Ppu = require("mn.PpuFrame")

local S = {}
S.__index = S

function S.new(battle)
  return setmetatable({ b = battle }, S)
end

function S:onEvent(ev, frames)
  local b = self.b
  if ev.t == "damage" then
    if b.playSceneName then
      b:L("battle anim " .. b.playSceneName)
      if frames > 0 then
        self.clip = { kind = "scene", name = b.playSceneName }
        self:show(1)
      end
    elseif frames > 0 then
      self.clip = { kind = "flash", slot = ev.slot }
      self:show(1)
    end
  elseif ev.t == "summon" and not ev.pending and frames > 0 then
    self.clip = { kind = "fade", n = frames }
    self:show(1)
  elseif ev.t == "eliminated" and frames > 0 then
    self.clip = { kind = "elim", slot = ev.slot }
    self:show(1)
  end
end

function S:show(i)
  local c, b = self.clip, self.b
  if not c then return end
  if c.kind == "scene" then self:sceneFrame(c.name, i)
  elseif c.kind == "fade" then b.white = i / c.n
  elseif c.kind == "elim" then self:elimFrame(c.slot, i)
  elseif c.kind == "flash" then b.flash = c.slot end
end

function S:finish()
  local b = self.b
  b.anim, b.elim, b.white, b.flash = nil, nil, nil, nil
  self.clip = nil
end

function S:sceneFrame(name, i)
  local f = Ppu.scene(name)[i]
  if not f then return end
  local b = self.b
  b.animCache = b.animCache or {}
  local key = name .. i
  if not b.animCache[key] then
    local im = love.graphics.newImage(Ppu.render(f))
    im:setFilter("nearest", "nearest")
    b.animCache[key] = im
  end
  b.anim = b.animCache[key]
end

function S:elimFrame(slot, i)
  local f = Ppu.scene("elim_top")[i]
  if not f then return end
  local _, dy = require("mn.Battle").cardXY(slot)
  local b = self.b
  b.elimCache = b.elimCache or {}
  local key = i .. ":" .. dy
  if not b.elimCache[key] then
    local img = love.image.newImageData(160, 144)
    Ppu.oam(img, f, nil, 0, dy)
    b.elimCache[key] = love.graphics.newImage(img)
    b.elimCache[key]:setFilter("nearest", "nearest")
  end
  b.elim = b.elimCache[key]
end

return S
