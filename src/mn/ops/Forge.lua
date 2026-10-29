-- Ring forge commit for opcode $8E, and the ring gift of opcode $2C, lifted
-- from bank 4.
--
-- TryAffordOtherChoice ($5A5B) reads the picked 8-byte list entry:
--   +0 ring id, +1 stock index A, +2 count A, +3 stock index B, +4 count B
--   (0 = no second stock), +5/+6 animite cost (little-endian), +7 unused here.
-- The cost is subtracted from the word at $A3A5 into $CD4A. Count A is
-- subtracted from $A4A6[index A] into $CD4D, with the index at $CD4C. When
-- count B is not 0 the same is done for B into $CD4F / $CD4E; otherwise
-- $CD4E stays $FF. Any borrow (the saved value is smaller) leaves through
-- ShowUnaffordableChoice ($5DF5): a notice, then back to the forge window.
-- An equal value is affordable.
--
-- CommitOtherChoiceFive ($5CB3) sets $CD49 = 1 and $CD51 = id, writes the
-- three differences back, and falls into AddSRAMEntryForOperand ($5D19):
--   $A122 += 1, $C726 = id.
--   CopyEntryRecordPrefix (4:$40F0) copies the first $1E bytes of the
--   $2D-byte record at 4:$415B + id * $2D into $CD91.
--   The SRAM entries from $A025 (stride $25) are scanned for a $FF lead
--   byte. That entry becomes: +0 id, +1 buf[0], +2 1, +3..+7 0, +8 buf[1],
--   +9..+18 buf[4..13], +19 0, +20 buf[14], +21 buf[15], +22..+33
--   buf[18..29], +34..+36 0. $CD52/$CD53 hold its address, $CD56 its index.
--   SpendNewEntryMeasures (2:$5B35, mn.ui.list.spend) runs on it with the
--   pass count [$CD50] - 1. $2C sets $CD50 from its second operand; the forge
--   path does not write it, so the last value stands.
--   The first $FF in $A118..$A121 is replaced by index + 1.
-- The entry table is in SRAM bank wSRAMBank + 1: vm.sramBanks[bank + 1] when
-- the VM carries that image ($91 fills it), else the flat vm memory. For the
-- SpendNewEntryMeasures pass the entry is mapped in at its address and the
-- bytes there are put back afterwards, as the bank switch would leave them.
-- The scan stops at $BFFF instead of running on, and writes nothing if no
-- $FF lead is found.
-- The ring name copied to the window tail is display only and not modelled.

local MnRom = require("mn.MnRom")
local Spend = require("mn.ui.list.spend")

local M = {}

M.RECORD_TABLE = 0x415B
M.RECORD_STRIDE = 0x2D
M.PREFIX = 0x1E
M.ENTRY_BASE = 0xA025
M.ENTRY_STRIDE = 0x25

local function rd16(vm, a) return vm:rd8(a) + vm:rd8(a + 1) * 256 end

-- SRAM bank wSRAMBank + 1, as a get/set pair.
local function nextBank(vm)
  local nb = (vm.sramBank or 0) + 1
  if not (vm.sramBanks and vm.sramBanks[nb]) then
    return function(a) return vm:rd8(a) end, function(a, v) vm:wr8(a, v) end, nil
  end
  local function get(a) return vm.sramBanks[nb]:byte(a - 0xA000 + 1) or 0 end
  local function set(a, v)
    local img, i = vm.sramBanks[nb], a - 0xA000 + 1
    if #img < i then img = img .. string.rep("\0", i - #img) end
    vm.sramBanks[nb] = img:sub(1, i - 1) .. string.char(v % 256) .. img:sub(i + 1)
  end
  return get, set, nb
end

-- The picked list entry (k is 0-based) as a table.
function M.entry(rom, list, k)
  local o = list + 1 + 8 * k
  return {
    id = rom:u8(o), ia = rom:u8(o + 1), na = rom:u8(o + 2),
    ib = rom:u8(o + 3), nb = rom:u8(o + 4), cost = rom:u16(o + 5),
  }
end

-- TryAffordOtherChoice. Returns true and stages $CD4A..$CD4F, or false.
function M.tryAfford(vm, e)
  vm:wr8(0xCD4E, 0xFF); vm:wr8(0xCD4F, 0xFF)
  local diff = rd16(vm, 0xA3A5) - e.cost
  if diff < 0 then return false end
  vm:wr8(0xCD4A, diff % 256); vm:wr8(0xCD4B, math.floor(diff / 256))
  local a = vm:rd8(0xA4A6 + e.ia) - e.na
  if a < 0 then return false end
  vm:wr8(0xCD4C, e.ia); vm:wr8(0xCD4D, a)
  if e.nb ~= 0 then
    local b = vm:rd8(0xA4A6 + e.ib) - e.nb
    if b < 0 then return false end
    vm:wr8(0xCD4E, e.ib); vm:wr8(0xCD4F, b)
  end
  return true
end

-- AddSRAMEntryForOperand for the id at $CD51.
function M.addEntry(vm, rom)
  local id = vm:rd8(0xCD51)
  vm:wr8(0xA122, (vm:rd8(0xA122) + 1) % 256)
  vm:wr8(0xC726, id)
  local src = MnRom.off(M.RECORD_TABLE + id * M.RECORD_STRIDE, 4)
  local buf = {}
  for i = 0, M.PREFIX - 1 do
    buf[i] = rom:u8(src + i)
    vm:wr8(0xCD91 + i, buf[i])
  end
  local get, set, banked = nextBank(vm)
  local addr, d = M.ENTRY_BASE, 0
  while addr + M.ENTRY_STRIDE - 1 <= 0xBFFF and get(addr) ~= 0xFF do
    addr = addr + M.ENTRY_STRIDE; d = d + 1
  end
  if addr + M.ENTRY_STRIDE - 1 > 0xBFFF then return nil end
  vm:wr8(0xCD56, d % 256)
  vm:wr8(0xCD52, addr % 256); vm:wr8(0xCD53, math.floor(addr / 256))
  local body = { id, buf[0], 1, 0, 0, 0, 0, 0, buf[1] }
  for i = 4, 13 do body[#body + 1] = buf[i] end
  body[#body + 1] = 0
  body[#body + 1] = buf[14]; body[#body + 1] = buf[15]
  for i = 18, 29 do body[#body + 1] = buf[i] end
  body[#body + 1] = 0; body[#body + 1] = 0; body[#body + 1] = 0
  assert(#body == M.ENTRY_STRIDE)
  for i, v in ipairs(body) do set(addr + i - 1, v) end
  if banked then
    local keep = {}
    for i = 0, M.ENTRY_STRIDE - 1 do keep[i] = vm:rd8(addr + i); vm:wr8(addr + i, get(addr + i)) end
    Spend.apply(vm, rom)
    for i = 0, M.ENTRY_STRIDE - 1 do set(addr + i, vm:rd8(addr + i)); vm:wr8(addr + i, keep[i]) end
  else
    Spend.apply(vm, rom)
  end
  for a = 0xA118, 0xA121 do
    if vm:rd8(a) == 0xFF then vm:wr8(a, (d + 1) % 256); break end
  end
  return addr, d
end

-- CommitOtherChoiceFive then AddSRAMEntryForOperand.
function M.commit(vm, rom, e)
  vm:wr8(0xCD49, 1)
  vm:wr8(0xCD51, e.id)
  vm:wr8(0xA3A5, vm:rd8(0xCD4A)); vm:wr8(0xA3A6, vm:rd8(0xCD4B))
  vm:wr8(0xA4A6 + vm:rd8(0xCD4C), vm:rd8(0xCD4D))
  if vm:rd8(0xCD4E) ~= 0xFF then vm:wr8(0xA4A6 + vm:rd8(0xCD4E), vm:rd8(0xCD4F)) end
  return M.addEntry(vm, rom)
end

return M
