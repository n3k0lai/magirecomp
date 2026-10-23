local TRK = os.getenv("MN_TRK")
local WATCH = tonumber(os.getenv("MN_WATCH") or "", 16) -- MN_WATCH=A125: report writes to that address
local OPLOG = tonumber(os.getenv("MN_OPLOG") or "", 16) -- MN_OPLOG=14: print every op run in that bank
-- Magi-Nation script engine (bank-1 dispatcher $0A66, table $01:$42C3, opcodes
-- $00-$AF) in Lua. Operand sizes come from src/mn/Opcodes.lua (generated from
-- mn-gfx scripts/script/opcodes.py). Implemented handlers cite their decomp
-- routine; everything else is logged once and skipped by its size.
local bit = require("bit")
local band, bor, lshift = bit.band, bit.bor, bit.lshift
local Op = require("mn.Opcodes")
local Ext = require("mn.OpExt").handlers

local VM = {}
VM.__index = VM

-- rom: object with u8/u16/insn/exprSize (MnRom over the cached script banks)
-- host: callbacks loadMap(i), setTriggers(ptr), setAList(ptr), runAList(entries),
--       spawn(slot, x, y), objPalette(bank, ptr), text(str) -> yields
function VM.new(rom, host)
  return setmetatable({ rom = rom, host = host, mem = {}, logged = {}, log = {} }, VM)
end

-- Object script records run as threads (one per slot + the $C71B text record).
function VM:spawnThread(slot, bank, ptr)
  self.threads = self.threads or {}
  local co = coroutine.create(function() self:run(bank, ptr) end)
  self.threads[slot] = { co = co, wait = 0, slot = slot }
end

-- $C71B record planted by a cutscene actor: run it as the dialogue thread,
-- held while the title card owns the screen ([$C6F3] == 0).
function VM:spawnTalk(bank, ptr)
  self.threads = self.threads or {}
  local co = coroutine.create(function()
    while self.mem[0xC6F3] == 0 do coroutine.yield("wait", 1) end
    self:run(bank, ptr)
  end)
  self.threads.talk = { co = co, wait = 0, slot = "talk" }
end

function VM:tickThreads(textOpen)
  -- AddAndShiftUnknown, rendezvous half: C6F6 += C6F5 (arrivals this frame), C6F5 := 0;
  -- the carry out of $FF bumps the phase C6F7 and releases the $5C waiters
  local sum = (self.mem[0xC6F6] or 0) + (self.mem[0xC6F5] or 0)
  if sum > 0xFF then self.mem[0xC6F7] = ((self.mem[0xC6F7] or 0) + 1) % 256; sum = 0 end
  self.mem[0xC6F6], self.mem[0xC6F5] = sum, 0
  for a = 0xC6F8, 0xC6FC, 2 do
    -- AddAndShiftUnknown on hardware: C6F9 := C6F8, C6F8 := 0 every frame (a post
    -- lives one frame). Our main VM and threads don't tick in one lockstep loop
    -- (text boxes pause the main VM), so a one-frame post gets missed (Eidon
    -- 2A:42A9 $60 $2A deadlock). Latch nonzero posts instead.
    local v = self.mem[a]; if v and v ~= 0 then self.mem[a + 1] = v; self.mem[a] = 0 end
  end
  if not self.threads then return end
  if os.getenv("MN_THR") then
    self.pcs = self.pcs or {}; self.tk = (self.tk or 0) + 1
    if self.tk % 200 == 0 then
      local parts = {}
      for k, t in pairs(self.threads) do local o = self.pcs[t.co]; parts[#parts + 1] = ("%s@%02X:%04X%s w%d"):format(tostring(k), o and math.floor(o / 0x4000) or 0, o and o % 0x4000 + 0x4000 or 0, t.text and "T" or "", t.wait) end
      print(("[thr] f%d %s | C6F9=%02X C6FB=%02X C6FD=%02X C6F3=%02X"):format(self.tk, table.concat(parts, " "), self:rd8(0xC6F9), self:rd8(0xC6FB), self:rd8(0xC6FD), self:rd8(0xC6F3)))
    end
  end
  for k, t in pairs(self.threads) do
    if t.text and not textOpen then t.text = nil end
    local asleep = type(t.slot) == "number" and self.host.slotActive and not self.host.slotActive(t.slot)
    if not t.text and not asleep then
      if t.wait > 0 then t.wait = t.wait - 1 end
      if t.wait <= 0 then
        self.curSlot = type(t.slot) == "number" and t.slot or nil
        self.curKey = k
        local ok, why, arg = coroutine.resume(t.co)
        self.curSlot = nil
        if not ok then print("[vm] thread " .. tostring(k) .. " error " .. tostring(why)); self.threads[k] = nil
        elseif coroutine.status(t.co) == "dead" then
          if os.getenv("MN_THR") then local o = self.pcs and self.pcs[t.co]; print(("[thr] %s ended at %s"):format(tostring(k), o and ("%02X:%04X op %02X"):format(math.floor(o / 0x4000), o % 0x4000 + 0x4000, self.rom:u8(o)) or "?")) end
          if self.threads[k] == t then self.threads[k] = nil end
        elseif why == "wait" then t.wait = arg or 1
        elseif why == "text" then t.text = true end
      end
    end
  end
end

function VM:rd8(a) return self.mem[a] or 0 end
function VM:rd16(a) return self:rd8(a) + lshift(self:rd8(a + 1), 8) end
function VM:wr8(a, v)
  if WATCH and a == WATCH then print(("[watch] %04X <- %02X at %s"):format(a, band(v, 0xFF), self.lastO and ("%02X:%04X"):format(math.floor(self.lastO / 0x4000), self.lastO % 0x4000 + 0x4000) or "?")) end
  self.mem[a] = band(v, 0xFF)
end

local function off(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end
VM.off = off

-- LookupWordAt1234 ($1397): index byte, then per-index operands (lookup_index_N.asm)
function VM:expr(o)
  local r = self.rom; local i = r:u8(o); o = o + 1
  local function two() local a; a, o = self:expr(o); local b; b, o = self:expr(o); return a, b end
  local T = 0xFFFF
  if i == 0 then local a = r:u16(o); local m = r:u8(o + 2); return (band(self:rd8(a), m) ~= 0) and T or 0, o + 3
  elseif i == 1 then return self:rd8(r:u16(o)), o + 2
  elseif i == 2 then return self:rd16(r:u16(o)), o + 2
  elseif i == 3 then return band(bit.bnot(self:rd8(0xC189)), 3), o
  elseif i == 4 then return self:rd16(0xA123), o -- story word in SRAM
  elseif i == 5 then return r:u8(o), o + 1
  elseif i == 6 then return r:u16(o), o + 2
  elseif i == 7 then local a, b = two(); return band(a, b), o
  elseif i == 8 then local a, b = two(); return (a ~= 0 and b ~= 0) and T or 0, o
  elseif i == 9 then local a, b = two(); return (a ~= 0 or b ~= 0) and T or 0, o
  elseif i == 10 then local a; a, o = self:expr(o); return a == 0 and T or 0, o
  elseif i == 11 then local a, b = two(); return band(a + b, T), o
  elseif i == 12 then local a, b = two(); return band(a - b, T), o
  elseif i == 13 then local a; a, o = self:expr(o); return band(a + 1, T), o
  elseif i == 14 then local a; a, o = self:expr(o); return band(a - 1, T), o
  elseif i == 15 then local a, b = two(); return a == b and T or 0, o
  elseif i == 16 then local a, b = two(); return a ~= b and T or 0, o
  elseif i == 17 then local a, b = two(); return b < a and T or 0, o
  elseif i == 18 then local a, b = two(); return a >= b and T or 0, o
  elseif i == 19 then local a, b = two(); return a < b and T or 0, o
  elseif i == 20 then local a, b = two(); return b >= a and T or 0, o
  elseif i == 21 then return 0, o
  elseif i == 22 then return self:expr(o + 1) -- WRAM bank select, flat memory here
  end
  return 0, o
end

function VM:note(op)
  if not self.logged[op] then
    self.logged[op] = true
    local s = ("[vm] unimplemented $%02X %s (skipped)"):format(op, Op.NAMES[op] or "?")
    self.log[#self.log + 1] = s; print(s)
  end
end

-- Run a script from (bank, ptr) as a coroutine; text boxes yield.
-- Map-setup run (LCD off): no yields; stops at text or park.
function VM:runInit(bank, ptr)
  local saved = self.init; self.init = true
  local co = coroutine.create(function() self:run(bank, ptr) end)
  local ok, err = coroutine.resume(co)
  if not ok then print("[vm] init error " .. tostring(err)) end
  self.init = saved
end

function VM:start(bank, ptr)
  self.co = coroutine.create(function() self:run(bank, ptr) end)
  return self:resume()
end

function VM:resume()
  if not self.co then return false end
  local ok, err, arg = coroutine.resume(self.co)
  if ok and err == "wait" then self.wait = arg end
  self.textWait = ok and err == "text" or nil
  if not ok then print("[vm] error " .. tostring(err)); self.co = nil; return false end
  if coroutine.status(self.co) == "dead" then self.co = nil; return false end
  return true -- waiting (text box)
end

function VM:run(bank, ptr)
  local r, h = self.rom, self.host
  local o = off(ptr, bank)
  local steps = 0
  while steps < 4000 do
    steps = steps + 1
    local op = r:u8(o)
    local n = r:insn(o)
    if self.pcs then self.pcs[coroutine.running() or 0] = o end
    if TRK and self.curKey == TRK and self.tk and self.tk > 7300 then print(("[trk] f%d %02X:%04X op %02X"):format(self.tk, math.floor(o / 0x4000), o % 0x4000 + 0x4000, r:u8(o))) end
    if WATCH then self.lastO = o end
    if OPLOG and math.floor(o / 0x4000) == OPLOG then print(("[op] %02X:%04X %02X key %s"):format(OPLOG, o % 0x4000 + 0x4000, op, tostring(self.curKey))) end
    if not n then self:note(op); return end
    local cur = { bank = math.floor(o / 0x4000), ptr = o % 0x4000 + 0x4000 }
    local function jump(b, p) o = off(p, b) end
    if op == 0x93 then -- FinishStartup: default state (object records) reinstalled, script continues
      if h.freshScene and not self.init then h.freshScene() end
      o = o + 1
    elseif op == 0x65 then -- $1820 -> LoadFiveBankedMapSources (bank $4F record)
      if r:u8(o + 3) == 0x4F then h.loadMap((r:u16(o + 1) - 0x4000) / 15) end; o = o + n
    elseif op == 0x64 then h.setTriggers(r:u16(o + 1)); o = o + n -- ReadBank21ByteThenResume
    elseif op == 0x69 then h.setAList(r:u16(o + 1)); o = o + n -- RunBank21ScriptList ($2C97)
    elseif op == 0x66 then h.objPalette(r:u8(o + 3), r:u16(o + 1)); o = o + n -- $2EE9 OBJ palettes
    elseif op == 0x05 then -- object record from script (opcode_05.asm)
      -- slot, handler word, cell x, cell y, word, tile base, anim (bank, ptr), script (bank, ptr)
      if r:u8(o + 1) == 0 then
        -- a door's $02 pair normally wins (applied by a later $00); when it lands on a wall
        -- in this map (seen entering the ringsmith, 59) the record's own cell is used
        if not self.pair then h.placePlayer(r:u8(o + 4), r:u8(o + 5))
        elseif h.cellOpen and not h.cellOpen(self.pair[1], self.pair[2]) then self.pair = nil; h.placePlayer(r:u8(o + 4), r:u8(o + 5)) end
      end
      h.spawn(r:u8(o + 1), r:u8(o + 4), r:u8(o + 5), r:u16(o + 2), r:u8(o + 8), r:u8(o + 9), r:u16(o + 10), r:u8(o + 12), r:u16(o + 13)); o = o + n
    elseif op == 0x01 then -- opcode_01.asm: wScriptPair ($C9A1 col, $C9A2 row)
      self.pair = { r:u8(o + 1), r:u8(o + 2) }; o = o + n
    elseif op == 0x02 then -- opcode_02.asm: pair = (C18E - b0) + b1, (C18F - b2) + b3
      local px, py = h.playerCell()
      self.pair = { (px - r:u8(o + 1) + r:u8(o + 2)) % 256, (py - r:u8(o + 3) + r:u8(o + 4)) % 256 }; o = o + n
    elseif op == 0x00 then -- Opcode00 -> bank 1 $4423: C9A1 copied to C18E (player map cell)
      if self.pair then h.placePlayer(self.pair[1], self.pair[2]); self.pair = nil end; o = o + n
    elseif op == 0x13 then -- Opcode13 (word): this record's handler := word, yield
      o = o + n
      if not self.init then
        -- $5D81 is the player-control handler: slot 0 hands control back to the pad
        if self.curSlot and h.setHandler then h.setHandler(self.curSlot, r:u16(o - 2)) end
        if self.curSlot == 0 and r:u16(o - 2) == 0x5D81 and h.release then h.release(0); return end
        coroutine.yield("wait", 1)
      end
    elseif op == 0x30 then -- Opcode30: C840/C841 := b1,b2; b3 = sound index ($FF keeps)
      self:wr8(0xC840, r:u8(o + 1)); self:wr8(0xC841, r:u8(o + 2))
      local v = r:u8(o + 3)
      if v ~= 0xFF and not self.init and self:rd8(0xC920) ~= v then self:wr8(0xC920, v); h.music(v) end
      o = o + n
    elseif op == 0x25 then -- Opcode25: battle setup (C9E4, D391 kind, D36D, battle script record)
      if h.battleBegin and not self.init then h.battleBegin({ r:u8(o + 1), r:u8(o + 2), r:u8(o + 3), r:u8(o + 4), r:u16(o + 5) }) end
      o = o + n
    elseif op == 0x2E or op == 0x2C or op == 0x2D or op == 0x26 or op == 0x28 then
      -- battle-engine record ops ($2E: five bytes to D392 then bank 2 $752D = add combatant)
      local args = {}; for i = 1, n - 1 do args[i] = r:u8(o + i) end
      if h.battleOp and not self.init then h.battleOp(op, args) end
      o = o + n
    elseif op == 0x2B then o = o + n; if not self.init then coroutine.yield("wait", 1) end -- lets D3C2 wait finish
    elseif op == 0x27 then -- Opcode27: run the battle until D3C2 clears
      o = o + n
      if h.battleRun and not self.init then
        h.battleRun()
        while h.battleActive() do coroutine.yield("wait", 1) end
        -- the engine never resumes this stream (dispatch_nonzero_d016.asm): a loss
        -- (mode 3) continues at the $31 record's second script ($D3D0), anything else
        -- at its first ($D3CD). Scripted duels use it (Korg 14:6EAD -> win 14:6B30);
        -- the port keeps the field through wild encounters, so the record is only
        -- followed when a $31 ran since the last battle.
        local lost = h.battleResult and h.battleResult() == "loss"
        local k = lost and 0x7D3D0 or 0x7D3CD
        if self.duelTail and self:rd8(k) ~= 0 then
          self.duelTail = nil
          jump(self:rd8(k), self:rd8(k + 1) + 256 * self:rd8(k + 2))
        else
          self.duelTail = nil
          return
        end
      end
    elseif op == 0x82 then -- CenterFineScrollOnScriptBase
      -- a door pair still pending here (entry had no $00) is the spawn cell
      if self.pair and not self.init and h.cellOpen and h.cellOpen(self.pair[1], self.pair[2]) then h.placePlayer(self.pair[1], self.pair[2]); self.pair = nil end
      h.centerCamera(); o = o + n
    elseif op == 0x0B then h.slotFlag(r:u8(o + 1)); o = o + n -- opcode_0b.asm: clear bit 7 of slot record
    elseif op == 0x94 then -- MarkScriptDone21B2: stop this frame's loop, resume at the next opcode
      if self.init then return end
      o = o + n; coroutine.yield("wait", 1)
    elseif op == 0x9B then -- Opcode9B: proceeds only when wUnknownC6EE == 2, else parks on $9D
      if self.init then return end
      if h.boxOpen then h.boxOpen(r:u16(o + 1)) end -- word: portrait record ($7078 = none)
      o = o + n
    elseif op == 0x24 then o = o + n; coroutine.yield("wait", r:u8(o - 1)) -- Opcode20 alias: countdown
    elseif op == 0x46 then o = off(r:u16(o + 1), cur.bank) -- FollowScriptWord: jump in bank
    elseif op == 0x9A then -- Opcode9A: wait until the window is finished/dismissed, then close it
      if not self.init and h.boxBusy and coroutine.running() then
        local guard = 0
        while h.boxBusy() and guard < 3600 do guard = guard + 1; coroutine.yield("wait", 1) end
      end
      if h.boxClose then h.boxClose() end; o = o + n
    elseif op == 0x42 or op == 0x12 then return -- InstallParkedScript / Opcode12: park the record
    elseif op == 0x6B then h.glyphCopy(r:u8(o + 1), r:u8(o + 2), r:u16(o + 3), r:u16(o + 5), r:u8(o + 7)); o = o + n -- ArmCopyGlyphFromScript ($1946): count, wCallbackBank, wGlyphSrc, wGlyphDest, wGlyphVRAMBank; CopyGlyph moves 16 bytes per count
    elseif op == 0x56 or op == 0x57 or op == 0x58 then
      -- StoreScriptByteAtC6F8/A/C: mailbox post; stall while the box is full.
      -- tickThreads moves C6F8->C6F9 (A->B, C->D) once per frame.
      local a = 0xC6F8 + (op - 0x56) * 2
      if self.init then if self:rd8(a) ~= 0 then return end
      else while self:rd8(a) ~= 0 do coroutine.yield("wait", 1) end end
      self:wr8(a, r:u8(o + 1)); o = o + n
    elseif op == 0x60 or op == 0x61 or op == 0x62 then
      -- LoadC6F9/B/D ThenMatchScriptByte: wait until the mailbox reads the byte
      local a = 0xC6F9 + (op - 0x60) * 2
      if self.init then return end
      while self:rd8(a) ~= r:u8(o + 1) do coroutine.yield("wait", 1) end
      o = o + n
    elseif op == 0x14 then -- Opcode14 (bank, ptr): object anim, non-blocking
      if self.curSlot and h.setAnim then h.setAnim(self.curSlot, { { r:u8(o + 1), r:u16(o + 2), 0 } }) end
      o = o + n
    elseif op == 0x15 then
      -- Opcode15 (bank, ptr, frames)* until $00: a timed anim schedule; the record's
      -- script waits for it to finish.
      local recs, q, total = {}, o + 1, 0
      while r:u8(q) ~= 0 and #recs < 48 do
        recs[#recs + 1] = { r:u8(q), r:u16(q + 1), r:u8(q + 3) }; total = total + r:u8(q + 3); q = q + 4
      end
      o = q + 1
      if self.curSlot and h.setAnim then
        h.setAnim(self.curSlot, recs)
        if total > 0 then coroutine.yield("wait", total) end
      end
    elseif op == 0x16 then
      -- Opcode16 (bank, ptr, frames, sx, sy)* until $00: each anim plays in place while
      -- Opcode16AddScroll adds (sx, sy) to the scroll deltas $C843/$C844 every frame;
      -- the walker rides the scroll, so it only travels as far as the camera can.
      -- PyBoy: Eidon 13:58C2 (0E:53A0, $80 frames, 01,00) arrives 8 cells right; the
      -- Tavel Gorge kids 1F:50CD (00,FF, camera already at the map top) stay on row 3.
      local q = o + 1
      while r:u8(q) ~= 0 do
        local b, p, nf = r:u8(q), r:u16(q + 1), r:u8(q + 3)
        local sx, sy = r:u8(q + 4), r:u8(q + 5)
        if sx >= 128 then sx = sx - 256 end; if sy >= 128 then sy = sy - 256 end
        q = q + 6
        if self.curSlot and h.setAnim then
          h.setAnim(self.curSlot, { { b, p, nf } }, true)
          if (sx ~= 0 or sy ~= 0) and nf > 0 then h.pan(nf, sx, sy, self.curSlot) end
          if nf > 0 then coroutine.yield("wait", nf) end
        end
      end
      o = q + 1
    elseif op >= 0x53 and op <= 0x55 then -- ArmC6F8/A/CUnlessSet: post $FF once the box is empty
      local a = 0xC6F8 + (op - 0x53) * 2
      if self.init then if self:rd8(a) ~= 0 then return end
      else while self:rd8(a) ~= 0 do coroutine.yield("wait", 1) end end
      self:wr8(a, 0xFF); o = o + n
    elseif op >= 0x5D and op <= 0x5F then -- LoadC6F9/B/D ThenPlantHandlerUnlessZero: wait for any post
      local a = 0xC6F9 + (op - 0x5D) * 2
      if self.init then return end
      while self:rd8(a) == 0 do coroutine.yield("wait", 1) end
      o = o + n
    elseif op == 0x5C then
      -- StageNextScriptIfByteAtMostC6F7 (phase, n) + DispatchIfC6F6IsZeroElseMarkIt ($1756):
      -- wait for phase C6F7 >= byte, arrive (C6F5 += 1), then each frame: C6F6 = 0 ->
      -- go on; below n -> wait; else mark (C6F5 := 1, C6F6 := $FF) so the frame-end
      -- add carries, bumping the phase and releasing all n parties together.
      -- PyBoy: after the inn save 28:58EE (main) and Tony's 28:58FE (slot 0) meet with $00, $02.
      if self.init then return end
      while self:rd8(0xC6F7) < r:u8(o + 1) do coroutine.yield("wait", 1) end
      self:wr8(0xC6F5, self:rd8(0xC6F5) + 1)
      local need = r:u8(o + 2)
      while true do
        coroutine.yield("wait", 1)
        local f6 = self:rd8(0xC6F6)
        if f6 == 0 then break end
        if f6 >= need then self:wr8(0xC6F5, 1); self:wr8(0xC6F6, 0xFF) end
      end
      o = o + n
    elseif op == 0x5A then -- FillScriptRecordC70DFromScript (bank, ptr): run as a record thread
      if not self.init then
        self.threads = self.threads or {}
        local b, p = r:u8(o + 1), r:u16(o + 2)
        self.threads.c70d = { co = coroutine.create(function() self:run(b, p) end), wait = 0, slot = "c70d" }
      end
      o = o + n
    elseif op == 0x0C then if h.slotSleep then h.slotSleep(r:u8(o + 1)) end; o = o + n -- Opcode0C: set record bit 7
    elseif op == 0x6E or op == 0x6F then -- fade to (4850) / back from (4837) a BGR555 colour
      local w = r:u16(o + 2)
      if h.fade and not self.init then h.fade(w, op == 0x6E) end
      o = o + n
    elseif op == 0x76 or op == 0x77 or op == 0x7A then -- SetCCA6Countdown*: wait (second byte) frames
      o = o + n
      if not self.init then coroutine.yield("wait", math.max(1, r:u8(o - 1))) end
    elseif op == 0x1B then self:wr8(0xC921, r:u8(o + 1)); if h.sfxSlot then h.sfxSlot(1, r:u8(o + 1)) end; o = o + n -- wSoundSlotA
    elseif op == 0x1C then self:wr8(0xC922, r:u8(o + 1)); if h.sfxSlot then h.sfxSlot(2, r:u8(o + 1)) end; o = o + n -- wSoundSlotB
    elseif op == 0x21 then self:wr8(0xC91F, 1); o = o + n -- wSoundRequest = 1
    elseif op == 0x48 then o = o + n; if not self.init then coroutine.yield("wait", 1) end -- PlantInitialScriptHandler: resume next pass
    elseif op == 0x80 then -- WriteScriptBytesAcrossWramBanks: word, addr, bank-5 byte (collision), bank-3 byte (metatile)
      local a, col, mt = r:u16(o + 3), r:u8(o + 5), r:u8(o + 6)
      if h.setCell then h.setCell(a, col, mt) end
      o = o + n; if not self.init then coroutine.yield("wait", 1) end
    elseif op == 0x1A then -- Opcode1A: proceed once WRAM3[[FF93]] == byte (polls)
      local want, g = r:u8(o + 1), 0
      while h.cellByte and self:rd16(0xFF93) >= 0xD000 and h.cellByte(self:rd16(0xFF93)) ~= want and g < 600 and not self.init do g = g + 1; coroutine.yield("wait", 1) end
      o = o + n
    elseif op == 0x70 or op == 0x71 or op == 0x74 then -- split-byte countdowns ($FFA7 low 6 bits x $FFA6 high 2 + 1)
      local b = r:u8(o + 1)
      if op == 0x70 then self:wr8(0xC9D9, r:u8(o + 2)) end
      o = o + n
      if not self.init then coroutine.yield("wait", math.max(1, (bit.rshift(b, 6) + 1) * math.max(1, band(b, 0x3F)))) end
    elseif op == 0x79 then self:wr8(0xC9D8, r:u8(o + 1)); o = o + n -- StoreScriptByteCall481E (bank 7 UI call: INCBIN)
    elseif op == 0x96 then -- SaveScriptTripleToSRAM: bank, ptr -> sSavedScriptBank/Ptr ($A012-$A014); pair -> $A015
      self:wr8(0xA012, r:u8(o + 1)); self:wr8(0xA013, r:u8(o + 2)); self:wr8(0xA014, r:u8(o + 3)); o = o + n
    elseif op == 0x89 or op == 0x8A then -- (bank-7 $4087 call for $8A: INCBIN) LoadSRAMScriptAndDispatch
      local p = self:rd8(0xA013) + 256 * self:rd8(0xA014)
      if p ~= 0 then jump(self:rd8(0xA012), p) else o = o + n end
    elseif op == 0x38 or op == 0x39 then self:note(op); o = o + n -- targets still INCBIN (LCD-off record loop / $1126 / SRAM save)
    elseif op == 0x11 then -- Opcode11 -> $0C8F (INCBIN). PyBoy cave-in records: the
      -- slot lands on a random on-screen cell (cam col+1..+9, row+0..+8), then its
      -- next $47 pick plays one of six rock-fall anims
      o = o + n
      if h.scatter and self.curSlot and not self.init then h.scatter(self.curSlot); coroutine.yield("wait", 1) end
    elseif op == 0x7C or op == 0x7D then -- scroll nudge: target cell - 5 per axis, then speed byte
      if os.getenv("MN_THR") then print(("[nudge] op %02X at %X"):format(op, o)) end
      local tc, tr, spd
      if op == 0x7C then tc, tr, spd = (r:u8(o + 1) - 5) % 256, (r:u8(o + 2) - 5) % 256, r:u8(o + 3)
      else
        local x, y = 5, 5
        if h.slotCell then x, y = h.slotCell(r:u16(o + 1)); x, y = x or 5, y or 5 end
        tc, tr, spd = x < 5 and 0 or x - 5, y < 5 and 0 or y - 5, r:u8(o + 3)
      end
      o = o + n
      if spd >= 128 then spd = 256 - spd end
      if h.nudge and not self.init then
        local g = 0
        while not h.nudge(tc, tr, spd) and g < 2000 do g = g + 1; coroutine.yield("wait", 1) end
      end
    elseif op == 0x7E then -- StageEightScriptBytes: src word, w, h, dst word, 2 more; copies one cell/frame
      local src, w, hh, dst = r:u16(o + 1) - 0xD000, r:u8(o + 3), r:u8(o + 4), r:u16(o + 5) - 0xD000
      o = o + n
      if h.copyCell and not self.init then
        local W = h.mapWidth and h.mapWidth() or 1
        for yy = 0, hh - 1 do for xx = 0, w - 1 do
          h.copyCell(src + yy * W + xx, dst + yy * W + xx); coroutine.yield("wait", 1)
        end end
      end
    elseif op == 0x19 then -- opcode_19.asm: set bit 7 of the running record (dormant), yield
      o = o + n
      if self.curSlot == 0 or not self.curSlot then if h.release then h.release(self.curSlot) end
      elseif not self.init then
        if h.slotSleep then h.slotSleep(self.curSlot) end
        coroutine.yield("wait", 1)
      end
    elseif op == 0x09 then -- Opcode09 (slot, bank, ptr): give a slot a new script
      -- a sprite-bank target is a plain anim: slot 0 then becomes the player again
      -- (bank $14 holds both anims and scripts: a $15/$16 schedule head is a script)
      local hd = r:u8(off(r:u16(o + 3), r:u8(o + 2)))
      if os.getenv("MN_THR") then print(("[op09] slot %d -> %02X:%04X head %02X sprite=%s init=%s by %s pc %X"):format(r:u8(o + 1), r:u8(o + 2), r:u16(o + 3), hd, tostring(h.isSpriteBank and h.isSpriteBank(r:u8(o + 2))), tostring(self.init), tostring(self.curKey), o)) end
      if h.isSpriteBank and h.isSpriteBank(r:u8(o + 2)) and not (r:u8(o + 2) == 0x14 and (hd == 0x15 or hd == 0x16)) then
        local sl = r:u8(o + 1)
        if self.threads and self.threads[sl] and self.threads[sl].co ~= coroutine.running() then self.threads[sl] = nil end
        if sl == 0 and h.release then h.release(0)
        elseif h.setAnim then h.setAnim(sl, { { r:u8(o + 2), r:u16(o + 3), 0 } }) end
      else
        -- port objects spawn dormant by default; a script handed to one means it runs
        if not self.init and r:u8(o + 1) ~= 0 and h.slotFlag then h.slotFlag(r:u8(o + 1)) end
        self:spawnThread(r:u8(o + 1), r:u8(o + 2), r:u16(o + 3))
      end
      o = o + n
    elseif op == 0x5B then -- FillScriptRecordC71BUnlessC6EEIs1: stalls while C6EE==1
      if (self.curSlot or self.fromA) and not self.init then
        -- C6EE == 1 while a dialogue owns the window: one talk record at a time
        while self:rd8(0xC6EE) == 1 or (self.threads and self.threads.talk and coroutine.status(self.threads.talk.co) ~= "dead") do coroutine.yield("wait", 1) end
        self:spawnTalk(r:u8(o + 1), r:u16(o + 2))
      end
      o = o + n
    elseif op == 0xAF then -- OrScriptMaskIntoSram: SRAM[word] |= mask
      local a = r:u16(o + 1); self:wr8(a, bit.bor(self:rd8(a), r:u8(o + 3))); o = o + n
    elseif op == 0xAE then -- AndScriptMaskIntoSram ($2869): SRAM[word] &= mask
      local a = r:u16(o + 1); self:wr8(a, band(self:rd8(a), r:u8(o + 3))); o = o + n
    elseif op == 0x07 then -- opcode_07.asm: slot record bytes 1-2 := two script bytes
      h.slotFields(r:u8(o + 1), r:u8(o + 2), r:u8(o + 3)); o = o + n
    elseif op == 0x31 then -- opcode_31.asm: six bytes to WRAM 7 $D3CD-$D3D2
      for k = 0, 5 do self:wr8(0x7D3CD + k, r:u8(o + 1 + k)) end; o = o + n
      self.duelTail = true -- a battle started from here returns through these records
    elseif op == 0x1F then -- opcode_1f.asm: music index (wSoundIndex $C920), wSoundActive on change
      local v = r:u8(o + 1)
      if self:rd8(0xC920) ~= v then self:wr8(0xC920, v); self:wr8(0xC91E, 1); h.music(v) end
      self:wr8(0xC92A, 0); self:wr8(0xC92C, 0x0F); o = o + n
    elseif op == 0xA9 then -- StoreScriptWordAtA123: story-progress word
      self:wr8(0xA123, r:u8(o + 1)); self:wr8(0xA124, r:u8(o + 2)); o = o + n
      -- then bank 7 $40E6 (clear_sram_after_script_word.asm): $7F bytes from $A125 and
      -- from $A224 are zeroed, so per-chapter flags reset with each new story word
      -- (PyBoy: the cave's 1F:5EB4 A125 bit is gone after Orwin; 14:50BA tests it at A123=3)
      for a = 0xA125, 0xA125 + 0x7E do self.mem[a] = nil end
      for a = 0xA224, 0xA224 + 0x7E do self.mem[a] = nil end
    elseif op == 0x99 then if h.boxClose then h.boxClose() end; o = o + n -- Opcode99: window slides closed
    elseif op == 0x91 then o = o + n -- bank-1 SRAM fill (new-game init); our SRAM table starts zeroed
    elseif op == 0x84 then -- CenterFineScrollOnScriptWord: wMapColumn = E-5, wMapRow = D-5 (window top-left cell)
      if h.cameraCell then h.cameraCell(r:u8(o + 1) - 5, r:u8(o + 2) - 5) else h.centerCamera() end; o = o + n
    elseif op == 0x68 then o = o + n -- unpack into WRAM4/6 (map-record overlay); cells come from loadMap
    elseif op == 0x1D then if h.sfx then h.sfx(2) end; o = o + n -- wSoundRequest = 2
    elseif op == 0x44 then -- SkipTwoUnlessLcdOff
      o = o + n
    elseif op == 0xA4 then
      -- PlantOffset7ThenStoreFF ($25DA): SRAM flag word, mask, reward (category,
      -- id), WRAM-3 map cell word. LCD off (map setup): flag set -> cell := $FF
      -- (opened chest) and continue; clear -> park. LCD on (A press, $25FA):
      -- flag set -> script 22:405B; else sound $11, CopyThreeBank7 ($7350) gives
      -- the reward, flag |= mask, cell := $FF, continue at 22:4048 (22:4074 when full).
      local W, m, cat, id, cell = r:u16(o + 1), r:u8(o + 3), r:u8(o + 4), r:u8(o + 5), r:u16(o + 6)
      local set = band(self:rd8(W), m) ~= 0
      if self.init then
        if set then h.setMetatile(cell, 0xFF); o = o + n else return end
      elseif set then jump(0x22, 0x405B)
      else
        local given = h.giveReward(cat, id)
        self.nameBuf = self:recordName(cat, id)
        if given then
          self:wr8(W, bor(self:rd8(W), m)); h.setMetatile(cell, 0xFF); h.sound(0x11)
          jump(0x22, 0x4048)
        else jump(0x22, 0x4074) end
      end -- MarkScriptDone21B2: wScriptDone ends the record
    elseif op == 0xA3 then
      -- PlantParkedHandlerThenStage: SRAM flag word, mask, (bank, ptr), metatile,
      -- WRAM-3 cell word. LCD off: flag set -> cell := metatile; park either way.
      -- LCD on (A press): flag set -> (bank, ptr) ("nothing else here"); else
      -- flag |= mask, cell := metatile, continue (PyBoy map 60 fireplace, 2B:403F).
      local W, m, b, p, mt, cell = r:u16(o + 1), r:u8(o + 3), r:u8(o + 4), r:u16(o + 5), r:u8(o + 7), r:u16(o + 8)
      local set = band(self:rd8(W), m) ~= 0
      if self.init then
        if set then h.setMetatile(cell, mt) end
        return
      elseif set then jump(b, p)
      else self:wr8(W, bor(self:rd8(W), m)); h.setMetatile(cell, mt); o = o + n end
    elseif op == 0x87 then
      -- CopyThreeBytesCallBank7 (category, id, count) via table 07:5D7F; the record
      -- name goes to the <SWAP> buffer. PyBoy: Evu's spellbook $87 03 01 01 -> A5A6 = $08,
      -- the ring trade $87 04 04 32 -> Animite word A3A5 = $32.
      local cat, id, cnt = r:u8(o + 1), r:u8(o + 2), r:u8(o + 3)
      if cat == 0 then -- item count A3A7+id, clamped to the cap 6 bytes before the record
        local a, cap = 0xA3A7 + id, r:u8(self:recordOff(0, id) - 6)
        self:wr8(a, math.min(cap, self:rd8(a) + cnt))
      elseif cat == 3 then -- spell: A5A5+id := the byte 8 before the spell record
        self:wr8(0xA5A5 + id, r:u8(self:recordOff(3, id) - 8))
      elseif cat == 4 then -- Animite: little-endian word, capped at 999
        local v = math.min(999, self:rd8(0xA3A5) + self:rd8(0xA3A6) * 256 + cnt)
        self:wr8(0xA3A5, v % 256); self:wr8(0xA3A6, math.floor(v / 256))
      else self:note(op) end
      if cat == 0 or cat == 3 then self.nameBuf = self:recordName(cat, id) end
      if h.got then h.got(cat, id, cnt) end
      o = o + n
    elseif op == 0x40 or op == 0x20 then -- ScriptByteCountdown / Opcode20ArmCountdown: wait n frames
      o = o + n; coroutine.yield("wait", r:u8(o - 1))
    elseif op == 0x83 then -- AddScriptDeltasUntilZero: (count, dx, dy) camera pixel deltas
      local q = o + 1
      while r:u8(q) ~= 0 do
        local c, dx, dy = r:u8(q), r:u8(q + 1), r:u8(q + 2)
        if dx >= 128 then dx = dx - 256 end; if dy >= 128 then dy = dy - 256 end
        h.pan(c, dx, dy); coroutine.yield("wait", c); q = q + 3
      end
      o = q + 1
    elseif op == 0x41 then -- Bank1NibblePhaseCountdown: count = bank-1 byte [ptr + (rDIV mix & $0F)],
      -- then wait until the 4-frame phase has passed that many times (a random idle pause)
      local base = r:u16(o + 1); o = o + n
      local cnt = r:u8(off(base + love.math.random(0, 15), 1))
      if not self.init then coroutine.yield("wait", 4 * (cnt + 1)) end
    elseif op == 0x45 then jump(r:u8(o + 1), r:u16(o + 2)) -- EnterScriptFromLookup
    elseif op == 0xAA or op == 0xAB then
      -- StoreScriptByteInWramBank ($2801) / StoreScriptWordInWramBank: addr, WRAM bank,
      -- value. A battle script uses it on battle WRAM (bank 7 $D000-$D3FF), e.g. Korg's
      -- duel sets his starting energy; those writes go to the battle engine in order
      local args = {}; for i = 1, n - 1 do args[i] = r:u8(o + i) end
      if h.battleOp and not self.init then h.battleOp(op, args) end
      o = o + n
    elseif op == 0xAC then self:wr8(r:u16(o + 1), r:u8(o + 3)); o = o + n -- StoreScriptByteInSram
    elseif op == 0x43 then -- SRAMLookupInstallScript: nonzero lookup enters (bank, ptr)
      local v, q = self:expr(o + 1)
      if v ~= 0 then
        local o0 = o; jump(r:u8(q), r:u16(q + 1))
        -- a target equal to this opcode is a poll loop: re-test next frame
        if o == o0 then if self.init then return end; coroutine.yield("wait", 1); steps = 0 end
      else o = o + n end
    elseif op == 0x4B or op == 0x49 then -- SelectScriptByExactWord / ByLookupRange
      local v, q = self:expr(o + 1); local hit
      while r:u8(q) ~= 0xFF do
        if op == 0x4B then
          if r:u16(q + 1) == v then hit = { r:u8(q), r:u16(q + 3) }; break end; q = q + 5
        else
          if v >= r:u8(q + 1) and v <= r:u8(q + 2) then hit = { r:u8(q), r:u16(q + 5) }; break end; q = q + 7
        end
      end
      if hit then jump(hit[1], hit[2]) else o = o + n end
    elseif op == 0xA6 or op == 0xA7 then
      local a = r:u16(o + 1); local v = self:expr(o + 3)
      self:wr8(a, v); if op == 0xA7 then self:wr8(a + 1, bit.rshift(v, 8)) end; o = o + n
    elseif op == 0xA5 then
      local a, m = r:u16(o + 1), r:u8(o + 3); local v = self:expr(o + 4)
      if v ~= 0 then self:wr8(a, bor(self:rd8(a), m)) end; o = o + n
    elseif op == 0x9F then -- StageStripTextFromScript: text up to $FD (<END>)
      if self.init then return end -- LCD off: no text during map setup
      -- <LINE> $FF -> "\n", <WAIT> $FE -> "\f", <SWAP> $FC -> name buffer
      local t, q = {}, o + 1
      while r:u8(q) ~= 0xFD do
        local c = r:u8(q)
        if c == 0xFF then t[#t + 1] = "\n"
        elseif c == 0xFE then t[#t + 1] = "\f"
        elseif c == 0xFC then t[#t + 1] = self.nameBuf or ""
        elseif c < 0xF7 then t[#t + 1] = string.char(c) end
        q = q + 1
      end
      o = o + n
      h.text(table.concat(t)); coroutine.yield("text")
    elseif Ext[op] then
      -- handlers from src/mn/ops/*.lua: (vm, o, n, cur) -> next flat offset, or nil to end the record
      local nx = Ext[op](self, o, n, cur)
      if not nx then return end
      o = nx
    elseif Op.END[op] then
      if op == 0x9C then -- choice: (count, then count x (bank, ptr)); the window closes on pick
        local c = r:u8(o + 1); local k
        if self.init then return end
        -- MN_PICK="2B:43F0,...": a choice whose record targets one of these takes it
        local want = os.getenv("MN_PICK")
        if want then
          for i = 0, c - 1 do
            if want:find(("%02X:%04X"):format(r:u8(o + 2 + 3 * i), r:u16(o + 3 + 3 * i)), 1, true) then k = i end
          end
        end
        -- autopilot: first option; a 3+ option shop menu (Forge/Equip/Power/Done) takes the exit
        if not k and self.autoPick then k = c >= 3 and c - 1 or 0 end
        if not k and h.choose then
          local st = h.choose(c) -- hand cursor on the strip's options; the host sets .picked
          if st then
            while not st.picked do coroutine.yield("wait", 1) end
            k = st.picked - 1
          end
        end
        k = k or 0
        if h.boxClose then h.boxClose() end
        if c > 0 then jump(r:u8(o + 2 + 3 * k), r:u16(o + 3 + 3 * k)) else return end
      elseif op == 0x47 then
        -- $47 PickScriptRecordByDividerMod: hardware divider mod count (random)
        local c = r:u8(o + 1); local k = (c > 0 and self.curSlot and not self.init) and love.math.random(0, c - 1) or 0
        if c > 0 then jump(r:u8(o + 2 + 3 * k), r:u16(o + 3 + 3 * k)) else return end
      elseif op == 0x8E then jump(r:u8(o + 1), r:u16(o + 2))
      else self:note(op); return end
    else
      self:note(op); o = o + n
    end
  end
end

-- bank-7 records, $22 bytes each: items at $5E0B, spells at $7001
function VM:recordOff(cat, id)
  return 7 * 0x4000 + (cat == 3 and 0x7001 or 0x5E0B) + id * 0x22 - 0x4000
end

-- 13-byte record name (a leading icon glyph is part of it), trailing spaces trimmed
function VM:recordName(cat, id)
  if cat ~= 0 and cat ~= 3 then return "item" end
  local o, t = self:recordOff(cat, id), {}
  for i = 0, 12 do t[#t + 1] = string.char(self.rom:u8(o + i)) end
  return (table.concat(t):gsub(" +$", ""))
end

return VM
