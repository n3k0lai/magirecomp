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
local Push = require("mn.Push")
local Grass = require("mn.Grass")
local Travel = require("mn.ops.Travel")
local Panels = require("mn.ops.Panels")
local LivePalette = require("mn.LivePalette")
local Viewport = require("mn.Viewport")
local EdgeFill = require("mn.EdgeFill")
local EdgeFillMaps = require("mn.EdgeFillMaps")
local M = {}
M.__index = M
M.wideAware = true -- Boot passes the logical view to draw() (see mn.Viewport)

local Ride = require("mn.Ride")
-- bank-1 record heads that read the pad: a slot-0 record with one is the player
local PAD_HEADS = { [0x5D81] = true, [0x5B1E] = true, [0x5B41] = true, [0x5D47] = true }
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
  -- OBJ palettes: sprites are baked with the $21:$5CC0 block (the one 691 of
  -- the 693 reachable $66 ops load). Until a $66 runs, the live OBJ block
  -- starts as that block rather than all black.
  s.objBase = s:paletteBlock(0x21, 0x5CC0)
  local blank = true
  for a = 0xC7EB, 0xC82A do if s.vm:rd8(a) ~= 0 then blank = false end end
  if blank then Panels.loadPalettes(s.vm, s.objBase, true) end
  if love.graphics.newShader then s.livePal = LivePalette.new(s.objBase) end
  -- default_state: $FFAA/$FFAB start at 3 (bit 1 lets HandleStartPress open the menu)
  if s.vm:rd8(0xFFAA) == 0 and s.vm:rd8(0xFFAB) == 0 then s.vm:wr8(0xFFAA, 3); s.vm:wr8(0xFFAB, 3) end
  -- WriteC12APatternBank5 (05:6C08), before the map script's opcode $85
  World.seedPattern(s.vm)
  s.items = assert(loadstring(love.filesystem.read(Importer.CACHE .. "/items.lua")))()
  s:enterMap(mapIndex, x, y)
  return s
end

function M:host()
  local s = self
  local h = {
    loadMap = function(i)
      -- $65 (00:1820) -> LoadFiveBankedMapSources (00:2E15): BG palettes ($C72B),
      -- tiles (CopyMapRecords), the WRAM-2/3/5 planes. Nothing else: records,
      -- threads, mailboxes, the A list ($69) and the player cell are untouched.
      -- A door's resets are $93's (FinishStartup), which precedes 634 of the
      -- 701 $65 in the scripts.
      s:scriptSnapshot(i)
      s:loadArea(i); s.rebased = false
    end,
    -- FinishStartup ($93) -> SetupDefaultState -> BuildPointerList (01:40D3) sets bit 7
    -- and clears bit 6 on all $31 records: they sleep, they are not erased, and a later
    -- $0B wakes one with its cell, handler and scripts intact (2F:46C0 wakes the boat
    -- record slot 4 the 236/258/40 shore spawned, then loads the sea map 281)
    defaultGates = function() -- $93: WriteC12APattern; the walk heads start from the normal family
      World.seedPattern(s.vm); s.layer, s.layerDir, s.layerHeld = nil, nil, nil
    end,
    freshScene = function() -- record threads start over (the running script survives)
      s.asleep = s.asleep or {}
      -- (slot 0 is the player; the port keeps only a cutscene stand-in there)
      for k, ob in pairs(s.objects) do if k ~= 0 then ob.dormant = true; s.asleep[k] = ob end end
      s.objects = {}
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
    -- StoreEThroughWordInWram3 (00:26CC), the shared tail of $A0-$A4: the byte goes
    -- into the WRAM-3 metatile plane (def.cells) at the word. Only with the LCD off
    -- (map setup) does the later full BG draw show it. With the LCD on the tail
    -- redraws one cell: the last A cell SaveCellBelowAndStageThirdScript saved
    -- (column $C99D, row $C99C, WRAM-3 byte at the word $C99E), whatever the
    -- stored word was. Any other stored cell keeps its old tiles until a seam
    -- redraws it from WRAM 3 (bgStale, applied once it is off screen).
    setMetatile = function(addr, mt)
      local d = s.def
      local i = addr - 0xD000; local x, y = i % d.w, math.floor(i / d.w)
      if d.cells and i >= 0 and i < d.w * d.h then d.cells[i + 1] = mt end
      s.log[#s.log + 1] = ("metatile (%d,%d) := $%02X"):format(x, y, mt)
      if not s.vm or s.vm.init then
        s.patches[#s.patches + 1] = { x = x, y = y, mt = mt }
        return
      end
      s.bgStale = s.bgStale or {}
      s.bgStale[i] = true
      local vm = s.vm
      local ax, ay = vm:rd8(0xC99D), vm:rd8(0xC99C)
      local aw = vm:rd8(0xC99E) + vm:rd8(0xC99F) * 256
      local ai = aw - 0xD000
      if ai >= 0 and ai < d.w * d.h and d.cells and d.cells[ai + 1] then
        s.patches[#s.patches + 1] = { x = ax, y = ay, mt = d.cells[ai + 1] }
        if ax + ay * d.w == ai then s.bgStale[ai] = nil end
      end
    end,
    -- $7E StageEightScriptBytes: copy a w x h rect of map cells (metatile plane,
    -- WRAM 3, and collision plane, WRAM 5) from src to dst. PyBoy map 222 cave-in:
    -- src $D012 (hidden rubble template, row 0) -> dst $D061, one cell per frame.
    mapWidth = function() return s.def.w end,
    copyCell = function(si, di)
      local d = s.def
      local mt = d.cells[si + 1]
      if mt then d.cells[di + 1] = mt; s.patches[#s.patches + 1] = { x = di % d.w, y = math.floor(di / d.w), mt = mt } end
      if d.block[si + 1] then d.block[di + 1] = d.block[si + 1] end
    end,
    -- DispatchBank7Arg ($7350). Category 0 clamps an item count; 1-3 are
    -- Travel.grant (stones, relics, spells). A false return is the full
    -- branch (22:4074).
    giveReward = function(cat, id)
      if cat >= 1 and cat <= 3 then return Travel.grant(s.vm, cat, id) end
      if cat ~= 0 then return true end
      local a = 0xA3A7 + id; local it = s.items[id]
      local maxc = it and it.max or 99
      if s.vm:rd8(a) >= maxc then return false end
      s.vm:wr8(a, s.vm:rd8(a) + 1); s.log[#s.log + 1] = ("got item %d (%s)"):format(id, it and it.name or "?")
      return true
    end,
    got = function(cat, id, cnt) s.log[#s.log + 1] = ("got %d:%d x%d"):format(cat, id, cnt) end,
    sound = function() end,
    -- $66 -> FillC76BFromBCThenOBJPalettes ($2EE9): 32 words to $C76B, then
    -- the target block is copied live and uploaded.
    objPalette = function(bank, ptr) Panels.loadPalettes(s.vm, s:paletteBlock(bank, ptr), true) end,
    playerCell = function() return s.x, s.y end,
    cellOpen = function(x, y) return World.walkable(World.cell(s.def, x, y)) end,
    placePlayer = function(x, y) s.x, s.y = x, y; s:snap(); s.moving = nil; Ride.sync(s); s.log[#s.log + 1] = ("place player %d,%d"):format(x, y) end, -- a placement ends any half step
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
      return M.nudgeStep(s.camFix, tc, tr, spd, W - 160, H - 144)
    end,
    -- $11 (PickMapCellFromDiv): wMapColumn/wMapRow are the camera's top-left cell and the
    -- map stride is the width; the VM picks the cell and moves the record there
    mapView = function()
      local W, H = s.def.w * 16, s.def.h * 16
      local cx = s.camFix and s.camFix[1] or math.max(0, math.min(W - 160, s.px + 8 - 80))
      local cy = s.camFix and s.camFix[2] or math.max(0, math.min(H - 144, s.py + 8 - 72))
      return math.floor(cx / 16), math.floor(cy / 16), s.def.w
    end,
    blockByte = function(addr) local i = addr - 0xD000; return s.def.block[i + 1] end,
    scatter = function(slot, col, row, found)
      local ob = s.objects[slot]; if not ob then return end
      ob.x, ob.y = col, row; ob.picking = not found or nil
      ob.hx, ob.hy = nil, nil; ob.dirty = true
      if os.getenv("MN_THR") then s.log[#s.log + 1] = ("scatter %d -> %d,%d"):format(slot, ob.x, ob.y) end
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
    slotFlag = function(slot)
      if not s.objects[slot] and s.asleep and s.asleep[slot] then s.objects[slot] = s.asleep[slot] end
      if s.asleep then s.asleep[slot] = nil end
      if s.objects[slot] then s.objects[slot].shown = true; s.objects[slot].dormant = nil end end,
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
      local anim = Sprites.isAnim(s.vm.rom, abank, aptr)
      if slot == 0 and not anim then s.hidePlayer = true end
      -- slot 0 with a sprite anim and the $5D81 pad handler is the player itself, not a
      -- stand-in: drop a leftover stand-in so the pad works (1A:6841 into room 10 after
      -- the map 25 guardian duel, record $00,$5D81,5,5 with 20:50FB). $5B1E is the other
      -- pad head (bank 1 direction dispatch): 2F:44F9 plants it with 20:4F73 when the
      -- Ogar duel tail drops Tony on 279, and the duel's stand-in must go then too.
      -- $5B41 (SelectSRAMBankThenDownMark, falls into ResumeDownClearHead $5B6E) and
      -- $5D47 (inside ResumeOtherLeftCellScript: reads $C9A3 and plants the up / left /
      -- right heads) are pad heads too: 2F:466C plants $5B41 with 20:5BCF when the boat
      -- lands on 236 (sea trigger $C6), and Tony walks off it
      if slot == 0 and PAD_HEADS[handler] and anim then
        if s.objects[0] or s.hidePlayer then s.log[#s.log + 1] = ("player record at %d,%d"):format(s.x, s.y) end
        s.objects[0] = nil; s.hidePlayer = false; return
      end
      if slot ~= 0 or s.hidePlayer then
        local prev = s.objects[slot]
        if s.asleep then s.asleep[slot] = nil end
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
        -- the record's tail script (second bank/ptr), run by $64D1 (mn.Ride re-mount 22:40C2)
        ob.tail = (sbank and sbank ~= 0) and { sbank, sptr } or nil
        -- an anim field that is more than sprite ops is the record's script: run it as a thread
        if not anim then ob.driven = true; s.vm:spawnThread(slot, abank, aptr, true) end
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
    isSpriteBank = function(b, p) return Sprites.isAnim(s.vm.rom, b, p) end,
    -- $4C/$4D/$4E/$4F run by a record's script queue that record's sprite lists: show
    -- them from this op on (the VM waits the same frame count before its next op)
    animAt = function(slot, bank, ptr)
      local ob = s.objects[slot]; if not ob or (ob.anim and ob.anim[1] == bank and ob.anim[2] == ptr and not ob.spent) then return end
      ob.blank = nil; ob.sched = nil; ob.anim = { bank, ptr }
      Sprites.build(s, ob)
    end,
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
    -- $00 copies the door pair into slot 0's record: a stand-in (hidePlayer) stands there too
    moveStandIn = function(x, y) local ob = s.objects[0]; if ob and s.hidePlayer then ob.x, ob.y, ob.ox, ob.oy = x, y, 0, 0 end end,
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
    -- $38's loop polls B / Start behind the $C9C6 gate (Panels.lua)
    buttonPressed = function(k) return s.input(k) and true or false end,
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
  h.fullRom = function() -- banks past the script image ($68 overlay streams)
    if s._fullRom == nil then
      local bytes = love.filesystem.read(Importer.CACHE .. "/rom.bin")
      s._fullRom = bytes and require("mn.MnRom").new(bytes) or false
    end
    return s._fullRom or nil
  end
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

-- 32 RGB555 words at bank:ptr in the cached script banks (0-based)
function M:paletteBlock(bank, ptr)
  local r, o, w = self.vm.rom, bank * 0x4000 + ptr - 0x4000, {}
  for k = 0, 31 do w[k] = r:u16(o + 2 * k) end
  return w
end

-- The map data $65 loads (see host.loadMap); no record, thread or WRAM state.
function M:loadArea(i)
  self.def = Importer.loadMap(i); self.map = i
  -- $65 LoadFiveBankedMapSources -> FillC72BFromBCThenBank7 ($2EC3): slot 0's
  -- 32 words land in $C72B, are copied to $C7AB and uploaded the same frame
  if self.def.bgWords then
    local w = {}; for k = 0, 31 do w[k] = self.def.bgWords[k + 1] end
    Panels.loadPalettes(self.vm, w, false)
  end
  if self.x then self:snap() end
  -- port camera overrides and BG overlays belong to the old plane
  self.camOff = nil; self.camFix = nil; self.patches = {}; self.bgStale = nil
  self.atlas = love.graphics.newImage(("%s/maps/%03d_meta.png"):format(Importer.CACHE, i)); self.atlas:setFilter("nearest", "nearest")
  local ai = ("%s/maps/%03d_meta_idx.png"):format(Importer.CACHE, i)
  self.atlasIndex = self.def.index and love.filesystem.getInfo(ai) and love.graphics.newImage(ai) or nil
  if self.atlasIndex then self.atlasIndex:setFilter("nearest", "nearest") end
  local ov = love.filesystem.read(("%s/maps/%03d.obj"):format(Importer.CACHE, i))
  self.obj = {}; for k = 1, #ov do self.obj[k - 1] = ov:byte(k) end
  self.log[#self.log + 1] = ("enter map %d at %d,%d"):format(i, self.x or -1, self.y or -1)
  if os.getenv("MN_THR") then local co = coroutine.running(); local who = "main"; for k, t in pairs(self.vm.threads or {}) do if t.co == co then who = tostring(k) end end; self.log[#self.log + 1] = "  by thread " .. who .. " pc " .. (self.vm.pcs and self.vm.pcs[co] and ("%X"):format(self.vm.pcs[co]) or "?") end
end

-- A port-side start in a map (boot, checkpoint replay): a fresh record table,
-- no threads, no mailboxes, no A list.
function M:enterMap(i, x, y)
  self.objects = {}
  self.x, self.y = x, y
  self:loadArea(i)
  self.moving = nil; self.facing = self.facing or "down"
  self:settleAList()
  if self.vm.threads then self.vm.threads = {} end
  for m = 0xC6F5, 0xC6FD do self.vm.mem[m] = 0 end
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
  if not (os.getenv("MN_SNAP_TO") and os.getenv("MN_SNAP_FILE")) then return end
  local to = self:triggerTo(bit.band(World.cell(self.def, self.x, self.y), 0x3F))
  if to then self:snapMatch(to, "", b, p) end
end

-- Script warps (MN_SNAP_TO=s279): a $65 map load run by a script, e.g. after the
-- Ogar win tail 13:6CD9, has no door to replay. Checkpoint the current map and
-- the last main script; Overworld.load reruns it there.
function M:scriptSnapshot(to)
  local want = os.getenv("MN_SNAP_TO")
  if not (want and want:find("s") and os.getenv("MN_SNAP_FILE")) then return end
  -- replay the last main script, not the thread doing the load: the Ogar tail
  -- 13:6CD9 plants slot 0's anim 13:6D54, whose thread (2F:4508) loads 279
  -- after the tail has ended; 6D54 alone stalls on its $5C
  local b, p = (self.vm.started or ""):match("^(%x+):(%x+)$")
  if b then self:snapMatch(to, "s", tonumber(b, 16), tonumber(p, 16)) end
end

-- Control checkpoints (MN_SNAP_TO=c141[:n]): on the n-th free frame in that map
-- after a script, text box or stand-in (a control hand-back), e.g. Ashgar's house 141 after the 135 scene's
-- script warp, save the map, cell, trigger lists and SRAM with no script to
-- replay; Overworld.load places Tony there with the saved lists.
function M:controlSnapshot()
  local want = os.getenv("MN_SNAP_TO")
  if not (want and want:find("c") and os.getenv("MN_SNAP_FILE")) then return end
  self:snapMatch(self.map, "c")
end

-- Frame / end checkpoints (MN_SNAP_AT=end or MN_SNAP_AT=<frame>, MN_SNAP_FILE=path): a harness
-- run saves a control-style checkpoint (map, cell, lists, SRAM, plane diff) on that frame or
-- on its last frame, so a leg that ends mid-map (186 push blocks) need not replay from the
-- last door. Fires once; MN_SNAP_TO is not needed.
function M:frameSnapshot(frame, last)
  local at, file = os.getenv("MN_SNAP_AT"), os.getenv("MN_SNAP_FILE")
  if not (at and file) or self.frameSnapDone then return end
  if (at == "end" and last) or (tonumber(at) and frame >= tonumber(at)) then
    self.frameSnapDone = true
    self:writeSnapshot(file:match("^[^,]+"), nil, nil, self.map, "c")
  end
end

function M:snapMatch(to, kind, b, p)
  local want, files = os.getenv("MN_SNAP_TO"), os.getenv("MN_SNAP_FILE")
  -- comma lists pair up: MN_SNAP_TO=279,113 MN_SNAP_FILE=a.lua,b.lua (one checkpoint per map)
  local fl = {}
  for f in files:gmatch("[^,]+") do fl[#fl + 1] = f end
  local i = 0
  for spec in want:gmatch("[^,]+") do
    i = i + 1
    local k, m, n = spec:match("^([sc]?)(%d+):?(%d*)$")
    local file = fl[i]
    if file and m and k == kind and to == tonumber(m) then
      self.snapCount = self.snapCount or {}
      self.snapCount[i] = (self.snapCount[i] or 0) + 1
      if self.snapCount[i] == (tonumber(n) or 1) then self:writeSnapshot(file, b, p, to, kind) end
    end
  end
end

function M:writeSnapshot(file, b, p, to, kind)
  local parts = {}
  -- SRAM (story word, flags, items, saved script) and the title-card flag; other WRAM is per-scene
  for a, v in pairs(self.vm.mem) do
    if v ~= 0 and ((a >= 0xA000 and a < 0xC000) or a == 0xC6F3) then parts[#parts + 1] = ("[%d]=%d"):format(a, v) end
  end
  table.sort(parts)
  local f = assert(io.open(file, "w"))
  local script = b and ("bank=%d,ptr=%d,"):format(b, p) or ""
  local lists = kind == "c" and ("trig=%s,alist=%s,"):format(tostring(self.triggerPtr), tostring(self.aList)) or ""
  -- a control checkpoint has no script to replay, so the map entry script's
  -- plane edits ($7F overlay blits, $7E copies, setCell) are saved as a diff
  -- against the stored map and put back by Overworld.load (map 134's 28:68C1
  -- blits the story 15 door, C2 at 24,18)
  if kind == "c" and self.def then
    local d = M.planeDiff(self.def, M.baseMap(self.map))
    if #d > 0 then lists = lists .. ("planes={%s},"):format(table.concat(d, ",")) end
  end
  f:write(("return {map=%d,x=%d,y=%d,facing=%q,%s%stony=%s,mem={%s}}\n"):format(self.map, self.x, self.y,
    self.facing, script, lists, tostring(self.tonyEnergy or "nil"), table.concat(parts, ",")))
  f:close()
  local what = kind == "c" and "control" or (kind == "s" and "script" or "door")
  self.log[#self.log + 1] = b and ("snapshot -> %s (%s %02X:%04X into %d)"):format(file, what, b, p, to)
    or ("snapshot -> %s (%s in %d at %d,%d)"):format(file, what, to, self.x, self.y)
end

-- stored map record for a plane diff (tests swap this out)
-- One frame of NudgeCameraDeltas (bank 1 $4587) on camera pixels c = {x, y}. Per axis the map
-- cell (C85F = x // 16, C860 = y // 16) is compared with the target cell: a match, or an edge
-- that blocks the step, finishes that axis; otherwise spd px is added toward it (StepHorizontal/
-- VerticalScroll clamp a delta to 4). True once both axes are finished in the same frame, as L
-- reaching 0 there. Leaving left/up therefore stops as soon as the cell matches, up to 15 px
-- short of the cell's left/top edge, exactly like the asm.
function M.nudgeStep(c, tc, tr, spd, maxX, maxY)
  spd = math.max(1, math.min(4, spd))
  local function axis(i, t, mx)
    local v = c[i]; local col = math.floor(v / 16)
    if col == t then return true end
    if col < t then
      if v >= mx then return true end
      c[i] = math.min(mx, v + spd)
    else
      if v <= 0 then return true end
      c[i] = math.max(0, v - spd)
    end
    return false
  end
  local a = axis(1, tc, maxX); local b = axis(2, tr, maxY)
  return a and b
end

function M.baseMap(i) return Importer.loadMap(i) end

-- flat {i, col, mt, ...} for every cell whose collision or metatile byte
-- differs from base (i is the 0-based WRAM 5 offset, $D000 + i)
function M.planeDiff(def, base)
  local out = {}
  for i = 1, def.w * def.h do
    local c, m = def.block[i] or 0, def.cells[i] or 0
    if c ~= (base.block[i] or 0) or m ~= (base.cells[i] or 0) then
      out[#out + 1] = ("%d,%d,%d"):format(i - 1, c, m)
    end
  end
  return out
end

function M:applyPlanes(list)
  local d = self.def
  for k = 1, #list - 2, 3 do
    local i, c, m = list[k], list[k + 1], list[k + 2]
    if i >= 0 and i < d.w * d.h then
      d.block[i + 1] = c; d.cells[i + 1] = m
      self.patches = self.patches or {}
      self.patches[#self.patches + 1] = { x = i % d.w, y = math.floor(i / d.w), mt = m }
    end
  end
end

function M.load(file, input)
  local snap = assert(loadfile(file))()
  local s = M.new(snap.map, snap.x, snap.y, input)
  if snap.planes then s:applyPlanes(snap.planes) end
  for a, v in pairs(snap.mem) do s.vm.mem[a] = v end
  s.tonyEnergy = snap.tony; s.facing = snap.facing
  if snap.trig then s.triggerPtr = snap.trig end
  if snap.alist then s.aList = snap.alist end
  if snap.bank then s:runScript(snap.bank, snap.ptr, "step trigger (snapshot)") end
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
  Grass.frame(self) -- hMainLoopCounter, once per pass (main_loop.asm)
  if self.bgStale then self:flushStale() end
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
  if self.textBox or self.scriptWaiting or self.vm.wait or self.objects[0] then self.ctlBusy = true end
  -- encounter records: a $65A4 handler fires the record's tail script when Tony shares its cell.
  -- Only a taken slot (Opcode0B) runs its handler: 277's init (2F:41F4) takes the Shadow
  -- Geyser record (slot 2, 37,8) only while the story word is 3..5.
  -- MN_NOENC=1 (harness debug only, off by default): wandering monsters (slots 31+) don't
  -- start battles, so route legs can be tested; story records (e.g. 277 slot 2) still fire
  local noEnc = os.getenv("MN_NOENC") == "1"
  if not self.moving and not self.textBox and not self.scriptWaiting then
    for slot, ob in pairs(self.objects) do
      if ob.handler == 0x65A4 and not ob.dormant and ob.x == self.x and ob.y == self.y and ob.beh
        and not (noEnc and type(slot) == "number" and slot >= 31) then
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
        return Sprites.walkGate(function(cx, cy) return World.cell(self.def, cx, cy) end, _ == 0, o.x, o.y, x, y)
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
  -- $38 loop with $C9C7 = 1 (Start): the frame skips FinishFrame, so the record waits
  if self.vm.loop38 and self.vm:rd8(0xC9C7) == 1 then return end
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
  if Push.tick(self) then return end -- crystal-gloves push lunge owns the player
  if Kick.tick(self) then return end -- Crystal Gloves dig lunge (bank-$20 kick script) owns the player
  if self.moving then
    -- pixel step in progress: the walk head is still the live record
    Grass.walk(self)
    local d = DIRS[self.moving]
    self.px, self.py = self.px + d[1], self.py + d[2]
    self.anim = (self.anim or 0) + 1
    Ride.sync(self) -- a riding record moves with the field position
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
    if th and th.talk and coroutine.status(th.talk.co) ~= "dead" then self.ctlBusy = true; return end
  end
  -- first free frame after a script, text box or stand-in: a control hand-back
  if self.ctlBusy then self.ctlBusy = nil; self:controlSnapshot() end
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
      elseif r.action == "use" and r.ptr and r.ptr ~= 0 then
        -- SetupCommand4D's record (the row's script, else the map fallback from $95)
        for a = 0xC714, 0xC718 do self.vm:wr8(a, 0) end
        self:runScript(r.bank, r.ptr, ("start menu use $%02X"):format(r.id or 0))
      end
    end
    return
  end
  -- $60E7 ride head (boat): the record takes the pad, A docks on a faced $00 cell
  if Ride.tick(self) then return end
  if self.aCool and self.aCool > 0 then self.aCool = self.aCool - 1; self.input("a") end
  if self.objects[0] then return end -- slot-0 cutscene stand-in owns the player
  -- a live C71B (talk/cutscene) record holds the player still (real: Tony stays put
  -- through the cave-in while C71B runs 5EFB; a step trigger there would fire 5BC6)
  local th = self.vm.threads
  if th and th.talk and coroutine.status(th.talk.co) ~= "dead" then return end
  -- a script running in slot 0 walks the player (Opcode09 slot 0, e.g. map 25's
  -- 1A:674C); the pad is ignored, so no step back onto a trigger mid-scene
  if self:slot0Scripted() then return end
  local dir = self.input("dir")
  -- ResumePlantedHead6167 (01:6167): a held direction ($C9A3 bits 4-7) jumps to its
  -- plant before anything else; only with no direction held does a newly pressed A
  -- ($C9A4 bit 0) reach DispatchPressedAOnFacingCell (01:619A). A with a direction is dropped.
  if not dir and (not self.aCool or self.aCool <= 0) and self.input("a") then
    local f = DIRS[self.facing]; local fx, fy = self.x + f[1], self.y + f[2]
    if os.getenv("MN_ADBG") then print(("[a] map %d at %d,%d facing %s cell $%02X alist %s"):format(self.map, self.x, self.y, tostring(self.facing), World.cell(self.def, fx, fy), tostring(self.aList))) end
    -- talk: the facing cell is the object's cell or the one below it (PyBoy: Evu at 15,5
    -- answers from 15,6 up, 14,5 / 14,6 right, 16,6 left, 15,4 down; only 15,5 blocks)
    for slot, ob in pairs(self.objects) do
      local hit = ob.x == fx and (ob.y == fy or ob.y + 1 == fy)
      -- a record script that only plants its talk ($5B ..., $42) is the talk itself; one that
      -- carries on after the $5B (257 boatman 1B:509A waits on C6FD for the talk's $58 01
      -- post, then 1B:50ED) has to run as the slot's thread
      if hit and ob.beh and M.useRunsRecord(self.vm.rom, ob.beh[1], ob.beh[2])
        and not (self.vm.threads and self.vm.threads[slot]) then
        -- the record's own script (sbank:sptr) runs as the slot's thread when used
        self.log[#self.log + 1] = ("use slot %d -> %02X:%04X"):format(slot, ob.beh[1], ob.beh[2])
        self.vm:spawnThread(slot, ob.beh[1], ob.beh[2]); return
      end
      if hit and ob.talk then
        self:runScript(ob.talk[1], ob.talk[2], ("talk to slot %d"):format(slot)); return
      end
    end
    -- DispatchPressedAOnFacingCell (01:619A): $09 is the gloves push, $0B the kick
    if Push.try(self) then return end
    if Kick.try(self) then return end
    if Ride.try(self) then return end -- a parked boat ($6405) in GateCellNearFirstRecord's window
    local v = World.cell(self.def, fx, fy)
    -- DispatchPressedAOnFacingCell (01:619A) reads only the faced cell; list
    -- cells are $20-$7F, which ProbeCells keeps solid, so Tony never stands on one
    -- SaveCellBelowAndStageThirdScript: bit 5/6 set, bit 7 clear -> index v-$40
    if v < 0x80 and bit.band(v, 0x60) ~= 0 and self.aList then
      -- SaveCellBelowAndStageThirdScript (01:4B61): row $C99C, column $C99D, the
      -- cell's WRAM word $C99E/$C99F and the list index $C9A0
      local w = 0xD000 + fy * self.def.w + fx
      self.vm:wr8(0xC99C, fy); self.vm:wr8(0xC99D, fx)
      self.vm:wr8(0xC99E, w % 256); self.vm:wr8(0xC99F, math.floor(w / 256)); self.vm:wr8(0xC9A0, v)
      local _, b, p = self:listEntry(self.aList, v - 0x40)
      if b then self.vm.fromA = true; self:runScript(b, p, ("A on cell $%02X"):format(v)); self.vm.fromA = nil; self.kickSeen = true end -- harness: a cell script ends a ">" goal like a kick
    end
    return
  end
  if self.layer == 2 then
    -- The $02 layer heads (01:4F0D and siblings) never read the held pad:
    -- the planted bank-$20 walk anim keeps $C6D3/$C6D2 nonzero, so Tony
    -- keeps going. A newly pressed other direction ($C9A4) switches to that
    -- direction's plant (4EF2 / 4F9C / 5046 / 50F0).
    if dir and dir ~= self.layerHeld and dir ~= self.layerDir then self.layerDir = dir end
    self.layerHeld = dir
    dir = self.layerDir
  end
  if not dir then return end
  -- direction held, including a bump: StepCell82EveryFourthFrame's first
  -- call does not wait for a nonzero step. A started grass script owns
  -- the frame, so the step does not also begin.
  if Grass.walk(self) then return end
  self.facing = dir
  local d = DIRS[dir]
  local nx, ny, layer, how = World.step(self.def, self.x, self.y, d[1], d[2], self.layer, World.mark(self.vm), self.vm)
  if not nx then return end
  for _, ob in pairs(self.objects) do if World.blocks(self.def, ob, nx, ny) then return end end
  if layer ~= self.layer then
    World.applyLayer(self.vm, self.layer, layer)
    self.log[#self.log + 1] = ("layer %s -> %s at %d,%d"):format(tostring(self.layer), tostring(layer), nx, ny)
    self.layer = layer
    self.layerDir = (layer == 2) and dir or nil
    self.layerHeld = (layer == 2) and dir or nil
  end
  if how == "hop" then self.log[#self.log + 1] = ("hop %d,%d -> %d,%d"):format(self.x, self.y, nx, ny) end
  self.x, self.y = nx, ny; self.moving = dir; self.camFix = nil; self.hidePlayer = nil
end

-- A WRAM-3 store the LCD-on tail did not redraw (setMetatile) shows its old tiles
-- while on screen; a cell entering the view is drawn by the scroll seam from WRAM 3,
-- so once a stale cell is off screen its stored metatile is what the BG will show.
function M:flushStale()
  local d = self.def
  local cx, cy = self:cameraXY()
  local x0, x1 = math.floor(cx / 16), math.floor((cx + 159) / 16)
  local y0, y1 = math.floor(cy / 16), math.floor((cy + 143) / 16)
  for i in pairs(self.bgStale) do
    local x, y = i % d.w, math.floor(i / d.w)
    if x < x0 or x > x1 or y < y0 or y > y1 then
      self.patches[#self.patches + 1] = { x = x, y = y, mt = d.cells[i + 1] }
      self.bgStale[i] = nil
    end
  end
  if next(self.bgStale) == nil then self.bgStale = nil end
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

-- view: { w, h, ux, uy } from mn.Viewport (nil = classic 160x144). The field
-- fills the whole view; battle, pictures, the text box and menus draw in the
-- classic 160x144 frame at (ux, uy), so their layouts stay the original ones.
function M:draw(view)
  local vw, vh = view and view.w or 160, view and view.h or 144
  local ux, uy = view and view.ux or 0, view and view.uy or 0
  local wide = vw ~= 160 or vh ~= 144
  if self.battle then
    if wide then love.graphics.clear(0, 0, 0) end
    self:classicFrame(wide, ux, uy, function() self.battle:draw() end)
  else self:drawField(vw, vh, ux, uy) end
  self:classicFrame(wide, ux, uy, function()
    if self.overlay then self.overlay:draw() end
    if Battle.GOD then -- dev mode tag (MN_GOD=1), never shown in normal play
      love.graphics.setColor(1, 0.2, 0.2); love.graphics.rectangle("fill", 130, 0, 30, 11)
      love.graphics.setColor(1, 1, 1); love.graphics.print("GOD", 133, -2); love.graphics.setColor(1, 1, 1)
    end
  end)
end

-- run fn with the origin at the classic frame, clipped to it (identity when classic)
function M:classicFrame(wide, ux, uy, fn)
  if not wide then return fn() end
  love.graphics.push(); love.graphics.translate(ux, uy); love.graphics.setScissor(ux, uy, 160, 144)
  fn()
  love.graphics.setScissor(); love.graphics.pop()
end

-- out-of-map cells of a wide view: best-guess metatiles (mn.EdgeFill) from
-- this map's own cell plane and atlas, batched in one draw
function M:drawEdgeFill(L, T, vw, vh)
  local ef = self.edgeFill
  if not ef or ef.map ~= self.map or ef.atlas ~= self.atlas then
    local fill, mode = EdgeFill.build(self.def, os.getenv("MN_VIEW_FILL"), EdgeFillMaps[self.map])
    ef = { map = self.map, atlas = self.atlas, fill = fill, mode = mode, quads = {},
           batch = love.graphics.newSpriteBatch(self.atlas, 1024, "stream") }
    self.edgeFill = ef
  end
  if ef.mode == "black" then return end
  local b = ef.batch; b:clear()
  local n = EdgeFill.each(ef.fill, self.def.w, self.def.h, L, T, vw, vh, function(x, y, mt)
    local q = ef.quads[mt]
    if not q then q = love.graphics.newQuad((mt % 16) * 16, math.floor(mt / 16) * 16, 16, 16, 256, 256); ef.quads[mt] = q end
    if b:getCount() >= b:getBufferSize() then b:setBufferSize(b:getBufferSize() * 2) end
    b:add(q, x * 16 - L, y * 16 - T)
  end)
  if n > 0 then love.graphics.draw(b, 0, 0) end
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

function M:drawField(vw, vh, ux, uy)
  vw, vh, ux, uy = vw or 160, vh or 144, ux or 0, uy or 0
  local W, H = self.def.w * 16, self.def.h * 16
  local cx, cy = self:cameraXY()
  -- render camera (L, T): the classic camera unless the view is wider, then a
  -- wider window around it (mn.Viewport.wideCamera); logic only sees cx, cy
  local wide = vw ~= 160 or vh ~= 144
  local L, T = cx, cy
  if wide then L, T = Viewport.wideCamera(cx, cy, W, H, vw, vh) end
  love.graphics.clear(0, 0, 0)
  if self.picture then
    -- a travel card / title picture replaces the field until $65
    self:classicFrame(wide, ux, uy, function() self.picture:draw() end)
  else
  if wide then self:drawEdgeFill(L, T, vw, vh) end
  -- the field shows the live palette block $C7AB (mn.LivePalette): fades and
  -- color cycling are the palette ops walking those words
  local lp = self.livePal and self.def.index and self.atlasIndex and self.livePal
  if lp then lp:update(self.vm); love.graphics.setShader(lp.bg) end
  love.graphics.draw(lp and self.def.index or self.def.image, -L, -T)
  for _, p in ipairs(self.patches) do
    love.graphics.draw(lp and self.atlasIndex or self.atlas, love.graphics.newQuad((p.mt % 16) * 16, math.floor(p.mt / 16) * 16, 16, 16, 256, 256), p.x * 16 - L, p.y * 16 - T)
  end
  if lp then love.graphics.setShader(lp.obj) end
  for _, o in pairs(self.objects) do
    if o.dirty then Sprites.build(self, o); o.dirty = false end
    if os.getenv("MN_RDBG") and self.map == tonumber(os.getenv("MN_RDBG")) and (self.vm.tk or 0) % 30 == 0 and _ ~= 0 and _ ~= 2 then print(("[rdbg] f%d slot %s at %d,%d o=%s,%s img=%s dorm=%s blank=%s cam=%d,%d off=%s fix=%s pan=%s"):format(self.vm.tk or 0, tostring(_), o.x, o.y, tostring(o.ox), tostring(o.oy), tostring(o.image ~= nil), tostring(o.dormant), tostring(o.blank), cx, cy, self.camOff and (self.camOff[1] .. "," .. self.camOff[2]) or "-", self.camFix and (self.camFix[1] .. "," .. self.camFix[2]) or "-", self.panv and table.concat(self.panv, ",") or "-")) end
    -- record byte 0 bit 7 (dormant) objects aren't drawn: PyBoy map 40 slots 5-7
    -- stay $80 and show no OAM until $0B wakes them
    if o.image and not o.dormant and not o.blank and not o.picking then
      local dx, dy = o.x * 16 - 24 + (o.ox or 0), o.y * 16 - 24 + (o.oy or 0)
      -- wide view only: a record parked off the map (scripts hide actors past
      -- the classic screen) stays hidden unless it overlaps the classic frame
      if not wide or not Viewport.offstage(dx, dy, o.image:getWidth(), o.image:getHeight(), W, H, cx, cy) then
        love.graphics.draw(o.image, dx - L, dy - T)
      end
    end
  end
  -- QueueRepeatedSpriteList: the kick / push lunge draws that record's
  -- bank-$20 list at the wobbled origin. A zero pointer keeps the walker.
  if not self.hidePlayer then
    local pose = Sprites.lungeList(self.push) or Sprites.lungeList(self.kick)
    local img = pose and Sprites.playerList(self, pose)
    if img then love.graphics.draw(img, self.px - L - 24, self.py - T - 24)
    else love.graphics.draw(self.sheet, self.quads[self:frame()], self.px - L - 8, self.py - T - 8) end
  end
  if lp then love.graphics.setShader() end
  end
  if self.textBox then self:classicFrame(wide, ux, uy, function() Font.drawTyped(self.textBox, self.def.pal7, self.vm.rom) end) end
end


-- $1F music: decode the song from the cached ROM banks and loop it.
local MnMusic = require("mn.MnMusic")
local musicCache = {}
function M:playMusic(v)
  -- Same mute rule as SfxOut (SDL_AUDIODRIVER=dummy, MN_NOMUSIC, MN_MUTE). love plays
  -- through OpenAL, so the SDL driver alone never silenced this path.
  if require("mn.SfxOut").muted() then return end
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

-- Using an object runs its record script as the slot's thread, unless that script only
-- plants its talk ($5B bank ptr then $42): then the talk itself runs (plain NPCs).
function M.useRunsRecord(rom, bank, ptr)
  local o = bank * 0x4000 + ptr - 0x4000
  if rom:u8(o) ~= 0x5B then return true end
  return rom:u8(o + 4) ~= 0x42
end

return M
