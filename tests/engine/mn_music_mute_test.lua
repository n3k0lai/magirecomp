-- Overworld:playMusic honours the same mute rule as SfxOut. love plays through OpenAL, so
-- SDL_AUDIODRIVER=dummy alone never silenced $1F music in headless runs.
--   luajit tests/engine/mn_music_mute_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local made = 0
_G.love = _G.love or {}
love.audio = { newSource = function() made = made + 1; return { setLooping = function() end, play = function() made = made + 100 end, stop = function() end } end,
  newQueueableSource = function() return {} end }
love.sound = { newSoundData = function() return { setSample = function() end } end }

local realGetenv = os.getenv
local env = {}
os.getenv = function(k) return env[k] end

local Overworld = require("mn.Overworld")
-- a rom whose reads would error: playMusic must return before touching it
local s = setmetatable({ vm = { rom = setmetatable({}, { __index = function() error("rom touched while muted") end }) } }, { __index = Overworld })

for _, k in ipairs({ "SDL_AUDIODRIVER", "MN_NOMUSIC", "MN_MUTE" }) do
  env = { [k] = k == "SDL_AUDIODRIVER" and "dummy" or "1" }
  local okc, err = pcall(function() s:playMusic(3) end)
  ok(okc, k .. " muted playMusic returned early: " .. tostring(err))
  ok(made == 0 and s.music == nil, k .. " built no source and played nothing")
end

os.getenv = realGetenv
print(("mn_music_mute_test: %d/%d"):format(checks - failures, checks))
if failures > 0 then os.exit(1) end
