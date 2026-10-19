-- Magi-Nation boot: `love . --mn [--rom path] [--viewer] [--mn-test outdir]`.
-- Uses gen1recomp's StateStack; renders into a 160x144 canvas scaled x4.
package.path = "src/?.lua;" .. package.path
local MnRom = require("mn.MnRom")
local Importer = require("mn.MnImporter")
local World = require("mn.World")
local bit = require("bit")
local StateStack = require("src.core.StateStack")
-- LICENSE.MD term 1: this boot screen is a front end and must carry the credit.
local Attribution = require("src.core.Attribution")

local Boot = {}
io.stdout:setvbuf("no")
local frame, shot = 0, 0
function love.errorhandler(msg) print("[mn] ERROR " .. tostring(msg) .. "\n" .. debug.traceback()); os.exit(1) end
local opts = { rom = "roms/magination.gbc" }
for i, a in ipairs(arg or {}) do
  if a == "--rom" then opts.rom = arg[i + 1] end
  if a == "--viewer" then opts.viewer = true end
  if a == "--mn-test" then opts.test = arg[i + 1] end
  if a == "--mn-music" then opts.music = tonumber(arg[i + 1]); opts.musicOut = arg[i + 2] end
end

local stack = setmetatable({}, { __index = StateStack }); stack:init()
local canvas, held

local function ensureCache()
  if Importer.isCached() then print("[mn] cache ok"); return end
  local f = assert(io.open(opts.rom, "rb"), "no ROM at " .. opts.rom)
  local bytes = f:read("*a"); f:close()
  print("[mn] importing " .. opts.rom)
  assert(Importer.import(bytes, function(s) print("[mn] " .. s) end))
  bytes = nil; collectgarbage()
end

-- Headless test planner: path to targets with BFS, press A on talk cells.
local function bfs(def, sx, sy, goal)
  local prev, q, h = { [sy * def.w + sx] = -1 }, { { sx, sy } }, 1
  local found
  while h <= #q do
    local x, y = q[h][1], q[h][2]; h = h + 1
    if goal(x, y) and not (x == sx and y == sy) then found = { x, y }; break end
    for _, d in ipairs({ { 1, 0, "right" }, { -1, 0, "left" }, { 0, 1, "down" }, { 0, -1, "up" } }) do
      local nx, ny = x + d[1], y + d[2]; local k = ny * def.w + nx
      if nx >= 0 and ny >= 0 and nx < def.w and ny < def.h and not prev[k] and World.walkable(World.cell(def, nx, ny)) then
        prev[k] = { y * def.w + x, d[3] }; q[#q + 1] = { nx, ny }
      end
    end
  end
  if not found then return nil end
  local k, path = found[2] * def.w + found[1], {}
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
      local t = def.triggers[v % 64 + 1]
      return t ~= nil and t.to >= 0 and t.to ~= ow.map
    end)
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
    end)
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
  if opts.test then
    local start = tonumber(os.getenv("MN_START") or "1")
    local def = Importer.loadMap(start); local e = def.entries[1]
    local planner
    -- MN_ROUTE="220:up,221:right": hold a direction while in that map (A every 20 frames)
    local route = {}
    -- "40:12.0" walks to cell 12,0 (BFS around walls and objects)
    local goals = {}
    -- "54:7.3|3.9": successive goals on successive entries into that map
    -- "...,@61,2:5.5,...": entries after "@61" only take effect once map 61 has been entered
    local routeStr = os.getenv("MN_ROUTE") or ""
    local lateKey, lateStr = routeStr:match("@(%d+),(.*)$")
    if lateKey then routeStr = routeStr:gsub("@%d+,.*$", "") end
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
      if lateKey and ow and ow.map == tonumber(lateKey) then
        -- switch to the late route: its maps restart their visit counts
        local r2, g2 = {}, {}; parseRoute(lateStr, r2, g2)
        for m2, v in pairs(r2) do route[m2] = v; goals[m2] = g2[m2]; visits[m2] = nil end
        lateKey = nil
      end
      local d = ow and route[ow.map]
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
        for _, ob in pairs(ow.objects) do if ob.handler == 0x65A4 then tgt = ob end end
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
        if ow.textBox and ow.farFace then ow.talkSeen = 0 end
        if not ow.objects[0] and not ow.textBox then
          local key = ow.map .. ":" .. (ow.farGoalFor or "")
          if ow.farMap ~= ow.map then
            if ow.farMap ~= nil or not ow.replan then visits[ow.map] = (visits[ow.map] or 0) + 1; ow.step = 1; ow.talkSeen = nil end
            ow.replan = nil
            ow.farMap = ow.map
            local def, prev, q, h = ow.def, {}, { { ow.x, ow.y } }, 1
            prev[ow.y * def.w + ow.x] = -1
            local best, bd, dist = nil, -1, { [ow.y * def.w + ow.x] = 0 }
            while h <= #q do
              local c = q[h]; h = h + 1
              local id = c[2] * def.w + c[1]
              local gl = goals[ow.map]; local vl = gl and gl[math.min(visits[ow.map] or 1, #gl)]
              local g = vl and vl[math.min(ow.step or 1, #vl)]
              if g then ow.farFace = g.face; if c[1] == g[1] and c[2] == g[2] then best, bd = c, dist[id] end
              elseif W.cell(def, c[1], c[2]) >= 0xC0 and dist[id] > bd then best, bd = c, dist[id] end
              for _, dd in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
                local nx, ny = c[1] + dd[1], c[2] + dd[2]; local nid = ny * def.w + nx
                local occ = false
                -- same rule as the player's own step (Overworld: $65A4 records and blank/imageless ones don't block)
                for k, ob in pairs(ow.objects) do if k ~= 0 and not ob.dormant and not ob.blank and (ob.image or ob.anim) and ob.handler ~= 0x65A4 and ob.x == nx and ob.y == ny then occ = true end end
                if nx >= 0 and ny >= 0 and nx < def.w and ny < def.h and not prev[nid] and not occ and W.walkable(W.cell(def, nx, ny)) then
                  prev[nid] = id; dist[nid] = dist[id] + 1; q[#q + 1] = { nx, ny }
                end
              end
            end
            ow.farPath = {}
            if best then
              local id = best[2] * def.w + best[1]
              while prev[id] and prev[id] ~= -1 do table.insert(ow.farPath, 1, { id % def.w, math.floor(id / def.w) }); id = prev[id] end
              ow.log[#ow.log + 1] = ("route far -> %d,%d (%d steps)"):format(best[1], best[2], #ow.farPath)
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
            if k == "a" then return frame % 30 == 0 and not (ow.talkSeen and vl and (ow.step or 1) < #vl) end
            -- turn only when needed: a press toward an open cell would walk off the goal
            if frame % 30 == 10 and not ow.talkSeen and ow.facing ~= ow.farFace then return ow.farFace end
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
          if ow.stuck > 60 and os.getenv("MN_STUCKDBG") then local n = ow.farPath and ow.farPath[1]; local tw = {}; for k2, t in pairs(ow.vm and ow.vm.threads or ow.threads or {}) do tw[#tw + 1] = tostring(k2) end; print(("stuck at %d,%d next %s talk=%s box=%s threads=%s"):format(ow.x, ow.y, n and (n[1] .. "," .. n[2]) or "-", tostring(ow.talkThread ~= nil), tostring(ow.textBox ~= nil), table.concat(tw, " "))) end
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
    if not os.getenv("MN_LOAD") then ow:runScript(e.bank, e.ptr, "map entry") end
    stack:push(ow)
    local startMap = ow.map
    Boot.testDone = function(s)
      if s.map ~= startMap and not s.moving and not s.scriptWaiting then startMap = s.map; planner.phase = "talk"; planner.q = {}; s.log[#s.log + 1] = ("door crossed -> map %d at %d,%d"):format(s.map, s.x, s.y) end
      if s.textBox and not planner.inBox then planner.inBox = true; planner.boxes = (planner.boxes or 0) + 1 end
      if not s.textBox and planner.inBox then planner.inBox = false end
      if (planner.boxes or 0) >= 2 and not s.textBox then planner.after = (planner.after or 0) + 1 end
      if os.getenv("MN_FRAMES") then return frame > tonumber(os.getenv("MN_FRAMES")) end
      return (planner.after or 0) > 20 or frame > 8000
    end
  elseif opts.viewer then
    stack:push(require("mn.Viewer").new(0))
  else
    -- keyboard path: Z/Enter = A, X/Backspace = B, arrows; key state is tracked from
    -- keypressed/keyreleased events so MN_KEYS (scripted events) drives the same code as real keys
    local startMap = tonumber(os.getenv("MN_BATTLE_TEST") and "3" or "0")
    local def = Importer.loadMap(startMap); local sp = def.entries[1] and def.entries[1].spawn or { x = 1, y = 1 }
    local pressed, held = {}, {}
    local AK = { z = "a", ["return"] = "a", x = "b", backspace = "b" }
    function love.keypressed(k) held[k] = true; if AK[k] then pressed[AK[k]] = true end end
    function love.keyreleased(k) held[k] = nil end
    local mkOw = os.getenv("MN_LOAD") and function(_, _, _, fn) return Overworld.load(os.getenv("MN_LOAD"), fn) end or Overworld.new
    local ow = mkOw(startMap, sp.x, sp.y, function(kind)
      if kind == "a" or kind == "b" then local p = pressed[kind]; pressed[kind] = false; return p end
      for _, k in ipairs({ "up", "down", "left", "right" }) do if held[k] or love.keyboard.isDown(k) then return k end end
    end)
    stack:push(ow)
    if os.getenv("MN_BATTLE_TEST") then -- the map-3 Weebo encounter ($2E 09 53 01), straight into battle
      ow.battle = require("mn.Battle").new(ow, { ops = { { op = 0x2E, args = { 0x09, 0x53, 0x01 } } } })
    end
    -- MN_KEYS="w60,z,w20,down,..." : wN waits N frames, a key name is pressed for 4 frames
    local keys = os.getenv("MN_KEYS")
    if keys then
      local q = {}; for tok in keys:gmatch("[^,]+") do q[#q + 1] = tok end
      local qi, waitN, rel = 1, 0, nil
      Boot.keyTick = function()
        if rel then rel[2] = rel[2] - 1; if rel[2] <= 0 then love.event.push("keyreleased", rel[1], rel[1], false); rel = nil end end
        if waitN > 0 then waitN = waitN - 1; return end
        local tok = q[qi]
        if not tok then
          if not Boot.keysDone then Boot.keysDone = frame; print("[mn-keys] script done at frame " .. frame) end
          if frame - Boot.keysDone > tonumber(os.getenv("MN_KEYS_TAIL") or "120") then
            for _, l in ipairs(ow.log) do print("[mn-keys] " .. l) end
            love.event.quit(0)
          end
          return
        end
        qi = qi + 1
        local n = tok:match("^w(%d+)$")
        if n then waitN = tonumber(n) else love.event.push("keypressed", tok, tok, false); rel = { tok, 4 }; waitN = 6 end
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
    end
    for _, l in ipairs(s.log) do print("[mn-test] " .. l) end
    for _, l in ipairs(s.vm.log) do print("[mn-test] " .. l) end
    love.event.quit(0)
  end
end

if opts.viewer then function love.keypressed(k) local s = stack:top(); if s.key then s:key(k) end end end

function love.draw()
  love.graphics.setCanvas(canvas); stack:top():draw(); love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0, 0, 4, 4)
  if not opts.test then
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.85, 0.85, 0.9, 1)
    love.graphics.printf("MagiRecomp - " .. Attribution.UPSTREAM_CREDIT, 8,
      math.min(h - 40, 144 * 4 + 8), w - 16)
    love.graphics.setColor(1, 1, 1, 1)
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
