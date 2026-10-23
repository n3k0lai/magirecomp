-- Queues sfx:render onto a QueueableSource. SelectSoundCommand and
-- UpdateSound stay inside render (finish_frame / RunDefaultVBlank): one
-- vblank slice per ~738 samples at 44100 Hz. Do not also call step.
-- Muted (SDL_AUDIODRIVER=dummy, MN_NOMUSIC, MN_MUTE, or no love.audio)
-- still renders, so requests drain, and never builds a source or calls play.
-- mn-headless is always muted.
local Sfx = require("mn.Sfx")

local M = {}
M.__index = M

local RATE = Sfx.RATE
-- A few frames of slack. Each update queues one buffer of the samples due.
local BUFFERS = 4

function M.muted()
  if os.getenv("SDL_AUDIODRIVER") == "dummy" then return true end
  if os.getenv("MN_NOMUSIC") then return true end
  if os.getenv("MN_MUTE") then return true end
  local audio = love and love.audio
  local sound = love and love.sound
  if not (audio and audio.newQueueableSource and sound and sound.newSoundData) then
    return true
  end
  return false
end

function M.new(rom)
  local muted = M.muted()
  local src
  if not muted then
    src = love.audio.newQueueableSource(RATE, 16, 1, BUFFERS)
  end
  return setmetatable({ sfx = Sfx.new(rom), muted = muted, src = src, acc = 0 }, M)
end

local function clamp(v)
  if v ~= v or v == nil then return 0 end
  if v > 1 then return 1 end
  if v < -1 then return -1 end
  return v
end

function M:_queue(samples)
  local src = self.src
  if not src or #samples == 0 then return end
  local free = src.getFreeBufferCount and src:getFreeBufferCount() or 1
  if not free or free < 1 then return end
  local sd = love.sound.newSoundData(#samples, RATE, 16, 1)
  for i = 1, #samples do sd:setSample(i - 1, clamp(samples[i])) end
  src:queue(sd)
  if not (src.isPlaying and src:isPlaying()) then src:play() end
end

-- dt is one field frame (Overworld passes 1/60). Samples due are dt * 44100.
function M:update(dt)
  if not dt or dt < 0 then dt = 0 end
  self.acc = self.acc + dt * RATE
  local n = math.floor(self.acc)
  if n <= 0 then return end
  self.acc = self.acc - n
  local samples = self.sfx:render(n)
  if self.muted or not self.src then return end
  self:_queue(samples)
end

return M
