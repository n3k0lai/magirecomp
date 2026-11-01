-- MagiLauncher ROM import path (drop / mobile picker) and the MN touch pad.
-- Synthetic bytes only; no ROM needed.   luajit tests/engine/mn_android_import_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local files, picks, imported = {}, 0, nil
love = { -- luacheck: ignore 111
  data = {
    hash = function(_, s) return "H:" .. s end,
    encode = function(_, _, s) return s == "H:GOOD" and "9972a7bca43210b4b6c0b3f6ee5d1957a865e12d" or "00" end,
  },
  filesystem = {
    getInfo = function(p) return files[p] and {} or nil end,
    read = function(p) return files[p] end,
    remove = function(p) files[p] = nil end,
    setRequirePath = function() end, getRequirePath = function() return "" end,
  },
  system = { pickFile = function(kind) picks = picks + 1; ok(kind == "rom", "picker kind rom"); return true end },
}
package.loaded["mn.MnImporter"] = {
  SHA1 = "9972a7bca43210b4b6c0b3f6ee5d1957a865e12d",
  isCached = function() return false end,
  import = function(b) imported = b; return true end,
}
package.loaded["src.core.Attribution"] = {}
package.loaded["src.core.GameVersion"] = { ORDER = {} }
package.loaded["src.import.RomImport"] = { isReady = function() return false end }

local L = require("src.import.MagiLauncher")
ok(L.isMagiRom("GOOD"), "good ROM accepted")
ok(not L.isMagiRom("BAD"), "bad ROM rejected")
ok(not L.isMagiRom(nil), "nil rejected")
local okBad, err = L.importMagi("BAD")
ok(not okBad and err:find("SHA%-1"), "bad ROM import refused")
ok(L.importMagi("GOOD") and imported == "GOOD", "good ROM imports")

-- picker flow: playMagi opens picker, a picked file is imported then booted
imported = nil
local l = L.new(nil)
local booted = false
l._bootMagi = function() booted = true end
l:playMagi()
ok(picks == 1 and l._picking, "picker opened")
files["picked_rom.gb"] = "GOOD"
l:focus(true)
ok(files["picked_rom.gb"] == nil, "picked file removed from save dir")
l:update(0); l:update(0)
ok(imported == "GOOD" and booted, "picked ROM imported and booted")

-- wrong picked file is reported, not imported
imported = nil
l:playMagi(); files["picked_rom.gb"] = "BAD"; l:update(0); l:update(0)
ok(imported == nil and l.message:find("not a clean"), "wrong pick refused")

-- touch pad maps touches to keyboard events, multi-touch safe
local TouchPad = require("mn.TouchPad")
local ev = {}
local pad = TouchPad.new(function(k, on) ev[#ev + 1] = k .. (on and "+" or "-") end)
local r = TouchPad.layout(800, 480)
local function c(q) return q[1] + q[3] / 2, q[2] + q[4] / 2 end
local ax, ay = c(r.a); local ux, uy = c(r.up)
pad:press(1, ux, uy, 800, 480); pad:press(2, ax, ay, 800, 480)
local rx, ry = c(r.right); pad:move(1, rx, ry, 800, 480); pad:release(2); pad:release(1)
ok(table.concat(ev, ",") == "up+,z+,up-,right+,z-,right-", "pad events: " .. table.concat(ev, ","))

print(("mn_android_import_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
