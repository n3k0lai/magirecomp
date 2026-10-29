-- Magi-Nation boot: `love . --mn [--rom path] [--viewer] [--mn-test outdir [--mn-ui Name]]`.
-- Uses gen1recomp's StateStack; renders into a logical canvas (160x144 classic,
-- wider with the flex zoom, see mn.Viewport and docs/mn-viewport.md) scaled into
-- the window. --mn-test runs stay classic 160x144 unless MN_VIEW_SIM is set.
package.path = "src/?.lua;" .. package.path
local MnRom = require("mn.MnRom")
local Importer = require("mn.MnImporter")
local World = require("mn.World")
local bit = require("bit")
local StateStack = require("src.core.StateStack")
-- LICENSE.MD term 1: this boot screen is a front end and must carry the credit.
local Attribution = require("src.core.Attribution")
local Viewport = require("mn.Viewport")

local Boot = {}
io.stdout:setvbuf("no")
local frame, shot = 0, 0
function love.errorhandler(msg) print("[mn] ERROR " .. tostring(msg) .. "\n" .. debug.traceback()); os.exit(1) end
local opts = { rom = "roms/magination.gbc" }
for i, a in ipairs(arg or {}) do
  if a == "--rom" then opts.rom = arg[i + 1] end
  if a == "--viewer" then opts.viewer = true end
  if a == "--mn-test" then opts.test = arg[i + 1] end
  if a == "--mn-ui" then opts.ui = arg[i + 1] end
  if a == "--mn-music" then opts.music = tonumber(arg[i + 1]); opts.musicOut = arg[i + 2] end
end

local stack = setmetatable({}, { __index = StateStack }); stack:init()
local canvas, held

-- Viewport settings: MN_VIEW_ZOOM (0 classic, 1 fill, 2 wide, 3 wider),
-- MN_VIEW_PIXEL=0 (allow fractional scale), MN_VIEW_SIM=WxH (pretend the
-- window is WxH device pixels: headless fold / unfold renders),
-- MN_VIEW_WIN=1 (with MN_VIEW_SIM under --mn-test: also write the composed
-- WxH window as win_NNNN.png). F7 cycles the zoom, F8 toggles pixel-perfect,
-- a three-finger tap cycles the zoom on touch screens; both are saved to
-- mn_view.cfg in the save folder (never read or written by --mn-test runs).
local VIEW_CFG = "mn_view.cfg"
local simW, simH = Viewport.parseSize(os.getenv("MN_VIEW_SIM"))
local viewCfg, winCanvas
local function viewSettings()
  if viewCfg then return viewCfg end
  local saved
  if not opts.test and love.filesystem.getInfo(VIEW_CFG) then saved = love.filesystem.read(VIEW_CFG) end
  viewCfg = Viewport.settings(os.getenv, saved)
  if opts.test and not simW then viewCfg.zoom = 0 end -- harness frames stay 160x144
  return viewCfg
end
local function saveView()
  if opts.test then return end
  pcall(love.filesystem.write, VIEW_CFG, Viewport.serialize(viewCfg))
  print(("[mn] view zoom %d (%s) pixel %s"):format(viewCfg.zoom, Viewport.ZOOM_NAMES[viewCfg.zoom], tostring(viewCfg.pixel)))
end
function Boot.viewKey(k)
  local cfg = viewSettings()
  if k == "f7" then cfg.zoom = (cfg.zoom + 1) % (Viewport.ZOOMS + 1); saveView(); return true end
  if k == "f8" then cfg.pixel = not cfg.pixel; saveView(); return true end
  return false
end
function love.touchpressed()
  if love.touch and #love.touch.getTouches() == 3 then Boot.viewKey("f7") end
end

local CREDIT = "MagiRecomp - " .. Attribution.UPSTREAM_CREDIT
-- height (units) of the band under the game that carries the credit line
local function creditBand(w)
  if opts.test then return 0 end
  local font = love.graphics.getFont()
  local _, lines = font:getWrap(CREDIT, math.max(16, w - 16))
  return #lines * font:getHeight() + 12
end

-- window (or MN_VIEW_SIM) -> viewport: safe area minus the credit band, in
-- device pixels so the integer scale is pixel-perfect on high-dpi phones
local function layout()
  local cfg = viewSettings()
  local G = love.graphics
  local w, h = G.getDimensions()
  local dpi = G.getDPIScale and G.getDPIScale() or 1
  local sx, sy, sw, sh = 0, 0, w, h
  if simW then
    dpi, sw, sh = 1, simW, simH
  elseif love.window and love.window.getSafeArea then
    local okA, x, y, aw, ah = pcall(love.window.getSafeArea)
    if okA and type(aw) == "number" and aw > 0 and ah > 0 and aw <= w + 0.5 and ah <= h + 0.5 then sx, sy, sw, sh = x, y, aw, ah end
  end
  local band = creditBand(w)
  local v = Viewport.compute(sw * dpi, math.max(1, sh - band) * dpi, cfg)
  v.dpi, v.sx, v.sy, v.band, v.winW, v.winH = dpi, sx, sy, band, sw, sh
  return v
end

-- Continue: check_save_signature.asm then LoadSRAMScriptAndDispatch. A valid file
-- installs the active SRAM bank and starts the saved script triple. MN_NEWGAME=1
-- skips that. data is the raw slot file; nil starts a new game.
local function continueFromSave(ow, data)
  if os.getenv("MN_NEWGAME") == "1" then return false end
  if not data or data == "" then return false end
  local SaveFile = require("mn.SaveFile")
  local Save = require("mn.ops.Save")
  local banks = SaveFile.decode(data)
  if not banks then return false end
  local accepted, w = SaveFile.accept(banks, Save.romStamp(ow.vm))
  if not accepted then
    ow.log[#ow.log + 1] = "save rejected"
    return false
  end
  Save.install(ow.vm, accepted, w)
  local b, p, x, y = Save.resume(ow.vm)
  ow.vm.pair = { x, y }
  ow.vm:wr8(0xC9A1, x)
  ow.vm:wr8(0xC9A2, y)
  if p == 0 then return false end
  ow:runScript(b, p, "continue")
  return true
end

local function readSaveFile(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  return data
end

local function ensureCache()
  if Importer.isCached() then print("[mn] cache ok"); return end
  local f = assert(io.open(opts.rom, "rb"), "no ROM at " .. opts.rom)
  local bytes = f:read("*a"); f:close()
  print("[mn] importing " .. opts.rom)
  assert(Importer.import(bytes, function(s) print("[mn] " .. s) end))
  bytes = nil; collectgarbage()
end

-- Headless test planner: path to targets with BFS, press A on talk cells.
-- States are (cell, head family): World.moves gives every cell one press
-- reaches, so hops and $01/$02 layer walks are planned like plain steps.
local DIRNAME = { ["1,0"] = "right", ["-1,0"] = "left", ["0,1"] = "down", ["0,-1"] = "up" }
local function bfs(def, sx, sy, goal, layer, vm)
  local n = def.w * def.h
  local gates, mark = World.gatesFor(vm, layer), World.mark(vm)
  local s0 = (layer or 0) * n + sy * def.w + sx
  local prev, q, h = { [s0] = -1 }, { { sx, sy, layer } }, 1
  local found, fk
  while h <= #q do
    local x, y, l = q[h][1], q[h][2], q[h][3]; h = h + 1
    -- no goal on the $02 heads: they keep sliding past it (01:4F0D never reads the held pad)
    if l ~= 2 and goal(x, y) and not (x == sx and y == sy) then found = { x, y }; fk = (l or 0) * n + y * def.w + x; break end
    local k0 = (l or 0) * n + y * def.w + x
    for _, m in ipairs(World.moves(def, x, y, l, mark, gates)) do
      local k = (m[3] or 0) * n + m[2] * def.w + m[1]
      if not prev[k] then prev[k] = { k0, DIRNAME[m[4] .. "," .. m[5]] }; q[#q + 1] = { m[1], m[2], m[3] } end
    end
  end
  if not found then return nil end
  local k, path = fk, {}
  while prev[k] ~= -1 do table.insert(path, 1, prev[k][2]); k = prev[k][1] end
  return path, found
end
local Planner = {}
function Planner.new(ow) return setmetatable({ ow = ow, q = {}, phase = "door", tried = {} }, { __index = Planner }) end
function Planner:isTalk(x, y)
  local ow = self.ow
  if self.tried[y * 1000 + x] then return false end
  for _, ob in pairs(ow.objects) do if ob.x == x and ob.y == y and ob.talk then return true end end
  local v = World.cell(ow.def, x, y)
  return v < 0x80 and bit.band(v, 0x60) ~= 0 and ow.aList and ow:listEntry(ow.aList, v - 0x40) ~= nil
end
function Planner:plan()
  local ow, def = self.ow, self.ow.def
  if self.phase == "door" then
    local dirs = { [1] = "up", [2] = "down", [3] = "right", [4] = "left" }
    local path, goal = bfs(def, ow.x, ow.y, function(x, y)
      local v = World.cell(def, x, y)
      if v < 0xC0 or not ow.triggerPtr or self.tried[y * 1000 + x] then return false end
      local to = ow:triggerTo(v % 64)
      return to ~= nil and to ~= ow.map
    end, ow.layer, ow.vm)
    if goal then self.tried[goal[2] * 1000 + goal[1]] = true end
    if path then
      -- remember goal so we don't loop on a trigger that does nothing
      self.q = path; return
    end
  elseif self.phase == "talk" then
    for _, f in ipairs({ { 0, -1, "up" }, { 0, 1, "down" }, { -1, 0, "left" }, { 1, 0, "right" } }) do
      if self:isTalk(ow.x + f[1], ow.y + f[2]) then
        self.tried[(ow.y + f[2]) * 1000 + ow.x + f[1]] = true
        self.q = { f[3] .. "!", "A" }; return
      end
    end
    local path = bfs(def, ow.x, ow.y, function(x, y)
      for _, f in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
        if self:isTalk(x + f[1], y + f[2]) then return true end
      end
    end, ow.layer, ow.vm)
    if path then self.q = path else self.phase = "door"; self.dbg = nil end
  end
end
function Planner:input(kind)
  local ow = self.ow
  if ow.textBox then
    self.textFrames = (self.textFrames or 0) + 1
    if kind == "a" and self.textFrames % 90 == 0 then return true end
    return nil
  end
  if os.getenv("MN_IDLE_ON") and ow.map == tonumber(os.getenv("MN_IDLE_ON")) then return nil end
  if #self.q == 0 then if kind == "dir" then self:plan() end; return nil end
  local h = self.q[1]
  if h == "A" then if kind == "a" then table.remove(self.q, 1); return true end; return nil end
  if kind ~= "dir" then return nil end
  table.remove(self.q, 1)
  if h:sub(-1) == "!" then ow.facing = h:sub(1, -2); return nil end
  return h
end

function love.load()
  ensureCache()
  if os.getenv("MN_SAMPLE_OUT") then
    local MnMusic, rom = require("mn.MnMusic"), Importer.scriptRom()
    local rd = function(b, p) return rom:u8(MnRom.off(p, b)) end
    local smp = MnMusic.sample(rd, 22050)
    local sd = love.sound.newSoundData(#smp, 22050, 16, 1)
    for i, v in ipairs(smp) do sd:setSample(i - 1, v) end
    local raw = sd:getString(); local n = #raw
    local function le(v, k) local t = {} for j = 1, k do t[j] = string.char(v % 256); v = math.floor(v / 256) end return table.concat(t) end
    local f = assert(io.open(os.getenv("MN_SAMPLE_OUT"), "wb"))
    f:write("RIFF", le(36 + n, 4), "WAVEfmt ", le(16, 4), le(1, 2), le(1, 2), le(22050, 4), le(44100, 4), le(2, 2), le(16, 2), "data", le(n, 4), raw); f:close()
    print("[mn-sample] " .. #smp .. " samples"); love.event.quit(0); return
  end
  if opts.music then -- render one song to WAV: --mn-music <index> <out.wav>
    local MnMusic, rom = require("mn.MnMusic"), Importer.scriptRom()
    local rd = function(b, p) return rom:u8(MnRom.off(p, b)) end
    local song = MnMusic.decode(rd, opts.music, 60)
    local rate = 22050
    local sd = love.sound.newSoundData(math.floor(song.length * rate) + 1, rate, 16, 1)
    if os.getenv("MN_SYNTH") == "simple" then MnMusic.render(song, rate, function(i, v) sd:setSample(i, v) end)
    else MnMusic.renderGB(song, rate, function(i, v) sd:setSample(i, v) end, rd) end
    local seen = {}
    if os.getenv("MN_EARLY") then for _, nt in ipairs(song.notes) do if nt.t < 2 then print(("[mn-early] t=%.3f inst $%02X note %d len %.3f slot %d"):format(nt.t, nt.inst, nt.note, nt.len, nt.slot)) end end end
    for _, nt in ipairs(song.notes) do
      if not seen[nt.inst] then
        seen[nt.inst] = true
        local ins = MnMusic.instrument(rd, nt.inst)
        print(("[mn-music] inst $%02X ch%d duty%d vol%d noise=%s hold=%s ev=%d"):format(nt.inst, ins.ch, ins.duty, ins.vol, ins.noise and ("%02X"):format(ins.noise) or "-", tostring(ins.hold), #ins.ev))
      end
    end
    local raw = sd:getString(); local n = #raw
    local function le(v, k) local t = {} for j = 1, k do t[j] = string.char(v % 256); v = math.floor(v / 256) end return table.concat(t) end
    local f = assert(io.open(opts.musicOut, "wb"))
    f:write("RIFF", le(36 + n, 4), "WAVEfmt ", le(16, 4), le(1, 2), le(1, 2), le(rate, 4), le(rate * 2, 4), le(2, 2), le(16, 2), "data", le(n, 4), raw)
    f:close()
    print(("[mn-music] song %d bank %02X:%04X tempo %d notes %d length %.1fs -> %s"):format(opts.music, song.bank, song.ptr, song.tempo, #song.notes, song.length, opts.musicOut))
    local lo, hi = {}, {}
    for _, nt in ipairs(song.notes) do local k = nt.slot; lo[k] = math.min(lo[k] or 999, nt.note); hi[k] = math.max(hi[k] or 0, nt.note) end
    for k = 0, 3 do if lo[k] then print(("[mn-music] slot %d notes %d-%d"):format(k, lo[k], hi[k])) end end
    love.event.quit(0); return
  end
  canvas = love.graphics.newCanvas(160, 144); canvas:setFilter("nearest", "nearest")
  local Overworld = require("mn.Overworld")
  if opts.ui and opts.test then
    -- UI harness: `--mn-ui Name --mn-test outdir` runs src/mn/ui/Name.lua as the only
    -- screen over an Overworld at MN_START (no entry script). MN_KEYS="w30,down,a,start"
    -- feeds one key per token (wN waits N frames), held for one frame. Ends when the
    -- screen's update returns a result or after MN_FRAMES (default 600) frames.
    local def = Importer.loadMap(tonumber(os.getenv("MN_START") or "1"))
    local sp = def.entries[1] and def.entries[1].spawn or { x = 1, y = 1 }
    local q = {}
    for tok in (os.getenv("MN_KEYS") or ""):gmatch("[^,]+") do q[#q + 1] = tok end
    local qi, waitN, cur = 1, 0, nil
    local DIR = { up = true, down = true, left = true, right = true }
    local function input(kind)
      if kind == "dir" then return DIR[cur] and cur or nil end
      return cur == kind
    end
    local ow = Overworld.new(tonumber(os.getenv("MN_START") or "1"), sp.x, sp.y, input)
    local ctx = { rom = ow.vm.rom, vm = ow.vm, ow = ow, input = input, log = ow.log }
    local scr = require("mn.ui." .. opts.ui).new(ctx)
    scr.map = scr.map or ow.map
    local inner = scr.update
    scr.update = function(self) local r = inner(self); if r ~= nil then self.result = r end; return r end
    stack:push(scr)
    Boot.keyTick = function()
      cur = nil
      if waitN > 0 then waitN = waitN - 1; return end
      local tok = q[qi]
      if not tok then return end
      qi = qi + 1
      local n = tok:match("^w(%d+)$")
      if n then waitN = tonumber(n) else cur = tok; waitN = 6 end
    end
    local ended = false
    Boot.testDone = function()
      if ended then return false end
      if scr.result == nil and frame <= tonumber(os.getenv("MN_FRAMES") or "600") then return false end
      ended = true
      local r = scr.result
      if type(r) == "table" then
        local t = {}
        for k, v in pairs(r) do t[#t + 1] = tostring(k) .. "=" .. tostring(v) end
        table.sort(t); r = "{" .. table.concat(t, " ") .. "}"
      end
      print(("[mn-ui] %s result %s at frame %d"):format(opts.ui, tostring(r), frame))
      for _, l in ipairs(ow.log) do print("[mn-ui] " .. l) end
      for _, l in ipairs(ow.vm.log) do print("[mn-ui] " .. l) end
      love.event.quit(0)
      return false
    end
  elseif opts.test and os.getenv("MN_TITLE") ~= "1" then
    -- MN_SEED (harness only) also seeds love.math: wild-monster scatter and random record
    -- picks then replay, so a route leg that needs a wild battle (the ferry fare) is repeatable
    local seedEnv = tonumber(os.getenv("MN_SEED") or "")
    if seedEnv then love.math.setRandomSeed(seedEnv) end
    local start = tonumber(os.getenv("MN_START") or "1")
    local def = Importer.loadMap(start); local e = def.entries[tonumber(os.getenv("MN_START_ENTRY") or "1")] -- MN_START_ENTRY (harness): which entry script starts the run
    local planner
    -- MN_ROUTE="220:up,221:right": hold a direction while in that map (A every 20 frames)
    local route = {}
    -- "40:12.0" walks to cell 12,0 (BFS around walls and objects)
    local goals = {}
    -- "54:7.3|3.9": successive goals on successive entries into that map
    -- "...,@61,2:5.5,...": entries after "@61" only take effect once map 61 has been entered
    -- "@43#2,...": only once map 43 has been entered twice (door crossings counted by testDone)
    local routeStr = os.getenv("MN_ROUTE") or ""
    local lateKey, lateN, lateStr = routeStr:match("@(%d+)#?(%d*),(.*)$")
    lateN = tonumber(lateN) or 1
    if lateKey then routeStr = routeStr:gsub("@%d+#?%d*,.*$", "") end
    local entered = {}
    local function parseRoute(str, route, goals)
    for m, d in str:gmatch("(%d+):([%w%.|>]+)") do
      if d:match("^%d+%.%d+") then
        -- "a|b" = goal per entry; "a>b" within one entry = next goal once a talk at a has ended
        local list = {}
        for vis in d:gmatch("[^|]+") do
          local steps = {}
          for gx, gy, f in vis:gmatch("(%d+)%.(%d+)([udlr]?)") do steps[#steps + 1] = { tonumber(gx), tonumber(gy), face = ({ u = "up", d = "down", l = "left", r = "right" })[f] } end
          list[#list + 1] = steps
        end
        route[tonumber(m)] = "far"; goals[tonumber(m)] = list
      else route[tonumber(m)] = d end
    end
    end
    parseRoute(routeStr, route, goals)
    local visits = {}
    local ow
    local mkOw = os.getenv("MN_LOAD") and function(_, _, _, fn) return Overworld.load(os.getenv("MN_LOAD"), fn) end or Overworld.new
    ow = mkOw(start, 0, 0, function(k)
      if lateKey and ow and ow.map == tonumber(lateKey) and (lateN <= 1 or (entered[ow.map] or 0) >= lateN) then
        -- switch to the late route: its maps restart their visit counts
        local r2, g2 = {}, {}; parseRoute(lateStr, r2, g2)
        for m2, v in pairs(r2) do route[m2] = v; goals[m2] = g2[m2]; visits[m2] = nil end
        lateKey = nil
      end
      local d = ow and route[ow.map]
      -- a shop list ($90 SetupPrefixedBlockChoice) opened by a talk: a route buys nothing, it
      -- leaves with B (cancel, slot $FE) so the talk script goes on past the shop
      if d and ow.overlay and ow.overlay.mode == "90" then
        if k == "b" then return frame % 20 == 10 end
        return nil
      end
      -- routes only press A and directions; a direction returned for "start" would open the menu
      if d and k ~= "a" and k ~= "dir" then return nil end
      -- MN_HOLD="63:900": no route input for the first n frames of each entry into that map (cutscenes)
      if ow and os.getenv("MN_HOLD") then
        if ow.holdMap ~= ow.map then ow.holdMap, ow.holdFrom = ow.map, frame end
        for hm, hn in os.getenv("MN_HOLD"):gmatch("(%d+):(%d+)") do
          if tonumber(hm) == ow.map and frame - ow.holdFrom < tonumber(hn) then
            if k == "a" then return ow.textBox ~= nil and frame % 20 == 0 end
            return nil
          end
        end
      end
      if d == "chase" then -- walk onto a live encounter record ($65A4 handler)
        if k == "a" then return ow.textBox ~= nil and frame % 20 == 0 end
        if ow.textBox or ow.moving then return nil end
        local W = require("mn.World")
        local tgt
        for _, ob in pairs(ow.objects) do if ob.handler == 0x65A4 and not ob.dormant then tgt = ob end end
        if not tgt then return nil end
        local def, prev, q, h = ow.def, { [ow.y * ow.def.w + ow.x] = -1 }, { { ow.x, ow.y } }, 1
        while h <= #q do
          local c = q[h]; h = h + 1
          if c[1] == tgt.x and c[2] == tgt.y then
            local id = c[2] * def.w + c[1]; local first = c
            while prev[id] ~= -1 do local pid = prev[id]; if pid == ow.y * def.w + ow.x then break end; id = pid; first = { id % def.w, math.floor(id / def.w) } end
            if first[1] > ow.x then return "right" elseif first[1] < ow.x then return "left" elseif first[2] < ow.y then return "up" else return "down" end
          end
          for _, dd in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
            local nx, ny = c[1] + dd[1], c[2] + dd[2]; local nid = ny * def.w + nx
            if nx >= 0 and ny >= 0 and nx < def.w and ny < def.h and not prev[nid] and W.walkable(W.cell(def, nx, ny)) and W.cell(def, nx, ny) < 0xC0 then
              prev[nid] = c[2] * def.w + c[1]; q[#q + 1] = { nx, ny }
            end
          end
        end
        return nil
      end
      if d == "far" then -- BFS to the reachable trigger cell farthest from where control began
        local W = require("mn.World")
        -- a bracelet kick (no text box) counts as a talk for ">" chains
        -- only on the goal cell: a scene's box on the way (249 18,5 pirate scene) must not end a ">" goal unpressed
        if require("mn.boot.RouteGoal").talkEndsGoal(ow) then ow.talkSeen = 0; ow.kickSeen = nil end
        if not ow.objects[0] and not ow.textBox then
          local key = ow.map .. ":" .. (ow.farGoalFor or "")
          if ow.farMap ~= ow.map then
            if ow.farMap ~= nil or not ow.replan then visits[ow.map] = (visits[ow.map] or 0) + 1; ow.step = 1; ow.talkSeen = nil end
            ow.replan = nil
            ow.farMap = ow.map
            local def = ow.def
            -- with Crystal Gloves ($A3A3 >= 2) a dig wall ($0B) is a step: face it and press A (Kick.try)
            local canDig = ow.vm and ow.vm:rd8(0xA3A3) >= 2
            local avoidPads = false
            local n = def.w * def.h
            local function search(crossDoors)
            -- states are (cell, head family) so $01/$02 layer walks are routed (World.step)
            local gates, mark = W.gatesFor(ow.vm, ow.layer), W.mark(ow.vm)
            local s0 = (ow.layer or 0) * n + ow.y * def.w + ow.x
            local prev, q, h = {}, { { ow.x, ow.y, ow.layer } }, 1
            prev[s0] = -1
            local best, bd, dist, hadGoal = nil, -1, { [s0] = 0 }
            while h <= #q do
              local c = q[h]; h = h + 1
              local id = (c[3] or 0) * n + c[2] * def.w + c[1]
              local gl = goals[ow.map]; local vl = gl and gl[math.min(visits[ow.map] or 1, #gl)]
              local g = vl and vl[math.min(ow.step or 1, #vl)]
              -- never stop on the $02 heads: they keep sliding (01:4F0D never reads the held pad)
              if g then hadGoal = true; ow.farFace = g.face; if c[3] ~= 2 and c[1] == g[1] and c[2] == g[2] then best, bd = c, dist[id] end
              elseif c[3] ~= 2 and W.cell(def, c[1], c[2]) >= 0xC0 and dist[id] > bd then best, bd = c, dist[id] end
              for _, dd in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
                local nx, ny = c[1] + dd[1], c[2] + dd[2]
                local occ = false
                -- same rule as the player's own step (World.blocks: only a live record on a $00 cell)
                for k, ob in pairs(ow.objects) do if k ~= 0 and W.blocks(def, ob, nx, ny) then occ = true end end
                -- a goal route steps around a live $65A4 step-on record unless it is the goal
                -- (277 37,8 runs the Shadow Geyser scene on every crossing while story is 3..5)
                if g then for oi, ob in pairs(ow.objects) do if oi ~= 0 and ob.handler == 0x65A4 and not ob.dormant and ob.x == nx and ob.y == ny and not (g[1] == nx and g[2] == ny) then occ = true end end end
                -- a goal route also steps around other doors (279 32,26 crossed the 74/75 door at 19-20,22)
                if g and not crossDoors and nx >= 0 and ny >= 0 and nx < def.w and ny < def.h then
                  local v = W.cell(def, nx, ny)
                  local t = v >= 0xC0 and def.triggers[bit.band(v, 0x3F) + 1]
                  -- only map doors; event lines (to = -1, e.g. 110 5-9,17) must stay crossable
                  if t and (t.to or -1) >= 0 and v ~= W.cell(def, g[1], g[2]) then occ = true end
                  -- MN_AVOIDPADS=1 (harness, geyser dungeon): also step around other trigger cells,
                  -- so a gate-color pad off the planned chain does not change $A224 mid-leg
                  if avoidPads and v >= 0xC0 and not (g[1] == nx and g[2] == ny) then occ = true end
                end
                -- a goal on a direction-gated step trigger (kind 1-4, World.gate) is only entered
                -- the way it fires (241 6-7,6 to 255 is kind 1: from below, moving up)
                if g and g[1] == nx and g[2] == ny and ow.triggerPtr and ow.listEntry then
                  local v = W.cell(def, nx, ny)
                  if v >= 0xC0 then
                    local k = ow:listEntry(ow.triggerPtr, bit.band(v, 0x3F))
                    if k and not W.gate(k, dd[1], dd[2]) then occ = true end
                  end
                end
                if nx >= 0 and ny >= 0 and nx < def.w and ny < def.h and not occ then
                  local lx, ly, ll
                  if c[3] == nil and canDig and W.cell(def, nx, ny) == 0x0B then lx, ly = nx, ny
                  else lx, ly, ll = W.step(def, c[1], c[2], dd[1], dd[2], c[3], mark, gates[c[3] or 0]) end
                  local lid = lx and ((ll or 0) * n + ly * def.w + lx)
                  if lid and not prev[lid] then prev[lid] = id; dist[lid] = dist[id] + 1; q[#q + 1] = { lx, ly, ll } end
                end
              end
            end
            return best, prev, hadGoal
            end
            -- other doors are stepped around; when one is the only connector (279 19-20,22 is the
            -- town-74 icon, a kind-0 trigger that always enters 74) cross it as a last resort
            local best, prev, hadGoal
            if os.getenv("MN_AVOIDPADS") == "1" then avoidPads = true; best, prev, hadGoal = search(false); avoidPads = false end
            if not best then best, prev, hadGoal = search(false) end
            if not best and hadGoal then
              best, prev = search(true)
              if best then ow.log[#ow.log + 1] = "route far: goal only reachable across another door" end
            end
            ow.farPath = {}
            if best then
              local id = (best[3] or 0) * n + best[2] * def.w + best[1]
              while prev[id] and prev[id] ~= -1 do local cid = id % n; table.insert(ow.farPath, 1, { cid % def.w, math.floor(cid / def.w) }); id = prev[id] end
              ow.log[#ow.log + 1] = ("route far -> %d,%d (%d steps)"):format(best[1], best[2], #ow.farPath)
            elseif hadGoal then ow.log[#ow.log + 1] = ("route far: no path from %d,%d"):format(ow.x, ow.y)
            end
          end
          if ow.farFace and ow.farPath and #ow.farPath == 0 then -- at the goal: face and press A (talk / counter cell)
            -- a ">" chain: once a talk ran here and the box has been gone 90 frames, take the next goal
            local gl = goals[ow.map]; local vl = gl and gl[math.min(visits[ow.map] or 1, #gl)]
            if vl and (ow.step or 1) < #vl then
              local th = ow.vm.threads
              local busy = ow.textBox or (th and th.talk and coroutine.status(th.talk.co) ~= "dead")
              if busy then ow.talkSeen = 0 elseif ow.talkSeen then ow.talkSeen = ow.talkSeen + 1 end
              if ow.talkSeen and ow.talkSeen > 90 then ow.step = (ow.step or 1) + 1; ow.talkSeen = nil; ow.farMap = nil; ow.replan = true; return nil end
            end
            -- press A only once turned: a step that ends facing a counter would read it first (225 9,4)
            if k == "a" then return frame % 30 == 0 and ow.facing == ow.farFace and not (ow.talkSeen and vl and (ow.step or 1) < #vl) end
            -- turn only when needed: a press toward an open cell would walk off the goal
            if k == "dir" and not ow.talkSeen and ow.facing ~= ow.farFace then return ow.farFace end
            return nil
          end
          -- a ">" chain of plain cells (no face): once on the goal and idle 30 frames
          -- (a floor pad's script has run, e.g. 125 16,48 opens the row-46 gate), take the next goal
          if not ow.farFace and ow.farPath and #ow.farPath == 0 then
            local gl = goals[ow.map]; local vl = gl and gl[math.min(visits[ow.map] or 1, #gl)]
            local g = vl and vl[math.min(ow.step or 1, #vl)]
            if g and g[1] == ow.x and g[2] == ow.y and (ow.step or 1) < #vl then
              if ow.textBox or ow.moving or ow.scriptWaiting then ow.padIdle = 0 else ow.padIdle = (ow.padIdle or 0) + 1 end
              if ow.padIdle > 30 then ow.padIdle = nil; ow.step = (ow.step or 1) + 1; ow.farMap = nil; ow.replan = true; ow.log[#ow.log + 1] = ("route far: pad %d,%d done, goal %d"):format(ow.x, ow.y, ow.step) end
              if k == "a" then return ow.textBox ~= nil and frame % 20 == 0 end
              return nil
            end
          end
          -- next path cell is a dig wall: turn toward it (a bump only turns), then A digs it
          local dn = ow.farPath and ow.farPath[1]
          if dn and dn[1] == ow.x and dn[2] == ow.y then dn = ow.farPath[2] end
          if dn and W.cell(ow.def, dn[1], dn[2]) == 0x0B then
            local dd = dn[1] > ow.x and "right" or dn[1] < ow.x and "left" or dn[2] < ow.y and "up" or "down"
            if k == "a" then return ow.facing == dd and not ow.moving and frame % 15 == 0 end
            if ow.facing ~= dd then return dd end
            return nil
          end
          if k == "a" then return false end
          -- parked on the goal trigger cell (a scene fired on arrival, list since swapped):
          -- step off and come back so the new list entry fires
          if ow.farPath and #ow.farPath == 0 and not ow.farFace and W.cell(ow.def, ow.x, ow.y) >= 0xC0 then
            ow.idleAt = (ow.idleAt or 0) + 1
            if ow.idleAt > 90 then
              ow.idleAt = 0; ow.farMap = nil; ow.replan = true
              for _, dd in ipairs({ { 1, 0, "right" }, { -1, 0, "left" }, { 0, 1, "down" }, { 0, -1, "up" } }) do
                if W.walkable(W.cell(ow.def, ow.x + dd[1], ow.y + dd[2])) and W.cell(ow.def, ow.x + dd[1], ow.y + dd[2]) < 0xC0 then return dd[3] end
              end
            end
            return nil
          end
          -- stuck (an object stepped into the path): re-plan around objects
          if ow.lastPos == ow.x * 1000 + ow.y then ow.stuck = (ow.stuck or 0) + 1 else ow.stuck = 0; ow.lastPos = ow.x * 1000 + ow.y end
          if ow.stuck > 60 and os.getenv("MN_STUCKDBG") then local n = ow.farPath and ow.farPath[1]; local tw = {}; for k2, t in pairs(ow.vm and ow.vm.threads or ow.threads or {}) do tw[#tw + 1] = tostring(k2) end; print(("stuck at %d,%d next %s talk=%s box=%s threads=%s"):format(ow.x, ow.y, n and (n[1] .. "," .. n[2]) or "-", tostring(ow.talkThread ~= nil), tostring(ow.textBox ~= nil), table.concat(tw, " "))); local ol = {}; for oi, ob in pairs(ow.objects) do ol[#ol + 1] = ("%s@%s,%s%s"):format(tostring(oi), tostring(ob.x), tostring(ob.y), ob.dormant and "z" or "") end; print("  objs " .. table.concat(ol, " ") .. (" cell26,3=%02X"):format(require("mn.World").cell(ow.def, 26, 3)))
            -- the live cell window around Tony (once per stuck spell), so a sealed seam shows up in the log
            if ow.stuck == 61 then local Wd = require("mn.World"); for yy = ow.y - 5, ow.y + 5 do local row = {}; for xx = ow.x - 7, ow.x + 7 do row[#row + 1] = (xx < 0 or yy < 0) and ".." or ("%02X"):format(Wd.cell(ow.def, xx, yy) or 0) end; print(("  y%3d %s"):format(yy, table.concat(row, " "))) end end end
          if ow.stuck > 60 then ow.stuck = 0; ow.farMap = nil; ow.replan = true; return nil end
          local nxt = ow.farPath and ow.farPath[1]
          if nxt and nxt[1] == ow.x and nxt[2] == ow.y then table.remove(ow.farPath, 1); nxt = ow.farPath[1] end
          if not nxt then return nil end
          if nxt[1] > ow.x then return "right" elseif nxt[1] < ow.x then return "left" elseif nxt[2] < ow.y then return "up" else return "down" end
        end
        if k == "a" then return frame % 20 == 0 end
        return nil
      elseif d then if k == "a" then return frame % 20 == 0 end; return d end
      return planner:input(k)
    end)
    planner = Planner.new(ow); Boot.planner = planner
    ow.vm.autoPick = not os.getenv("MN_CHOOSE") -- autopilot answers $9C menus itself
    if os.getenv("MN_TALK") then planner.phase = "talk" end
    -- MN_SAVE_LOAD resumes a slot file the way Continue does. The autopilot is unchanged.
    local saveLoad = os.getenv("MN_SAVE_LOAD")
    local resumed = saveLoad and saveLoad ~= "" and continueFromSave(ow, readSaveFile(saveLoad))
    if not resumed and not os.getenv("MN_LOAD") then ow:runScript(e.bank, e.ptr, "map entry") end
    stack:push(ow)
    local startMap = ow.map
    Boot.testDone = function(s)
      if s.map ~= startMap and not s.moving and not s.scriptWaiting then startMap = s.map; entered[s.map] = (entered[s.map] or 0) + 1; planner.phase = "talk"; planner.q = {}; s.log[#s.log + 1] = ("door crossed -> map %d at %d,%d"):format(s.map, s.x, s.y) end
      if s.textBox and not planner.inBox then planner.inBox = true; planner.boxes = (planner.boxes or 0) + 1 end
      if not s.textBox and planner.inBox then planner.inBox = false end
      if (planner.boxes or 0) >= 2 and not s.textBox then planner.after = (planner.after or 0) + 1 end
      local done
      if os.getenv("MN_FRAMES") then done = frame > tonumber(os.getenv("MN_FRAMES"))
      else done = (planner.after or 0) > 20 or frame > 8000 end
      if s.frameSnapshot then s:frameSnapshot(frame, done) end
      return done
    end
  elseif opts.viewer then
    stack:push(require("mn.Viewer").new(0))
  else
    -- keyboard path: Z/Enter = A, X/Backspace = B, arrows; key state is tracked from
    -- keypressed/keyreleased events so MN_KEYS (scripted events) drives the same code as real keys
    local startMap = tonumber(os.getenv("MN_BATTLE_TEST") and "3" or "0")
    local def = Importer.loadMap(startMap); local sp = def.entries[1] and def.entries[1].spawn or { x = 1, y = 1 }
    local pressed, held = {}, {}
    local AK = { z = "a", ["return"] = "a", x = "b", backspace = "b", space = "start", rshift = "select" }
    function love.keypressed(k) if Boot.viewKey(k) then return end; held[k] = true; if AK[k] then pressed[AK[k]] = true end end
    function love.keyreleased(k) held[k] = nil end
    local mkOw = os.getenv("MN_LOAD") and function(_, _, _, fn) return Overworld.load(os.getenv("MN_LOAD"), fn) end or Overworld.new
    local ow = mkOw(startMap, sp.x, sp.y, function(kind)
      if kind == "a" or kind == "b" or kind == "start" or kind == "select" then local p = pressed[kind]; pressed[kind] = false; return p end
      for _, k in ipairs({ "up", "down", "left", "right" }) do if held[k] or love.keyboard.isDown(k) then return k end end
    end)
    if not os.getenv("MN_LOAD") and not os.getenv("MN_BATTLE_TEST") then
      -- Keyboard default with no slot file, and --mn-test with MN_TITLE=1:
      -- Reset's script 22:418E. A slot file keeps Continue for now.
      -- MN_NEWGAME keeps today's Continue call (a no-op). A valid
      -- slot is installed and not resumed; MN_SAVE_LOAD overrides the slot.
      local Title = require("mn.boot.Title")
      local data
      if os.getenv("MN_NEWGAME") ~= "1" then
        local alt = os.getenv("MN_SAVE_LOAD")
        if alt and alt ~= "" then data = readSaveFile(alt) end
        if not data and love.filesystem and love.filesystem.read then
          data = love.filesystem.read(require("mn.SaveFile").PATH)
        end
      end
      if Title.choose(os.getenv, opts, data ~= nil and data ~= "") == "title" then
        Title.start(ow, data)
        Boot.title = true
      else
        continueFromSave(ow, data)
      end
    end
    stack:push(ow)
    if opts.test then
      Boot.testDone = function()
        return frame > tonumber(os.getenv("MN_FRAMES") or "600")
      end
    end
    if os.getenv("MN_BATTLE_TEST") then -- the map-3 Weebo encounter ($2E 09 53 01), straight into battle
      ow.battle = require("mn.Battle").new(ow, { ops = { { op = 0x2E, args = { 0x09, 0x53, 0x01 } } } })
    end
    -- MN_KEYS="w60,z,w20,down,left:16,..." : wN waits N frames, a key name is pressed for 4 frames (name:N holds it N frames)
    local keys = os.getenv("MN_KEYS")
    if keys then
      local q = {}; for tok in keys:gmatch("[^,]+") do q[#q + 1] = tok end
      local qi, waitN, rel = 1, 0, nil
      Boot.keyTick = function()
        if rel then rel[2] = rel[2] - 1; if rel[2] <= 0 then love.event.push("keyreleased", rel[1], rel[1], false); rel = nil end end
        if waitN > 0 then waitN = waitN - 1; return end
        local tok = q[qi]
        if not tok then
          if opts.test then return end
          if not Boot.keysDone then Boot.keysDone = frame; print("[mn-keys] script done at frame " .. frame) end
          if frame - Boot.keysDone > tonumber(os.getenv("MN_KEYS_TAIL") or "120") then
            for _, l in ipairs(ow.log) do print("[mn-keys] " .. l) end
            love.event.quit(0)
          end
          return
        end
        qi = qi + 1
        local n = tok:match("^w(%d+)$")
        if n then waitN = tonumber(n)
        else
          local name, hold = tok:match("^(.-):(%d+)$") -- "left:16" holds the key 16 frames
          tok = name or tok; hold = tonumber(hold) or 4
          local alias = { a = "z", b = "x", start = "space", select = "rshift" }
          tok = alias[tok] or tok
          love.event.push("keypressed", tok, tok, false); rel = { tok, hold }; waitN = hold + 2
        end
      end
    end
  end
end


function love.update()
  if Boot.keyTick then Boot.keyTick() end
  local s = stack:top(); if s.update then s:update() end
  frame = frame + 1
  if opts.test and Boot.testDone(s) then
    if s.def then
      local W = require("mn.World")
      print(("[mn-test] final player %d,%d map %d hide=%s box=%s vmwait=%s moving=%s sw=%s tw=%s"):format(s.x, s.y, s.map, tostring(s.hidePlayer), tostring(s.textBox and (tostring(s.textBox.done) .. "/" .. tostring(s.textBox.wait) .. "/" .. tostring(s.textBox.owner and coroutine.status(s.textBox.owner)))), tostring(s.vm.wait), tostring(s.moving), tostring(s.scriptWaiting), tostring(s.vm.textWait)))
      do local o = s.vm.pcs and s.vm.co and s.vm.pcs[s.vm.co]; print(("[mn-test] main vm pc %s"):format(o and ("%02X:%04X op %02X"):format(math.floor(o / 0x4000), o % 0x4000 + 0x4000, s.vm.rom:u8(o)) or "?")) end
      for yy = s.y - 3, s.y + 1 do local t = {} for xx = s.x - 3, s.x + 3 do t[#t + 1] = ("%02X"):format(W.cell(s.def, xx, yy) or 0) end print("[mn-test] cells " .. table.concat(t, " ")) end
      local dumpMode = os.getenv("MN_DUMPMAP")
      if dumpMode == "1" or dumpMode == "2" then -- harness debug: the live block grid ($00 floor ".", $08 "#", $01-$0F as one digit, else the high nibble; "2" adds a full-byte hex grid)
        for yy = 0, s.def.h - 1 do local t = {} for xx = 0, s.def.w - 1 do local v = W.cell(s.def, xx, yy) or 0
          t[#t + 1] = v == 0 and "." or v == 8 and "#" or v < 0x10 and ("%X"):format(v) or ("%X"):format(math.floor(v / 16)) end
          print(("[mn-test] map %2d %s"):format(yy, table.concat(t))) end
        if dumpMode == "2" then
          for yy = 0, s.def.h - 1 do local t = {} for xx = 0, s.def.w - 1 do t[#t + 1] = ("%02X"):format(W.cell(s.def, xx, yy) or 0) end
            print(("[mn-test] hex %2d %s"):format(yy, table.concat(t))) end
        end
        for k, ob in pairs(s.objects or {}) do
          print(("[mn-test] obj %s at %s,%s handler %s dormant=%s blank=%s img=%s blocks=%s"):format(tostring(k), tostring(ob.x), tostring(ob.y),
            ob.handler and ("$%04X"):format(ob.handler) or "-", tostring(ob.dormant), tostring(ob.blank), tostring(ob.image ~= nil or ob.anim ~= nil),
            tostring(k ~= 0 and ob.x and W.blocks(s.def, ob, ob.x, ob.y))))
        end
      end
    end
    for _, l in ipairs(s.log) do print("[mn-test] " .. l) end
    for _, l in ipairs(s.vm.log) do print("[mn-test] " .. l) end
    if Boot.title then
      print(("[mn-title] A017=%02X C921=%02X CCA6=%02X alive=%s"):format(
        s.vm:rd8(0xA017), s.vm:rd8(0xC921), s.vm:rd8(0xCCA6), tostring(s.vm.co ~= nil)))
    end
    love.event.quit(0)
  end
end

if opts.viewer then function love.keypressed(k) if Boot.viewKey(k) then return end; local s = stack:top(); if s.key then s:key(k) end end end

function love.draw()
  local v = layout()
  -- live resize (fold / unfold, rotation): the canvas follows the logical size
  if canvas:getWidth() ~= v.w or canvas:getHeight() ~= v.h then
    canvas = love.graphics.newCanvas(v.w, v.h); canvas:setFilter("nearest", "nearest")
  end
  love.graphics.setCanvas(canvas)
  local top = stack:top()
  if top.wideAware then top:draw(v)
  elseif v.w == 160 and v.h == 144 then top:draw()
  else -- a classic-only screen (viewer, harness): centred classic frame
    love.graphics.clear(0, 0, 0)
    love.graphics.push(); love.graphics.translate(v.ux, v.uy); top:draw(); love.graphics.pop()
  end
  love.graphics.setCanvas()
  love.graphics.draw(canvas, v.sx + v.ox / v.dpi, v.sy + v.oy / v.dpi, 0, v.scale / v.dpi, v.scale / v.dpi)
  if not opts.test then
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.85, 0.85, 0.9, 1)
    love.graphics.printf(CREDIT, 8, v.sy + v.winH - v.band + 6, w - 16)
    love.graphics.setColor(1, 1, 1, 1)
  end
  if opts.test and simW and os.getenv("MN_VIEW_WIN") == "1" and frame % 8 == 0 then
    if not winCanvas or winCanvas:getWidth() ~= simW or winCanvas:getHeight() ~= simH then winCanvas = love.graphics.newCanvas(simW, simH) end
    love.graphics.setCanvas(winCanvas); love.graphics.clear(0, 0, 0)
    love.graphics.draw(canvas, v.ox, v.oy, 0, v.scale, v.scale)
    love.graphics.setCanvas()
    local f = io.open(("%s/win_%04d_map%03d.png"):format(opts.test, shot + 1, stack:top().map or 0), "wb")
    if f then f:write(winCanvas:newImageData():encode("png"):getString()); f:close() end
  end
  local shotDir = os.getenv("MN_SHOT")
  if shotDir and not opts.test and frame % tonumber(os.getenv("MN_SHOT_EVERY") or "30") == 0 then
    local f = io.open(("%s/live_%04d.png"):format(shotDir, frame), "wb")
    if f then f:write(canvas:newImageData():encode("png"):getString()); f:close() end
  end
  if opts.test and frame % 8 == 0 then
    shot = shot + 1
    local d = canvas:newImageData()
    local f = assert(io.open(("%s/frame_%04d_map%03d.png"):format(opts.test, shot, stack:top().map), "wb"))
    f:write(d:encode("png"):getString()); f:close()
  end
end

return Boot
