-- Overworld state: grid walking on 16px cells, collision, the real player
-- walker (bank $20 sprite lists + anim scripts) and the script VM for map
-- entry, step triggers and A-button cells.
local Importer = require("mn.MnImporter")
local World = require("mn.World")
local VM = require("mn.ScriptVM")
local bit = require("bit")
local Sprites = require("mn.Sprites")
local Font = require("mn.Font")
local Battle = require("mn.Battle")
local StartMenu = require("mn.ui.StartMenu")
local Sfx = require("mn.Sfx")
local SfxOut = require("mn.SfxOut")
local Kick = require("mn.Kick")
local M = {}
M.__index = M

local DIRS = { up = { 0, -1 }, down = { 0, 1 }, left = { -1, 0 }, right = { 1, 0 } }

function M.new(mapIndex, x, y, input)
  local s = setmetatable({ input = input, log = {}, objects = {} }, M)
  local rom = Importer.scriptRom()
  s.sfxOut = SfxOut.new(rom)
  s.player = assert(loadstring(love.filesystem.read(Importer.CACHE .. "/player.lua")))()
  s.sheet = love.graphics.newImage(Importer.CACHE .. "/player.png"); s.sheet:setFilter("nearest", "nearest")
  s.quads = {}
  for i = 1, s.player.frames do s.quads[i] = love.graphics.newQuad((i - 1) * 32, 0, 32, 32, s.sheet:getDimensions()) end
  s.font = love.graphics.newFont(8); s.font:setFilter("nearest", "nearest")
  s.vm = VM.new(rom, s:host())
  -- default_state: $FFAA/$FFAB start at 3 (bit 1 lets HandleStartPress open the menu)
  if s.vm:rd8(0xFFAA) == 0 and s.vm:rd8(0xFFAB) == 0 then s.vm:wr8(0xFFAA, 3); s.vm:wr8(0xFFAB, 3) end
  s.items = assert(loadstring(love.filesystem.read(Importer.CACHE .. "/items.lua")))()
  s:enterMap(mapIndex, x, y)
  return s
end

function M:host()
  local s = self
  local h = {
    loadMap = function(i)
      -- from an object/talk thread this is a scene change inside a cutscene:
      -- the area reloads but object records stay (map 40 second scene keeps slots 0,3,4,6,7,9)
      -- after $93 the records were reset already; spawns before the $65 belong to the
      -- new map (training grounds 13:57EB spawns Tony/Eidon/Yaki/Salafy, then loads map 61)
      local keep = (s.vm.curSlot ~= nil or s.sceneFresh) and s.objects or nil
      local keepThreads = s.sceneFresh and s.vm.threads
      s.sceneFresh = nil
      s:enterMap(i, s.x, s.y); s.rebased = false
      if keepThreads then s.vm.threads = keepThreads end
      if s.sfade and s.sfade.to == 1 then s.sfade = { c = s.sfade.c, from = 1, to = 0, t = 0, dur = 16 } end
      if keep then for k, ob in pairs(keep) do s.objects[k] = ob end end
    end,
    freshScene = function() -- records and their threads start over (the running script survives)
      s.objects = {}; s.sceneFresh = true
      local co = coroutine.running()
      for k, t in pairs(s.vm.threads or {}) do if t.co ~= co then s.vm.threads[k] = nil end end
    end,
    setTriggers = function(p)
      s.triggerPtr = p
      if os.getenv("MN_TDBG") then s.log[#s.log + 1] = ("triggers 21:%04X (map %d)"):format(p, s.map) end
    end,
    setAList = function(p) -- RunBank21ScriptList ($2C97): kind-$01 entries run now
      s.aList = p; s.initQueue = s.initQueue or {}
      s.aListCo = coroutine.running() or true -- map 19's init sets the list before its loadMap
      local r = s.vm.rom; local o = 0x21 * 0x4000 + p - 0x4000
      for k = 0, r:u8(o) - 1 do
        local q = o + 1 + 4 * k
        if r:u8(q) == 1 then table.insert(s.initQueue, { r:u8(q + 1), r:u16(q + 2) }) end
      end
    end,
    setMetatile = function(addr, mt)
      local i = addr - 0xD000; local x, y = i % s.def.w, math.floor(i / s.def.w)
      s.patches[#s.patches + 1] = { x = x, y = y, mt = mt }
      s.log[#s.log + 1] = ("metatile (%d,%d) := $%02X"):format(x, y, mt)
    end,
    -- $7E StageEightScriptBytes: copy a w x h rect of map cells (metatile plane,
    -- WRAM 3, and collision plane, WRAM 5) from src to dst. PyBoy map 222 cave-in:
    -- src $D012 (hidden rubble template, row 0) -> dst $D061, one cell per frame.
    mapWidth = function() return s.def.w end,
    fade = function(word, toColor)
      local c = { bit.band(word, 31) / 31, bit.band(bit.rshift(word, 5), 31) / 31, bit.band(bit.rshift(word, 10), 31) / 31 }
      if toColor then s.sfade = { c = c, from = s.sfade and s.sfade.to or 0, to = 1, t = 0, dur = 16 }
      elseif s.sfade then s.sfade = { c = s.sfade.c, from = 1, to = 0, t = 0, dur = 16 } end
    end,
    copyCell = function(si, di)
      local d = s.def
      local mt = d.cells[si + 1]
      if mt then d.cells[di + 1] = mt; s.patches[#s.patches + 1] = { x = di % d.w, y = math.floor(di / d.w), mt = mt } end
      if d.block[si + 1] then d.block[di + 1] = d.block[si + 1] end
    end,
    giveReward = function(cat, id)
      if cat ~= 0 then return true end
      local a = 0xA3A7 + id; local it = s.items[id]
      local maxc = it and it.max or 99
      if s.vm:rd8(a) >= maxc then return false end
      s.vm:wr8(a, s.vm:rd8(a) + 1); s.log[#s.log + 1] = ("got item %d (%s)"):format(id, it and it.name or "?")
      return true
    end,
    got = function(cat, id, cnt) s.log[#s.log + 1] = ("got %d:%d x%d"):format(cat, id, cnt) end,
    sound = function() end,
    objPalette = function() end,
    playerCell = function() return s.x, s.y end,
    cellOpen = function(x, y) return World.walkable(World.cell(s.def, x, y)) end,
    placePlayer = function(x, y) s.x, s.y = x, y; s:snap(); s.log[#s.log + 1] = ("place player %d,%d"):format(x, y) end,
    centerCamera = function() s.pan = nil; s.camFix = nil end,
    -- $84 CenterFineScrollOnScriptWord: wMapColumn/Row = E-5 / D-5, then the
    -- scroll code clamps them to the map record's last column (byte 3, w-11)
    -- and row (byte 4); fine scroll sits at FINE_SCROLL_CENTER (15 px in
    -- PyBoy). Objects already placed keep their offset from the *unclamped*
    -- camera, so they move by (unclamped - clamped). Tavel Gorge: row 3 ->
    -- clamped 0, i.e. the kids' y=12 spawns land 3 rows up (emulator OAM).
    cameraCell = function(c, r)
      local W, H = s.def.w * 16, s.def.h * 16
      local ux, uy = c * 16, r * 16
      local cx = math.max(0, math.min(ux, (s.def.camCol or 99) * 16 + 15, W - 160))
      local cy = math.max(0, math.min(uy, (s.def.camRow or 99) * 16 + 15, H - 144))
      if s.def.camRow == 0 then cy = 0 end
      local dx, dy = math.floor((ux - cx) / 16 + 0.5), math.floor((uy - cy) / 16 + 0.5)
      if dx ~= 0 or dy ~= 0 then
        -- slot 0 (player / its stand-in) is a map cell (C18E/F) and does not move:
        -- PyBoy map 220 has Tony at row 25 after a 3-row walk from his row-28 spawn
        for k, ob in pairs(s.objects) do if k ~= 0 then ob.x, ob.y = ob.x - dx, ob.y - dy; ob.hx, ob.hy = nil, nil end end
        s.log[#s.log + 1] = ("camera clamp shift %d,%d"):format(dx, dy)
      end
      s.camFix = { cx, cy }
    end,
    -- $7C/$7D scroll nudge (bank 1 $4587): the camera's top-left cell (C85F/C860)
    -- steps toward (tc,tr) by spd px per axis per frame; edges stop an axis
    nudge = function(tc, tr, spd)
      local W, H = s.def.w * 16, s.def.h * 16
      if not s.camFix then
        s.camFix = { math.max(0, math.min(W - 160, s.px + 8 - 80)), math.max(0, math.min(H - 144, s.py + 8 - 72)) }
      end
      local tx = math.max(0, math.min(W - 160, tc * 16)); local ty = math.max(0, math.min(H - 144, tr * 16))
      local c = s.camFix; spd = math.max(1, spd)
      local function step(v, t) if v < t then return math.min(t, v + spd) elseif v > t then return math.max(t, v - spd) end; return v end
      c[1], c[2] = step(c[1], tx), step(c[2], ty)
      return c[1] == tx and c[2] == ty
    end,
    scatter = function(slot)
      local ob = s.objects[slot]; if not ob then return end
      local W, H = s.def.w * 16, s.def.h * 16
      local cx = s.camFix and s.camFix[1] or math.max(0, math.min(W - 160, s.px + 8 - 80))
      local cy = s.camFix and s.camFix[2] or math.max(0, math.min(H - 144, s.py + 8 - 72))
      ob.x = math.floor(cx / 16) + love.math.random(1, 9); ob.y = math.floor(cy / 16) + love.math.random(0, 8)
      ob.hx, ob.hy = nil, nil; ob.dirty = true
      if os.getenv("MN_THR") then s.log[#s.log + 1] = ("scatter %d -> %d,%d dorm=%s blank=%s img=%s"):format(slot, ob.x, ob.y, tostring(ob.dormant), tostring(ob.blank), tostring(ob.image ~= nil)) end
    end,
    setCell = function(addr, col, mt)
      local i = addr - 0xD000; local d = s.def
      if i < 0 or i >= d.w * d.h then return end
      d.block[i + 1] = col; d.cells[i + 1] = mt
      s.patches[#s.patches + 1] = { x = i % d.w, y = math.floor(i / d.w), mt = mt }
    end,
    cellByte = function(addr) local i = addr - 0xD000; return s.def.cells[i + 1] end,
    slotCell = function(word)
      local slot = (word - 0xC189) / 27; local ob = s.objects[slot]
      if slot == 0 and not ob then return s.x, s.y end
      if ob then return ob.x, ob.y end
    end,
    -- record byte 0 bit 7: set by op05/op0C (dormant), cleared by op0B. Dormant
    -- records keep their state but their scripts do not run.
    slotFlag = function(slot) if s.objects[slot] then s.objects[slot].shown = true; s.objects[slot].dormant = nil end end,
    slotSleep = function(slot) if s.objects[slot] then s.objects[slot].dormant = true end end,
    slotActive = function(slot) local ob = s.objects[slot]; return not (ob and ob.dormant) end,
    pan = function(c, dx, dy, carry)
      -- walkers that start the same $16 scroll together share it (Tavel Gorge kids 1F:50CD)
      local p = s.panv
      if carry and p and p[5] and p[1] == c and p[2] == dx and p[3] == dy then p[5][carry] = true; return end
      s.panv = { c, dx, dy, nil, carry and { [carry] = true } or nil }
    end,
    spawn = function(slot, x, y, handler, base, abank, aptr, sbank, sptr)
      -- slot 0 with a script record in its anim field is a cutscene stand-in:
      -- the real game shows no player sprite there until control returns
      if slot == 0 and not Sprites.SPRITE_BANKS[abank] then s.hidePlayer = true end
      -- slot 0 with a sprite anim and the $5D81 pad handler is the player itself, not a
      -- stand-in: drop a leftover stand-in so the pad works (1A:6841 into room 10 after
      -- the map 25 guardian duel, record $00,$5D81,5,5 with 20:50FB)
      if slot == 0 and handler == 0x5D81 and Sprites.SPRITE_BANKS[abank] then
        if s.objects[0] or s.hidePlayer then s.log[#s.log + 1] = ("player record at %d,%d"):format(s.x, s.y) end
        s.objects[0] = nil; s.hidePlayer = false; return
      end
      if slot ~= 0 or s.hidePlayer then
        local prev = s.objects[slot]
        s.objects[slot] = Sprites.npc(s, x, y, base, abank, aptr, sbank, sptr)
        local ob = s.objects[slot]
        ob.dormant = os.getenv("MN_NODORM") == nil or nil
        -- op05 refills a record but skips its flag byte (opcode_05.asm): a slot that is
        -- already live stays live (map 61 quake: Yaki 13:5D36 respawned over the trainer)
        if prev and not prev.dormant then ob.dormant = nil end
        -- record bytes 1-2 (op05 handler word): $65A4 marks a step-on record (world map 277
        -- slot 2 at 37,8 runs 2F:4210 -> 14:6A95, the Shadow Geyser scene, PyBoy)
        ob.handler = handler ~= 0 and handler or nil
        ob.beh = (sbank and sbank ~= 0x22) and { sbank, sptr } or nil
        -- a non-sprite-bank anim field is the object's script record: run it as a thread
        if not Sprites.SPRITE_BANKS[abank] then ob.driven = true; s.vm:spawnThread(slot, abank, aptr) end
        s.log[#s.log + 1] = ("npc slot %d at %d,%d sprite=%s talk=%s"):format(slot, x, y, tostring(ob.image ~= nil) .. (ob.seq and ("/" .. #ob.seq .. "f") or "") .. (ob.sched and ("/sched" .. #ob.sched) or ""),
          ob.talk and ("%02X:%04X"):format(ob.talk[1], ob.talk[2]) or "-") .. (" anim=%02X:%04X beh=%02X:%04X base=%02X%s"):format(abank, aptr, sbank or 0, sptr or 0, base, ob.anim and (" use=%02X:%04X"):format(ob.anim[1], ob.anim[2]) or "")
      end
    end,
    setAnim = function(slot, recs, still)
      local ob = s.objects[slot]; if not ob then return end
      ob.still = still
      -- a non-sprite-bank anim (22:4004, the null record) blanks the object:
      -- PyBoy cave crystal vanishes on $14 22:4004 at pickup
      if not Sprites.SPRITE_BANKS[recs[1][1]] then ob.blank = true; return end
      ob.blank = nil
      ob.sched = recs; ob.anim = { recs[1][1], recs[1][2] }; ob.driven = true
      Sprites.build(s, ob)
      if os.getenv("MN_THR") and slot >= 3 and slot <= 5 and s.map == 222 then s.log[#s.log + 1] = ("anim %d %02X:%04X img=%s at %d,%d"):format(slot, recs[1][1], recs[1][2], tostring(ob.image ~= nil), ob.x, ob.y) end
    end,
    -- Opcode19 (bit 7 of the record flags, dispatch resumes): the slot-0
    -- cutscene stand-in hands its cell back to the player
    isSpriteBank = function(b) return Sprites.SPRITE_BANKS[b] ~= nil end,
    release = function(slot)
      local ob = slot and s.objects[slot]
      if slot == 0 and ob then
        s.x, s.y = ob.x, ob.y; s.objects[0] = nil; s.hidePlayer = false; s.moving = nil; s.camFix = nil; s:snap()
        s.log[#s.log + 1] = ("player control at %d,%d"):format(s.x, s.y)
      end
    end,
    slotFields = function(slot, a, b) local ob = s.objects[slot]; if ob then ob.f1, ob.f2 = a, b end end,
    music = function(v) s.log[#s.log + 1] = ("music $%02X"):format(v); s:playMusic(v) end,
    -- record handler word ($13): $65A4 = "start my tail script when the player stands on me"
    setHandler = function(slot, w) local ob = s.objects[slot]; if ob then ob.handler = w end end,
    battleBegin = function(a)
      s.battleSetup = { args = a, ops = {} }
      s.log[#s.log + 1] = ("battle setup C9E4=%02X D391=%02X D36D=%02X script %02X:%04X"):format(a[1], a[2], a[3], a[4], a[5])
    end,
    -- open a UI screen over the field; done(result) runs when its update returns non-nil
    overlay = function(scr, done) s.overlay, s.overlayDone = scr, done end,
    -- from inside a VM coroutine (not the LCD-off init run): open scr, wait until it
    -- closes, return its result. Map setup (vm.init) gets nil without opening anything.
    runOverlay = function(scr)
      if s.vm.init or not coroutine.running() then return nil end
      local res
      s.overlay, s.overlayDone = scr, function(r) res = r end
      while s.overlay == scr do coroutine.yield("wait", 1) end
      return res
    end,
    uiContext = function() return { rom = s.vm.rom, vm = s.vm, ow = s, input = s.input, log = s.log } end,
    battleOp = function(op, args)
      local t = {}; for i, v in ipairs(args) do t[i] = ("%02X"):format(v) end
      s.log[#s.log + 1] = ("battle op $%02X %s"):format(op, table.concat(t, " "))
      if s.battleSetup then table.insert(s.battleSetup.ops, { op = op, args = args })
      elseif s.battle and s.battle.inject then s.battle:inject(op, args) end
    end,
    -- director duel ($25 then a looping $2B stream): see Battle:startDirector
    battleDirect = function() if s.battle and s.battle.startDirector then s.battle:startDirector() end end,
    -- a script the main stream runs from the next field frame (director duel tail)
    mainScript = function(bank, ptr) s.pendingMain = { bank, ptr } end,
    battleRaised = function() return s.battle ~= nil and s.battle.d3c2 == 1 end,
    battleClear = function() if s.battle then s.battle.d3c2 = 0 end end,
    battleRun = function()
      s.battle = Battle.new(s, s.battleSetup or { ops = {} }); s.battleSetup = nil
      s.log[#s.log + 1] = "battle start"
    end,
    battleActive = function() return s.battle ~= nil end,
    battleResult = function() return s.battleResult end,
    glyphCopy = function(count, bank, src, dest, vb)
      local r = s.vm.rom; local so = bank * 0x4000 + src - 0x4000
      s.log[#s.log + 1] = ("glyph %d tiles %02X:%04X -> %d:%04X (map %d)"):format(count, bank, src, vb, dest, s.map)
      local base = (vb % 2) * 0x1000 + dest - 0x8000
      for k = 0, count * 16 - 1 do
        local a = base + k
        if dest + k >= 0x8000 and dest + k < 0x9000 then s.obj[a] = r:u8(so + k) end
      end
      for _, ob in pairs(s.objects) do ob.image = nil; ob.imgs = nil; ob.dirty = true end
    end,
    -- text window: $9B opens (portrait word; $7078 = plain box), $9F appends,
    -- $99/$9A close; otherwise it closes when the coroutine that wrote it ends
    text = function(tok)
      if not s.textBox then s.textBox = Font.newBox(nil) end
      Font.append(s.textBox, tok); s.textBox.owner = coroutine.running()
      if os.getenv("MN_TEXTLOG") then s.log[#s.log + 1] = "text " .. tok:gsub("\n", "/"):gsub("\f", "|") end
      if os.getenv("MN_THR") then local o = s.vm.pcs and s.vm.pcs[coroutine.running()]; print(("[txt] f%d %s@%s %q"):format(s.vm.tk or 0, tostring(s.vm.curKey), o and ("%02X:%04X"):format(math.floor(o / 0x4000), o % 0x4000 + 0x4000) or "?", tok)) end
    end,
    boxOpen = function(w) s.textBox = Font.newBox((w >= 0x4008 and w < 0x8000 - 400 and w % 16 >= 8) and w or nil) end, -- $7078 is Tony (PyBoy shows his face on every $7078 line)
    choose = function(n) return s.textBox and Font.choice(s.textBox, n) end,
    boxClose = function() s.aCool = 20; if os.getenv("MN_THR") then print(("[txt] f%d close"):format(s.vm.tk or 0)) end; s.textBox = nil end,
    boxBusy = function() local b = s.textBox; return b ~= nil and not (b.done and not b.wait) end,
    picture = function(pic) s.picture = pic end, -- $63/$6A travel cards (mn.Picture); nil on $65
  }
  require("mn.OpExt").extendHost(s, h) -- host callbacks added by src/mn/ops/*.lua
  Sfx.host(s, h) -- h.sfx / h.sfxSlot / h.sfxRequest / h.sfxSelect on s.sfxOut.sfx
  return h
end

-- A map load drops the old A-list, except one this same script run set just
-- before its loadMap: map 19's init (1A:624C) runs $69 first, then $65.
function M:settleAList()
  local keep = self.aListCo ~= nil and self.aListCo == (coroutine.running() or true)
  if not keep then self.aList = nil end
  self.aListCo = nil
end

function M:snap() self.px, self.py = self.x * 16, self.y * 16 end

function M:enterMap(i, x, y)
  self.def = Importer.loadMap(i); self.map = i; self.objects = {}
  self.x, self.y = x, y; self:snap(); self.moving = nil; self.facing = self.facing or "down"
  self:settleAList(); self.camOff = nil; self.camFix = nil; self.patches = {}
  self.atlas = love.graphics.newImage(("%s/maps/%03d_meta.png"):format(Importer.CACHE, i)); self.atlas:setFilter("nearest", "nearest")
  local ov = love.filesystem.read(("%s/maps/%03d.obj"):format(Importer.CACHE, i))
  self.obj = {}; for k = 1, #ov do self.obj[k - 1] = ov:byte(k) end
  self.log[#self.log + 1] = ("enter map %d at %d,%d"):format(i, x, y)
  -- a door load (not a thread's scene change) rebuilds every record: stale
  -- c70d/slot threads from the old map must not survive into the new one
  do
    local co, inThread = coroutine.running(), false
    for _, t in pairs(self.vm.threads or {}) do if t.co == co then inThread = true end end
    if not inThread and self.vm.threads then self.vm.threads = {} end
    -- a thread's scene change still drops the C70D record unless it is the loader:
    -- PyBoy C70D reads 0 on map 40 after the kids scene (whose shake loop 1F:52F3
    -- would otherwise override the 2A:4859 camera pan)
    -- mailboxes C6F8-C6FD: hardware posts live one frame, so nothing carries
    -- over a scene change (map 40 slot 4's $5F saw the kids scene's stale $06)
    for m = 0xC6F5, 0xC6FD do self.vm.mem[m] = 0 end -- WriteQuadRecords clears the rendezvous too
    local c = self.vm.threads and self.vm.threads.c70d
    if inThread and c and c.co ~= co then self.vm.threads.c70d = nil end
  end
  if os.getenv("MN_THR") then local co = coroutine.running(); local who = "main"; for k, t in pairs(self.vm.threads or {}) do if t.co == co then who = tostring(k) end end; self.log[#self.log + 1] = "  by thread " .. who .. " pc " .. (self.vm.pcs and self.vm.pcs[co] and ("%X"):format(self.vm.pcs[co]) or "?") end
end

-- Dev checkpoints (MN_SNAP_TO=map[:n] MN_SNAP_FILE=path): when a door trigger into that map
-- fires (the n-th time), write the VM memory (SRAM flags, items, story word), the
-- player's cell and the trigger script; Overworld.load replays that door.
-- Destination map of the live trigger list's entry idx: the list the entry
-- script's $64 installed (self.triggerPtr), not the importer's cached first
-- list (map 40 runs 21:4228 / 21:4231 while the cache holds 21:4238).
function M:triggerTo(idx)
  if not self.triggerPtr then return nil end
  self.warpTo = self.warpTo or {}
  local key = self.triggerPtr * 64 + idx
  local hit = self.warpTo[key]
  if hit == nil then
    local _, b, p = self:listEntry(self.triggerPtr, idx)
    local w = b and self.vm.rom.resolveWarp and self.vm.rom:resolveWarp(b, p, {})
    hit = w and w.map or -1
    self.warpTo[key] = hit
  end
  return hit >= 0 and hit or nil
end

function M:snapshot(b, p)
  local want, file = os.getenv("MN_SNAP_TO"), os.getenv("MN_SNAP_FILE")
  if not (want and file) then return end
  local to = self:triggerTo(bit.band(World.cell(self.def, self.x, self.y), 0x3F))
  local m, n = want:match("^(%d+):?(%d*)$")
  if not to or to ~= tonumber(m) then return end
  self.snapCount = (self.snapCount or 0) + 1
  if self.snapCount ~= (tonumber(n) or 1) then return end
  local parts = {}
  -- SRAM (story word, flags, items, saved script) and the title-card flag; other WRAM is per-scene
  for a, v in pairs(self.vm.mem) do
    if v ~= 0 and ((a >= 0xA000 and a < 0xC000) or a == 0xC6F3) then parts[#parts + 1] = ("[%d]=%d"):format(a, v) end
  end
  table.sort(parts)
  local f = assert(io.open(file, "w"))
  f:write(("return {map=%d,x=%d,y=%d,facing=%q,bank=%d,ptr=%d,tony=%s,mem={%s}}\n"):format(self.map, self.x, self.y,
    self.facing, b, p, tostring(self.tonyEnergy or "nil"), table.concat(parts, ",")))
  f:close(); self.log[#self.log + 1] = ("snapshot -> %s (door %02X:%04X into %d)"):format(file, b, p, to)
end

function M.load(file, input)
  local snap = assert(loadfile(file))()
  local s = M.new(snap.map, snap.x, snap.y, input)
  for a, v in pairs(snap.mem) do s.vm.mem[a] = v end
  s.tonyEnergy = snap.tony; s.facing = snap.facing
  s:runScript(snap.bank, snap.ptr, "step trigger (snapshot)")
  return s
end

-- bank-$21 list entry (kind, bank, ptr)
function M:listEntry(ptr, idx)
  local r = self.vm.rom; local o = 0x21 * 0x4000 + ptr - 0x4000
  if idx < 0 or idx >= r:u8(o) then return nil end
  local q = o + 1 + 4 * idx
  return r:u8(q), r:u8(q + 1), r:u16(q + 2)
end

function M:runScript(bank, ptr, why)
  self.log[#self.log + 1] = ("script %02X:%04X (%s)"):format(bank, ptr, why)
  self.scriptWaiting = self.vm:start(bank, ptr)
  self:flushInit()
end

function M:flushInit()
  while self.initQueue and #self.initQueue > 0 do
    local e = table.remove(self.initQueue, 1)
    self.log[#self.log + 1] = ("init script %02X:%04X"):format(e[1], e[2])
    self.vm:runInit(e[1], e[2])
  end
end

function M:update()
  -- vblank slice for the SFX driver, including frames a menu or battle owns
  self.sfxOut:update(1 / 60)
  -- a UI screen (src/mn/ui/*, contract in docs/mn-ui.md) owns input until it returns a result
  if self.overlay then
    local r = self.overlay:update()
    if r ~= nil then
      local done = self.overlayDone
      self.overlay, self.overlayDone = nil, nil
      if done then done(r) end
    end
    return
  end
  if self.battle then
    local done = self.battle:update()
    if done then self.log[#self.log + 1] = ("battle end: %s"):format(tostring(done)); self.battle = nil; self.battleResult = done end
    self.vm:tickThreads(false)
    return
  end
  if self.pendingMain then
    local m = self.pendingMain
    self.pendingMain = nil
    self:runScript(m[1], m[2], "duel tail")
  end
  self.vm:tickThreads(self.textBox ~= nil and not self.textBox.done)
  -- encounter records: a $65A4 handler fires the record's tail script when Tony shares its cell
  if not self.moving and not self.textBox and not self.scriptWaiting then
    for slot, ob in pairs(self.objects) do
      if ob.handler == 0x65A4 and ob.x == self.x and ob.y == self.y and ob.beh then
        ob.handler = 0x4A6B
        self.log[#self.log + 1] = ("encounter slot %d at %d,%d"):format(slot, ob.x, ob.y)
        self:runScript(ob.beh[1], ob.beh[2], "encounter"); break
      end
    end
  end
  for _, o in pairs(self.objects) do
    if o.seq and not o.dirty and not o.dormant then -- dormant records don't animate or move
      o.hx, o.hy = o.hx or o.x, o.hy or o.y
      Sprites.tick(o, function(x, y)
        if x < 0 or y < 0 or x >= self.def.w or y >= self.def.h then return y >= self.def.h end -- may enter from below
        -- objects use the strict "cell == 0" walk gate (Tavel Gorge kids halt below the
        -- $C0 cave mouth); the slot-0 stand-in walks like the player and may end on a
        -- trigger cell (PyBoy: training-grounds Tony stops on the $C2 cell 10,9)
        local v = World.cell(self.def, x, y)
        return v == 0 or (_ == 0 and v >= 0xC0)
      end)
      if not o.driven and math.abs(o.x - o.hx) + math.abs(o.y - o.hy) > 6 then o.x, o.y, o.ox, o.oy = o.hx, o.hy, 0, 0 end
      if os.getenv("MN_TRACE") and o.sched then
        self.tr = (self.tr or 0) + 1
        if self.tr % 40 == 0 then self.log[#self.log + 1] = ("trace npc %d,%d+%d,%d step %d img %s"):format(o.x, o.y, o.ox, o.oy, o.si or 0, tostring(o.image):sub(-8)) end
      end
    end
  end
  if self.panv then
    local p = self.panv; self.camOff = self.camOff or { 0, 0 }
    local dx, dy = p[2], p[3]
    if p[5] then -- $16 scroll: clamped to the map, and it carries its walkers
      local cx, cy = self:cameraXY()
      local W, H = self.def.w * 16, self.def.h * 16
      if W >= 160 then dx = math.max(0, math.min(W - 160, cx + dx)) - cx end
      if H >= 144 then dy = math.max(0, math.min(H - 144, cy + dy)) - cy end
      for slot in pairs(p[5]) do
        local ob = self.objects[slot]
        if ob then
          ob.ox, ob.oy = (ob.ox or 0) + dx, (ob.oy or 0) + dy
          while ob.ox >= 16 do ob.ox = ob.ox - 16; ob.x = ob.x + 1 end
          while ob.ox <= -16 do ob.ox = ob.ox + 16; ob.x = ob.x - 1 end
          while ob.oy >= 16 do ob.oy = ob.oy - 16; ob.y = ob.y + 1 end
          while ob.oy <= -16 do ob.oy = ob.oy + 16; ob.y = ob.y - 1 end
        end
      end
    end
    self.camOff[1], self.camOff[2] = self.camOff[1] + dx, self.camOff[2] + dy
    p[1] = p[1] - 1; if p[1] <= 0 then self.panv = nil end
  end
  -- $9C choice menu: up/down/left/right move the hand (on a fresh press), A picks
  local ch = self.textBox and self.textBox.choice
  if ch and not ch.picked then
    local d = self.input("dir")
    if d and d ~= self.choiceDir then Font.choiceMove(ch, d) end
    self.choiceDir = d
    if self.input("a") then ch.picked = ch.cur end
  end
  if self.vm.wait then
    -- a main-script poll (e.g. $9A waiting on a box another thread writes) must not freeze the box
    if self.textBox and self.textBox.owner and not self.vm.textWait then
      local b = self.textBox
      Font.update(b, self.input("a") and true or false)
      if b.done and not b.wait and coroutine.status(b.owner) == "dead" and self.textBox == b then self.textBox = nil end
    end
    self.vm.wait = self.vm.wait - 1
    if self.vm.wait <= 0 then self.vm.wait = nil; self.scriptWaiting = self.vm:resume() end
    return
  end
  if self.textBox then
    local b = self.textBox
    Font.update(b, self.input("a") and true or false)
    if b.done and not b.wait then
      if self.vm.textWait then self.scriptWaiting = self.vm:resume(); self:flushInit()
      elseif not b.owner or coroutine.status(b.owner) == "dead" then
        if self.textBox == b then self.textBox = nil end
      end
    end
    return
  end
  if Kick.tick(self) then return end -- bracelet lunge (bank-$20 kick script) owns the player
  if self.moving then
    local d = DIRS[self.moving]
    self.px, self.py = self.px + d[1], self.py + d[2]
    self.anim = (self.anim or 0) + 1
    if self.px == self.x * 16 and self.py == self.y * 16 then
      local dx, dy = d[1], d[2]; self.moving = nil
      -- the live list ($64's self.triggerPtr) gives the kind and script; the
      -- importer's cached list can be another entry's
      local v = World.cell(self.def, self.x, self.y)
      local k, b, p
      if v >= 0xC0 and self.triggerPtr then k, b, p = self:listEntry(self.triggerPtr, bit.band(v, 0x3F)) end
      if os.getenv("MN_ADBG") and v >= 0xC0 then print(("[step] map %d %d,%d cell %02X d %d,%d t=%s tp=%s"):format(self.map, self.x, self.y, v, dx, dy, tostring(k), tostring(self.triggerPtr))) end
      if b and World.gate(k, dx, dy) then self:snapshot(b, p); self:runScript(b, p, "step trigger") end
    end
    return
  end
  if self.objects[0] then return end -- slot-0 cutscene stand-in owns the player
  do -- a live dialogue record owns A (real: C71B busy, the A list is not polled)
    local th = self.vm.threads
    if th and th.talk and coroutine.status(th.talk.co) ~= "dead" then return end
  end
  -- HandleStartPress (06): FinishFrame latches $FFAA into $FFAB, then the four gates
  self.vm:wr8(0xFFAB, self.vm:rd8(0xFFAA))
  if self.input("start") and StartMenu.canOpen(self.vm) then
    self.log[#self.log + 1] = "start menu"
    self.overlay = StartMenu.new({ rom = self.vm.rom, vm = self.vm, ow = self, input = self.input, log = self.log })
    self.overlayDone = function(r)
      if r.action == "save" and r.bank then
        -- the planted $C714 record runs through the field script handler, then is consumed
        for a = 0xC714, 0xC718 do self.vm:wr8(a, 0) end
        self:runScript(r.bank, r.ptr, "start menu save")
      end
    end
    return
  end
  if self.aCool and self.aCool > 0 then self.aCool = self.aCool - 1; self.input("a") end
  if (not self.aCool or self.aCool <= 0) and self.input("a") then
    local f = DIRS[self.facing]; local fx, fy = self.x + f[1], self.y + f[2]
    if os.getenv("MN_ADBG") then print(("[a] map %d at %d,%d facing %s cell $%02X alist %s"):format(self.map, self.x, self.y, tostring(self.facing), World.cell(self.def, fx, fy), tostring(self.aList))) end
    -- talk: the facing cell is the object's cell or the one below it (PyBoy: Evu at 15,5
    -- answers from 15,6 up, 14,5 / 14,6 right, 16,6 left, 15,4 down; only 15,5 blocks)
    for slot, ob in pairs(self.objects) do
      local hit = ob.x == fx and (ob.y == fy or ob.y + 1 == fy)
      if hit and ob.beh and self.vm.rom:u8(ob.beh[1] * 0x4000 + ob.beh[2] - 0x4000) ~= 0x5B
        and not (self.vm.threads and self.vm.threads[slot]) then
        -- the record's own script (sbank:sptr) runs as the slot's thread when used
        self.log[#self.log + 1] = ("use slot %d -> %02X:%04X"):format(slot, ob.beh[1], ob.beh[2])
        self.vm:spawnThread(slot, ob.beh[1], ob.beh[2]); return
      end
      if hit and ob.talk then
        self:runScript(ob.talk[1], ob.talk[2], ("talk to slot %d"):format(slot)); return
      end
    end
    -- DispatchPressedAOnFacingCell (01:619A): a faced $0B cell is the bracelet kick
    if Kick.try(self) then return end
    local v = World.cell(self.def, fx, fy)
    -- standing on a list cell ($20-$3F stay walkable) counts too
    if not (v < 0x80 and bit.band(v, 0x60) ~= 0) then v = World.cell(self.def, self.x, self.y) end
    -- SaveCellBelowAndStageThirdScript: bit 5/6 set, bit 7 clear -> index v-$40
    if v < 0x80 and bit.band(v, 0x60) ~= 0 and self.aList then
      local _, b, p = self:listEntry(self.aList, v - 0x40)
      if b then self.vm.fromA = true; self:runScript(b, p, ("A on cell $%02X"):format(v)); self.vm.fromA = nil end
    end
    return
  end
  if self.objects[0] then return end -- slot-0 cutscene stand-in owns the player
  -- a live C71B (talk/cutscene) record holds the player still (real: Tony stays put
  -- through the cave-in while C71B runs 5EFB; a step trigger there would fire 5BC6)
  local th = self.vm.threads
  if th and th.talk and coroutine.status(th.talk.co) ~= "dead" then return end
  -- a script running in slot 0 walks the player (Opcode09 slot 0, e.g. map 25's
  -- 1A:674C); the pad is ignored, so no step back onto a trigger mid-scene
  if self:slot0Scripted() then return end
  local dir = self.input("dir")
  if not dir then return end
  self.facing = dir
  local d = DIRS[dir]; local nx, ny = self.x + d[1], self.y + d[2]
  for _, ob in pairs(self.objects) do if ob.x == nx and ob.y == ny and (ob.image or ob.anim) and not ob.dormant and not ob.blank and ob.handler ~= 0x65A4 then return end end
  if nx >= 0 and ny >= 0 and nx < self.def.w and ny < self.def.h and World.walkable(World.cell(self.def, nx, ny)) then
    self.x, self.y = nx, ny; self.moving = dir; self.camFix = nil; self.hidePlayer = nil
  end
end

function M:slot0Scripted()
  local th = self.vm and self.vm.threads
  local t = th and th[0]
  return t ~= nil and t.co ~= nil and coroutine.status(t.co) ~= "dead"
end

function M:frame()
  local anim
  if self.moving then anim = self.player.anims[self.facing] else anim = self.player.anims["idle_" .. self.facing] end
  if not anim or #anim == 0 then return 1 end
  if not self.moving then return anim[1].f end
  local t = (self.anim or 0) % 16
  return anim[(t < 8) and 1 or math.min(#anim, 3)].f
end

function M:draw()
  if self.battle then self.battle:draw() else self:drawField() end
  if self.overlay then self.overlay:draw() end
  if Battle.GOD then -- dev mode tag (MN_GOD=1), never shown in normal play
    love.graphics.setColor(1, 0.2, 0.2); love.graphics.rectangle("fill", 130, 0, 30, 11)
    love.graphics.setColor(1, 1, 1); love.graphics.print("GOD", 133, -2); love.graphics.setColor(1, 1, 1)
  end
end

-- camera top-left in map pixels: follows the player, clamped to the map, unless a
-- script fixed it ($84) or panned it ($83 / $16)
function M:cameraXY()
  local W, H = self.def.w * 16, self.def.h * 16
  local cx = math.max(0, math.min(W - 160, self.px + 8 - 80))
  local cy = math.max(0, math.min(H - 144, self.py + 8 - 72))
  if W < 160 then cx = (W - 160) / 2 end
  if H < 144 then cy = (H - 144) / 2 end
  if self.camFix then cx, cy = self.camFix[1], self.camFix[2] end
  if self.camOff then cx, cy = cx + self.camOff[1], cy + self.camOff[2] end
  return math.floor(cx), math.floor(cy)
end

function M:drawField()
  local W, H = self.def.w * 16, self.def.h * 16
  local cx, cy = self:cameraXY()
  love.graphics.clear(0, 0, 0)
  if self.picture then
    self.picture:draw() -- a travel card / title picture replaces the field until $65
  else
  love.graphics.draw(self.def.image, -cx, -cy)
  for _, p in ipairs(self.patches) do
    love.graphics.draw(self.atlas, love.graphics.newQuad((p.mt % 16) * 16, math.floor(p.mt / 16) * 16, 16, 16, 256, 256), p.x * 16 - cx, p.y * 16 - cy)
  end
  for _, o in pairs(self.objects) do
    if o.dirty then Sprites.build(self, o); o.dirty = false end
    if os.getenv("MN_RDBG") and self.map == tonumber(os.getenv("MN_RDBG")) and (self.vm.tk or 0) % 30 == 0 and _ ~= 0 and _ ~= 2 then print(("[rdbg] f%d slot %s at %d,%d o=%s,%s img=%s dorm=%s blank=%s cam=%d,%d off=%s fix=%s pan=%s"):format(self.vm.tk or 0, tostring(_), o.x, o.y, tostring(o.ox), tostring(o.oy), tostring(o.image ~= nil), tostring(o.dormant), tostring(o.blank), cx, cy, self.camOff and (self.camOff[1] .. "," .. self.camOff[2]) or "-", self.camFix and (self.camFix[1] .. "," .. self.camFix[2]) or "-", self.panv and table.concat(self.panv, ",") or "-")) end
    -- record byte 0 bit 7 (dormant) objects aren't drawn: PyBoy map 40 slots 5-7
    -- stay $80 and show no OAM until $0B wakes them
    if o.image and not o.dormant and not o.blank then love.graphics.draw(o.image, o.x * 16 - 24 + (o.ox or 0) - cx, o.y * 16 - 24 + (o.oy or 0) - cy) end
  end
  if not self.hidePlayer then love.graphics.draw(self.sheet, self.quads[self:frame()], self.px - cx - 8, self.py - cy - 8) end
  end
  -- title-card fade: while [$C6F3] == 0 the scene sits at palette black
  -- ((0,16,0) in PyBoy); when the director sets it to 1 it fades in over $40
  -- frames (the $6F $87,$0040 stage before FinishStartup).
  local f3 = self.vm.mem[0xC6F3]
  if f3 == 0 then self.fadeT = 0 elseif f3 == 1 and self.fadeT then self.fadeT = self.fadeT + 1; if self.fadeT > 64 then self.fadeT = nil end end
  if self.fadeT and not self.picture then -- the field's startup fade; cards use the $6E/$6F fades
    love.graphics.setColor(0, 16 / 255, 0, 1 - self.fadeT / 64)
    love.graphics.rectangle("fill", 0, 0, 160, 144)
    love.graphics.setColor(1, 1, 1, 1)
  end
  -- script fades ($6E to a colour, $6F back from it): BGR555 colour over the scene
  local sf = self.sfade
  if sf then
    sf.t = math.min(sf.dur, sf.t + 1)
    local a = sf.from + (sf.to - sf.from) * sf.t / sf.dur
    if a > 0 then
      love.graphics.setColor(sf.c[1], sf.c[2], sf.c[3], a); love.graphics.rectangle("fill", 0, 0, 160, 144); love.graphics.setColor(1, 1, 1, 1)
    elseif sf.t >= sf.dur then self.sfade = nil end
  end
  if self.textBox then Font.drawTyped(self.textBox, self.def.pal7, self.vm.rom) end
end


-- $1F music: decode the song from the cached ROM banks and loop it.
local MnMusic = require("mn.MnMusic")
local musicCache = {}
function M:playMusic(v)
  if not (love.audio and love.sound) or os.getenv("MN_NOMUSIC") then return end
  local rom = self.vm and self.vm.rom
  if not rom or v >= 41 then return end
  if self.music then self.music:stop() end
  local src = musicCache[v]
  if not src then
    local MnRom = require("mn.MnRom")
    local song = MnMusic.decode(function(b, p) return rom:u8(MnRom.off(p, b)) end, v, 60)
    if song.length < 0.1 then return end
    local rate = 22050
    local sd = love.sound.newSoundData(math.floor(song.length * rate) + 1, rate, 16, 1)
    MnMusic.renderGB(song, rate, function(i, x) sd:setSample(i, x) end, function(b, p) return rom:u8(MnRom.off(p, b)) end)
    src = love.audio.newSource(sd, "static"); src:setLooping(true); musicCache[v] = src
  end
  self.music = src; src:play()
end

return M
