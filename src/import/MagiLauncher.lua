-- MagiLauncher: MagiRecomp own launcher.
--
-- Copyright (C) 2026 MagiRecomp contributors
--
-- Licensed under the GNU General Public License version 3 with the
-- Additional Terms (GPLv3 Section 7) in LICENSE.MD.
--
-- Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
-- (https://github.com/bryanthaboi/gen1recomp)
--
-- This launcher was written from scratch for MagiRecomp (October 2026) to
-- replace the upstream launcher, which is proprietary to BOIS CLUB GAMES, LLC
-- and is not part of this fork (LICENSE.MD term 2).  It uses no code or
-- assets from that launcher.  It only calls the GPL import and cache APIs
-- (src/import/RomImport.lua, CacheFs, GameVersion).
--
-- Scope (work in progress): show the required credit, list the games this
-- engine can boot, import a dropped ROM, and start a ready game.  Magi Nation
-- imports the player's own ROM (drop, roms/, or the mobile picker) and boots.

local Attribution = require("src.core.Attribution")
local GameVersion = require("src.core.GameVersion")

local MagiLauncher = {}
MagiLauncher.__index = MagiLauncher

local MAGI_ID = "magination"

local COLORS = {
  bg = { 0.06, 0.05, 0.10 },
  panel = { 0.12, 0.10, 0.20 },
  accent = { 0.55, 0.85, 0.65 },
  text = { 0.95, 0.95, 0.98 },
  muted = { 0.65, 0.65, 0.75 },
  warn = { 0.95, 0.70, 0.40 },
  credit = { 0.85, 0.85, 0.90 },
}

local function setColor(c, a)
  love.graphics.setColor(c[1], c[2], c[3], a or 1)
end

local function fonts(self)
  if self._fonts then return self._fonts end
  local g = love.graphics
  local ok1, title = pcall(g.newFont, 34)
  local ok2, body = pcall(g.newFont, 16)
  local ok3, small = pcall(g.newFont, 12)
  local fallback = g.getFont()
  self._fonts = {
    title = ok1 and title or fallback,
    body = ok2 and body or fallback,
    small = ok3 and small or fallback,
  }
  return self._fonts
end

-- new(onPlay, opts): onPlay(version, cartId, opts) boots a game.
function MagiLauncher.new(onPlay, opts)
  local self = setmetatable({}, MagiLauncher)
  self.onPlay = onPlay
  self.opts = opts or {}
  self.launcher = true
  self.saveNotice = {}
  self.selected = 1
  self.message = nil
  self:refresh()
  local initial = self.opts.initialTab
  if initial then
    for i, row in ipairs(self.rows) do
      if row.id == initial then self.selected = i end
    end
  end
  return self
end

function MagiLauncher:refresh()
  local RomImport = require("src.import.RomImport")
  local rows = {
    { id = MAGI_ID, label = "Magi Nation (3D)", wip = true,
      detail = "Tap to import your own ROM, then play." },
  }
  for _, version in ipairs(GameVersion.ORDER) do
    local info = GameVersion.info(version)
    local okReady, ready = pcall(RomImport.isReady, version)
    rows[#rows + 1] = {
      id = version,
      label = (info and info.displayName or version) .. " (base engine)",
      ready = okReady and ready or false,
    }
  end
  self.rows = rows
  if self.selected > #rows then self.selected = #rows end
end

function MagiLauncher:_importer()
  if self._import then return self._import end
  local RomImport = require("src.import.RomImport")
  self._import = RomImport.new(function(version)
    self.message = (GameVersion.info(version) or {}).displayName or version
    self.message = self.message .. " imported. Select it and press Enter to play."
    self:refresh()
  end)
  self._import.onError = function(message)
    self.message = tostring(message)
  end
  return self._import
end

function MagiLauncher:play(index)
  local row = self.rows[index or self.selected]
  if not row then return end
  if row.wip then
    return self:playMagi()
  end
  if not row.ready then
    self.message = "Drop a clean ROM file onto this window to import it first."
    return
  end
  if self.onPlay then self.onPlay(row.id, nil, nil) end
end

local PICKED_ROM = "picked_rom.gb" -- where the Android/iOS picker copies a ROM

local function mnImporter()
  package.path = "src/?.lua;" .. package.path
  return require("mn.MnImporter")
end
MagiLauncher._mnImporter = mnImporter

-- True when bytes are the supported Magi Nation (USA) dump.
function MagiLauncher.isMagiRom(bytes)
  if type(bytes) ~= "string" or #bytes == 0 then return false end
  local sha = love.data.encode("string", "hex", love.data.hash("sha1", bytes))
  return sha == mnImporter().SHA1
end

-- Build the private mn_cache from ROM bytes (never stored anywhere else).
function MagiLauncher.importMagi(bytes)
  if not MagiLauncher.isMagiRom(bytes) then
    return nil, "That is not a clean Magi Nation (USA) ROM (SHA-1 mismatch)."
  end
  local ok, res, err = pcall(mnImporter().import, bytes)
  if not ok then return nil, tostring(res) end
  if not res then return nil, tostring(err) end
  return true
end

function MagiLauncher:_bootMagi()
  love.filesystem.setRequirePath("src/?.lua;src/?/init.lua;"
    .. love.filesystem.getRequirePath())
  local ok, err = pcall(function()
    require("src.mn.Boot")
    love.load(arg)
  end)
  if not ok then self.message = "Magi Nation failed to start: " .. tostring(err) end
end

-- Queue ROM bytes; the import runs on the next update so the message draws.
function MagiLauncher:_queueMagi(bytes)
  self._magiBytes = bytes
  self.message = "Importing Magi Nation (one time, may take a minute)..."
end

-- Hand off to the Magi Nation rebuild (src/mn/Boot.lua).  Needs the private
-- cache; if it is missing, import the player's own ROM from roms/ (desktop
-- checkout), the native file picker (Android/iOS), or a dropped file.
function MagiLauncher:playMagi()
  local okImp, Imp = pcall(mnImporter)
  if okImp and Imp.isCached and Imp.isCached() then return self:_bootMagi() end
  local f = io.open("roms/magination.gbc", "rb")
  if f then
    local bytes = f:read("*a"); f:close()
    return self:_queueMagi(bytes)
  end
  if love.system and type(love.system.pickFile) == "function" then
    love.filesystem.remove(PICKED_ROM)
    if love.system.pickFile("rom") then
      self._picking = true
      self.message = "Choose your own Magi Nation (USA) ROM file."
      return
    end
  end
  self.message = "Magi Nation: drop your own Magi Nation (USA) ROM on this "
    .. "window (or put it at roms/magination.gbc), then press Enter."
end

function MagiLauncher:_checkPicked()
  if not self._picking or not love.filesystem.getInfo(PICKED_ROM) then return end
  self._picking = false
  local bytes = love.filesystem.read(PICKED_ROM)
  love.filesystem.remove(PICKED_ROM)
  if MagiLauncher.isMagiRom(bytes) then return self:_queueMagi(bytes) end
  self.message = "That file is not a clean Magi Nation (USA) ROM."
end

function MagiLauncher:move(delta)
  local n = #self.rows
  if n == 0 then return end
  self.selected = ((self.selected - 1 + delta) % n) + 1
end

function MagiLauncher:update(dt)
  self:_checkPicked()
  if self._magiBytes then
    if self._magiWait then
      local bytes = self._magiBytes
      self._magiBytes, self._magiWait = nil, nil
      local ok, err = MagiLauncher.importMagi(bytes)
      collectgarbage()
      if ok then return self:_bootMagi() end
      self.message = "Magi Nation import failed: " .. tostring(err)
    else
      self._magiWait = true -- let one frame draw the message first
    end
  end
  if self._import then self._import:update(dt) end
end

local function layout()
  local w, h = love.graphics.getDimensions()
  return w, h, 40, 150, 34
end

function MagiLauncher:draw()
  local g = love.graphics
  local f = fonts(self)
  local w, h, x, listY, rowH = layout()
  g.push("all")
  g.clear(COLORS.bg[1], COLORS.bg[2], COLORS.bg[3], 1)

  g.setFont(f.title)
  setColor(COLORS.accent)
  g.print(Attribution.PROJECT, x, 36)
  g.setFont(f.body)
  setColor(COLORS.muted)
  g.print(Attribution.TAGLINE .. "  -  Magi Nation launcher (work in progress)", x, 84)
  g.print("Up/Down select, Enter play, drop a ROM to import, Esc quit", x, 108)

  for i, row in ipairs(self.rows) do
    local y = listY + (i - 1) * rowH
    if y + rowH > h - 110 then break end
    if i == self.selected then
      setColor(COLORS.panel)
      g.rectangle("fill", x - 10, y - 4, w - 2 * x + 20, rowH - 4, 6, 6)
    end
    setColor(row.wip and COLORS.warn or COLORS.text)
    g.print(row.label, x, y)
    local status = row.wip and "WIP" or (row.ready and "Ready" or "Not imported")
    setColor(row.ready and COLORS.accent or COLORS.muted)
    g.printf(status, x, y, w - 2 * x, "right")
  end

  local imp = self._import
  local statusY = h - 104
  if imp and imp.workState == "working" then
    setColor(COLORS.text)
    g.print(("%s  %d%%"):format(tostring(imp.status or "Importing"),
      math.floor((imp.progress or 0) * 100)), x, statusY)
  elseif self.message then
    setColor(COLORS.warn)
    g.printf(self.message, x, statusY, w - 2 * x)
  end

  -- Required attribution (LICENSE.MD term 1): always visible.
  g.setFont(f.small)
  setColor(COLORS.credit)
  g.printf(Attribution.UPSTREAM_CREDIT, x, h - 62, w - 2 * x)
  setColor(COLORS.muted)
  g.printf(Attribution.NOT_AFFILIATED, x, h - 32, w - 2 * x)
  g.pop()
end

function MagiLauncher:keypressed(key)
  if key == "up" or key == "w" then self:move(-1)
  elseif key == "down" or key == "s" then self:move(1)
  elseif key == "return" or key == "kpenter" or key == "space" then self:play()
  elseif key == "f5" then self:refresh()
  elseif key == "escape" then love.event.quit()
  end
end

function MagiLauncher:gamepadpressed(_, button)
  if button == "dpup" then self:move(-1)
  elseif button == "dpdown" then self:move(1)
  elseif button == "a" or button == "start" then self:play()
  end
end

function MagiLauncher:_rowAt(px, py)
  local _, _, _, listY, rowH = layout()
  if py < listY - 4 then return nil end
  local i = math.floor((py - listY + 4) / rowH) + 1
  if self.rows[i] then return i end
  return nil
end

function MagiLauncher:mousepressed(x, y, button, istouch)
  if istouch or button ~= 1 then return end
  local i = self:_rowAt(x, y)
  if not i then return end
  if i == self.selected then self:play(i) else self.selected = i end
end

function MagiLauncher:touchpressed(_, x, y)
  local i = self:_rowAt(x, y)
  if not i then return end
  if i == self.selected then self:play(i) else self.selected = i end
end

function MagiLauncher:filedropped(file)
  self.message = nil
  local okOpen = pcall(file.open, file, "r")
  local bytes = okOpen and file:read() or nil
  pcall(file.close, file)
  if MagiLauncher.isMagiRom(bytes) then return self:_queueMagi(bytes) end
  self:_importer():filedropped(file)
end

function MagiLauncher:startPath(path)
  self:_importer():startPath(path)
end

function MagiLauncher:savesChanged() self:refresh() end
function MagiLauncher:resumeAfterOverlay() self:refresh() end

function MagiLauncher:focus(on) if on then self:_checkPicked() end end

local function noop() end
for _, name in ipairs({ "gamepadreleased", "gamepadaxis", "joystickpressed",
    "joystickreleased", "joystickaxis", "joystickhat", "touchmoved",
    "touchreleased", "mousereleased", "mousemoved", "textinput",
    "prepareOverlayHandoff", "ignoreReturningPointer" }) do
  MagiLauncher[name] = noop
end

return MagiLauncher
