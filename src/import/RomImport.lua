-- RomImport: ROM import, verification, and cache-extraction logic.
--
-- Copyright (C) 2026 BOIS CLUB GAMES, LLC
-- Modifications Copyright (C) 2026 MagiRecomp contributors
--
-- This file is part of MagiRecomp, a modified fork of the Pokemon Gen 1
-- Recompilation Project.  It is free software under the GNU General Public
-- License version 3 together with the Additional Terms (GPLv3 Section 7)
-- in LICENSE.MD.  See LICENSE.MD for details.
--
-- Based on the Pokemon Gen 1 Recompilation Project by BOIS CLUB GAMES, LLC
-- (https://github.com/bryanthaboi/gen1recomp)
--
-- MODIFIED (October 2026, MagiRecomp): the GPL-licensed ROM import,
-- verification, and cache extraction logic of src/import/RomImporter.lua was
-- separated out into this module.  The upstream launcher user interface that
-- lived in RomImporter.lua is proprietary to BOIS CLUB GAMES, LLC (LICENSE.MD
-- term 2) and is NOT included here; MagiRecomp ships its own launcher
-- (src/import/MagiLauncher.lua).  This module draws no UI of its own beyond a
-- plain progress readout for headless/scripted imports.

local GameVersion = require("src.core.GameVersion")
local Logger = require("src.core.Logger")
local CacheContract = require("src.import.CacheContract")

local RomImport = {}
RomImport.__index = RomImport

-- ------- ROM cache location
--
-- Remove a cache subtree from the OS save directory.  Files are deleted by
-- their real save-directory path and directories through the write
-- directory only, so this never deletes the game folder (portable installs
-- read the cache from there) or a developer checked-out source tree.
local chmodFn = nil

local function makeWritable(real, mode)
  if chmodFn == nil then
    chmodFn = false
    local okFfi, ffi = pcall(require, "ffi")
    if okFfi and ffi.os ~= "Windows" then
      pcall(ffi.cdef, "int chmod(const char *path, unsigned int mode);")
      if pcall(function() return ffi.C.chmod end) then
        chmodFn = function(p, m) pcall(ffi.C.chmod, p, m) end
      end
    end
  end
  if chmodFn then chmodFn(real, mode) end
end

local function removeTree(path)
  local info = love.filesystem.getInfo(path)
  if not info then return end
  if info.type == "directory" then
    makeWritable(love.filesystem.getSaveDirectory() .. "/" .. path, 493)
    for _, child in ipairs(love.filesystem.getDirectoryItems(path)) do
      removeTree(path .. "/" .. child)
    end
    love.filesystem.remove(path)
    return
  end
  local SaveData = require("src.core.SaveData")
  local real = love.filesystem.getSaveDirectory() .. "/" .. path
  local f = SaveData.openNative(real, "rb")
  if not f then return end
  f:close()
  local ok, err = SaveData.removeNative(real)
  if not ok then
    makeWritable(real, 420)
    ok, err = SaveData.removeNative(real)
  end
  if not ok then
    error("could not remove stale cache " .. real .. ": " .. tostring(err))
  end
end

RomImport._removeSaveDirTree = removeTree

-- Portable installs read the cache from the game folder.  A copy an earlier
-- non-portable run left in the save directory would shadow it, because
-- physfs searches the save directory before the source.  Clear it once.
local saveDirPurged = false
local function purgeSaveDirCache()
  if saveDirPurged then return end
  saveDirPurged = true
  local saveDir = love.filesystem.getSaveDirectory()
  local function saveDirHas(rel)
    local f = require("src.core.SaveData").openNative(saveDir .. "/" .. rel, "rb")
    if not f then return false end
    f:close()
    return true
  end
  for _, version in ipairs(GameVersion.ORDER) do
    local prefix = GameVersion.cachePrefix(version)
    local required = CacheContract.presenceFilesFor(version)
    local hasRequired = false
    for _, path in ipairs(required) do
      if saveDirHas(prefix .. path) then hasRequired = true; break end
    end
    if saveDirHas(prefix .. CacheContract.MARKER_PATH) or hasRequired then
      removeTree(prefix .. "data/generated")
      removeTree(prefix .. "assets/generated")
      love.filesystem.remove(prefix .. CacheContract.MARKER_PATH)
    end
  end
end

-- Whether a given game version ROM has already been imported and cached.
function RomImport.isReady(version)
  version = version or "red"
  local CacheFs = require("src.import.CacheFs")
  if CacheFs.root() then purgeSaveDirCache() end
  return CacheContract.isReady(version, CacheFs)
end

local function sha1(data)
  local digest = love.data.hash("sha1", data)
  if type(digest) == "userdata" and digest.getString then
    digest = digest:getString()
  end
  return love.data.encode("string", "hex", digest)
end
RomImport.sha1 = sha1

local function readExternalPath(path)
  local file, openError = require("src.core.SaveData").openNative(path, "rb")
  if not file then return nil, openError end
  local data = file:read("*a")
  file:close()
  return data
end

local ROM_BYTES_GEN1 = 1024 * 1024
local ROM_BYTES_GEN2 = 2 * 1024 * 1024
local ROM_BYTES_GEN3 = 16 * 1024 * 1024

local function isAcceptedRomSize(n)
  return n == ROM_BYTES_GEN1 or n == ROM_BYTES_GEN2 or n == ROM_BYTES_GEN3
end
RomImport.isAcceptedRomSize = isAcceptedRomSize

-- .gb / .gbc / .gba (case-insensitive after lowercasing the name).
local function isRomFilename(name)
  return type(name) == "string" and name:lower():match("%.gb[ac]?$") ~= nil
end
RomImport.isRomFilename = isRomFilename

-- new(onComplete): a headless importer.  onComplete(version) runs once a ROM
-- has been verified and its private cache published.
function RomImport.new(onComplete, opts)
  local self = setmetatable({}, RomImport)
  self.onComplete = onComplete
  self.opts = opts or {}
  self.workState = "idle"
  self.status = nil
  self.detail = nil
  self.progress = 0
  return self
end

function RomImport:setError(message, version)
  require("src.import.CacheFs").prefix = ""
  self.workState = "error"
  self.errorVersion = version or self.importing
  self.importing = nil
  self.status = "That ROM could not be imported"
  self.detail = tostring(message)
  self.progress = 0
  self.worker = nil
  self._extract = nil
  self.romData = nil
  -- A headless import has no launcher to show this: log and exit non-zero.
  if os.getenv("POKEPORT_IMPORT_ONLY") == "1" then
    Logger.error("import failed: %s", tostring(message))
    love.event.quit(1)
  end
  if self.onError then pcall(self.onError, message, version) end
end

-- Verify + extract a ROM.  The version is decided by the ROM own SHA-1.
function RomImport:startData(data, displayName, sourcePath)
  if self.workState == "working" then return end
  self._importSource = sourcePath
  if type(data) ~= "string" then
    self:setError("The selected file could not be read.")
    return
  end
  local RomArchive = require("src.import.RomArchive")
  local kind = RomArchive.kind(data)
  if kind then
    if #data > RomArchive.MAX_ARCHIVE_BYTES then
      self:setError(("That .%s is %.1f MiB; a ROM archive only has to hold "
        .. "one small cart. Drop the raw ROM instead."):format(kind, #data / 1024 / 1024))
      return
    end
    local bytes, entry = RomArchive.unwrap(data, displayName, {
      isRomName = isRomFilename,
      acceptedSize = isAcceptedRomSize,
      prefer = function(candidate)
        return GameVersion.forSha1(sha1(candidate)) ~= nil
      end,
    })
    if not bytes then
      self:setError(entry)
      return
    end
    data = bytes
    displayName = displayName and (displayName .. " / " .. entry) or entry
  end
  if not isAcceptedRomSize(#data) then
    self:setError(("Expected a 1 MiB, 2 MiB, or 16 MiB ROM; this file is %.2f MiB.")
      :format(#data / 1024 / 1024))
    return
  end
  local actualHash = sha1(data)
  local version = GameVersion.forSha1(actualHash)
  if not version then
    self:setError(("Unsupported ROM (SHA-1 %s). Only clean, verified dumps of "
      .. "supported games are accepted."):format(actualHash))
    return
  end
  self.romSha1 = actualHash
  local info = GameVersion.info(version)
  self.importing = version
  self.workState = "working"
  self.status = "Preparing private game data"
  self.detail = displayName or info.displayName
  self.progress = 0
  self.romData = data

  -- Clear this version previous cache from both homes before anything writes.
  local CacheFs = require("src.import.CacheFs")
  local prefix = info.cachePrefix
  local savedPrefix = CacheFs.prefix
  CacheFs.prefix = prefix
  local cleared, clearError = pcall(function()
    removeTree(prefix .. "data/generated")
    removeTree(prefix .. "assets/generated")
    love.filesystem.remove(prefix .. CacheContract.MARKER_PATH)
    CacheFs.removeTree("data/generated")
    CacheFs.removeTree("assets/generated")
    CacheFs.remove(CacheContract.MARKER_PATH)
  end)
  CacheFs.prefix = savedPrefix
  if not cleared then
    self:setError(tostring(clearError), version)
    return
  end

  if self:_startExtractThread(version, prefix, data, displayName) then return end
  self:_startExtractCoroutine(version, info, prefix, displayName)
end

-- False when threads are unavailable, so the coroutine path still covers
-- that host.  POKEPORT_NO_THREAD=1 forces it.
function RomImport:_startExtractThread(version, prefix, data, displayName)
  if os.getenv("POKEPORT_NO_THREAD") == "1" then return false end
  if not (love.thread and love.thread.newThread) then return false end
  local ok, thread = pcall(love.thread.newThread, "src/import/ExtractThread.lua")
  if not ok or not thread then return false end
  local progressName = "rom_import_progress"
  local resultName = "rom_import_result"
  love.thread.getChannel(progressName):clear()
  love.thread.getChannel(resultName):clear()
  local started, startResult = pcall(thread.start, thread, version, prefix, data,
    progressName, resultName, self.romSha1)
  if not started or startResult == false then return false end
  self._extract = {
    thread = thread, version = version, prefix = prefix,
    displayName = displayName,
    progress = love.thread.getChannel(progressName),
    result = love.thread.getChannel(resultName),
  }
  self.romData = nil
  return true
end

function RomImport:_startExtractCoroutine(version, info, prefix, displayName)
  self.worker = coroutine.create(function()
    coroutine.yield()
    local CacheFs = require("src.import.CacheFs")
    CacheFs.prefix = prefix
    local manifest = require("src.import.RomManifest").decode(version)
    local gen = GameVersion.generation(version)
    local RomExtractor = gen == 3
      and require("src.import.RomExtractorGen3")
      or gen == 2
      and require("src.import.RomExtractorGen2")
      or require("src.import.RomExtractor")
    local extractor = RomExtractor.new(self.romData, manifest,
      function(progress, total, stage, current, stageTotal)
        self.status = stage
        self.progress = progress / total
        self.stageCurrent = current
        self.stageTotal = stageTotal
        coroutine.yield()
      end, self.romSha1)
    extractor:run()
    CacheFs.prefix = ""
    self.romData = nil
    collectgarbage("collect")
    self:_completeImport(version, prefix, displayName)
  end)
end

function RomImport:_rememberRomSource(version)
  local RomSources = require("src.import.RomSources")
  local source = self._importSource
  self._importSource = nil
  local rec = { sha1 = self.romSha1, at = os.time() }
  if RomSources.isAbsolute(source) then rec.path = source end
  RomSources.remember(version, rec)
end

-- Everything after the tree is filled, shared by both worker paths.
function RomImport:_completeImport(version, prefix, displayName)
  local info = GameVersion.info(version)
  local CacheFs = require("src.import.CacheFs")
  -- Written last: the marker is what isReady() checks.
  local savedPrefix = CacheFs.prefix
  CacheFs.prefix = prefix
  local ok, writeError = CacheContract.publish(version, CacheFs, self.romSha1)
  CacheFs.prefix = savedPrefix
  if not ok then
    error("could not finish the private cache: " .. tostring(writeError))
  end
  local SaveConvert = package.loaded["src.save_convert.SaveConvert"]
  if GameVersion.generation(version) == 2 and SaveConvert then
    SaveConvert.invalidateGen2Data(version)
  end
  pcall(self._rememberRomSource, self, version)
  self.importing = nil
  self.workState = "complete"
  self.completeVersion = version
  self.status = "Ready"
  self.detail = (displayName or info.displayName) .. " imported"
  self.progress = 1
  if self.onComplete then self.onComplete(version) end
end

-- Drain the worker progress and finish when it reports done.
function RomImport:_pumpExtract()
  local job = self._extract
  if not job then return end
  local msg = job.progress:pop()
  while msg do
    self.status = msg.stage
    self.progress = msg.progress / msg.total
    self.stageCurrent = msg.current
    self.stageTotal = msg.stageTotal
    msg = job.progress:pop()
  end
  local res = job.result:pop()
  if not res then
    local threadError = job.thread.getError and job.thread:getError()
    if threadError then
      self._extract = nil
      self:setError(tostring(threadError), job.version)
    end
    return
  end
  self._extract = nil
  if not res.ok then
    self:setError(tostring(res.error), job.version)
    return
  end
  local ok, err = pcall(self._completeImport, self, job.version, job.prefix,
    job.displayName)
  if not ok then self:setError(tostring(err), job.version) end
end

function RomImport:startPath(path)
  if not path then return end
  local data, readError = readExternalPath(path)
  if not data then
    self:setError("Could not read the selected file: " .. tostring(readError))
    return
  end
  self:startData(data, path:match("[^/\\]+$") or path,
    require("src.import.RomSources").absolute(path))
end

function RomImport:filedropped(file)
  if not file then return end
  local okOpen = pcall(file.open, file, "r")
  local data = okOpen and file:read() or nil
  pcall(file.close, file)
  local name = file.getFilename and file:getFilename() or nil
  self:startData(data, name and (name:match("[^/\\]+$") or name) or nil, name)
end

function RomImport:busy()
  return self.workState == "working"
end

function RomImport:update(dt)
  self:_pumpExtract()
  if self.worker then
    local ok, err = coroutine.resume(self.worker)
    if not ok then
      self.worker = nil
      self:setError(tostring(err), self.importing)
    elseif coroutine.status(self.worker) == "dead" then
      self.worker = nil
    end
  end
end

-- Plain progress readout for headless runs (no launcher UI).
function RomImport:draw()
  local g = love.graphics
  g.clear(0.05, 0.05, 0.08, 1)
  g.setColor(1, 1, 1, 1)
  g.print(tostring(self.status or "Importing"), 24, 24)
  if self.detail then g.print(tostring(self.detail), 24, 44) end
  g.print(("%d%%"):format(math.floor((self.progress or 0) * 100)), 24, 64)
end

-- Input is ignored by the headless importer.
local function noop() end
for _, name in ipairs({ "keypressed", "gamepadpressed", "gamepadreleased",
    "gamepadaxis", "joystickpressed", "joystickreleased", "joystickaxis",
    "joystickhat", "touchpressed", "touchmoved", "touchreleased",
    "mousepressed", "mousereleased", "mousemoved", "textinput", "focus" }) do
  RomImport[name] = noop
end

return RomImport
