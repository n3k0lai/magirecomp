-- Opcode $7E (StageEightScriptBytes) copies a map rectangle during map setup
-- and, one cell a frame, while a script is running. Synthetic bytes only.
--   luajit tests/engine/mn_core_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- 8-wide plane. Source 2x2 at $D000, dest at $D020 (row 4). A zero collision
-- byte must still copy. $52 after the record is the "script continued" mark.
local SRC = { { 0x01, 0xA1 }, { 0x00, 0xA2 }, { 0x03, 0x00 }, { 0x04, 0xA4 } }
local SCRIPT = { 0x7E, 0x00, 0xD0, 2, 2, 0x20, 0xD0, 0x04, 0x05, 0x52, 0x05 }

local function world()
  local ow = { patches = {}, def = { w = 8, h = 8, cells = {}, block = {} } }
  for i = 1, 64 do ow.def.cells[i] = 0x10; ow.def.block[i] = 0x20 end
  local function put(addr, col, mt)
    local i = addr - 0xD000
    ow.def.block[i + 1] = col
    ow.def.cells[i + 1] = mt
  end
  put(0xD000, SRC[1][1], SRC[1][2])
  put(0xD001, SRC[2][1], SRC[2][2])
  put(0xD008, SRC[3][1], SRC[3][2])
  put(0xD009, SRC[4][1], SRC[4][2])
  local h = {
    mapWidth = function() return ow.def.w end,
    copyCell = function(si, di)
      local d = ow.def
      local mt = d.cells[si + 1]
      if mt then
        d.cells[di + 1] = mt
        ow.patches[#ow.patches + 1] = { x = di % d.w, y = math.floor(di / d.w), mt = mt }
      end
      if d.block[si + 1] then d.block[di + 1] = d.block[si + 1] end
    end,
  }
  return ow, h, put
end

local function cell(ow, addr)
  local i = addr - 0xD000
  return ow.def.block[i + 1], ow.def.cells[i + 1]
end

local function rectOk(ow, what)
  local addrs = { 0xD020, 0xD021, 0xD028, 0xD029 }
  for i, addr in ipairs(addrs) do
    local col, mt = cell(ow, addr)
    ok(col == SRC[i][1] and mt == SRC[i][2], what .. (" cell %d"):format(i))
  end
  local col, mt = cell(ow, 0xD022)
  ok(col == 0x20 and mt == 0x10, what .. " leaves the cell past the row")
  col, mt = cell(ow, 0xD018)
  ok(col == 0x20 and mt == 0x10, what .. " leaves the row above")
end

-- Map setup (runInit, LCD off): the whole rect is written before the next opcode.
do
  local ow, h = world()
  local vm = VM.new(image(SCRIPT), h)
  vm:runInit(0x12, 0x4000)
  rectOk(ow, "init")
  ok(vm:rd8(0xC6F7) == 4, "init continues into the opcode after $7E")
  ok(#ow.patches == 4, "init queues one draw patch per copied cell")
end

-- Running script: one cell per resume, then the following opcode.
do
  local ow, h = world()
  local vm = VM.new(image(SCRIPT), h)
  vm:start(0x12, 0x4000)
  local c1, m1 = cell(ow, 0xD020)
  ok(c1 == 0x01 and m1 == 0xA1, "runtime copies the first cell and waits")
  local c2, m2 = cell(ow, 0xD021)
  ok(c2 == 0x20 and m2 == 0x10, "runtime has not copied the second cell yet")
  ok(vm:rd8(0xC6F7) == 0, "runtime has not reached the opcode after $7E")
  ok(vm:rd8(0xFFA7) == 2 and vm:rd8(0xC704) == 2, "runtime stages width and height")
  ok(vm:rd16(0xC6FE) == 0xD000 and vm:rd16(0xC700) == 0xD020, "runtime stages the pointers")
  ok(vm:rd8(0xC702) == 0x04 and vm:rd8(0xC703) == 0x05, "runtime stages the row and column")
  ok(vm.co ~= nil, "runtime is not finished after one cell")
  for _ = 1, 3 do vm.wait = nil; vm:resume() end
  local _, m4 = cell(ow, 0xD029)
  ok(m4 == 0xA4, "runtime finishes the window after one step per cell")
  ok(vm:rd8(0xC6F7) == 0 and vm.co ~= nil, "the last cell still yields before the next opcode")
  vm.wait = nil; vm:resume()
  rectOk(ow, "runtime")
  ok(vm:rd8(0xC6F7) == 4, "runtime continues into the opcode after $7E")
  ok(vm.co == nil, "runtime record ends after the copy")
end

print(("mn_core: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
