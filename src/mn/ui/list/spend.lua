-- SpendNewEntryMeasures (bank 2 $5B35), called from CommitBoughtSramRecord
-- ($731C) after $CD52 points at the SRAM entry and $CD50 is 2.
-- LoadD110Record ($5C1E) copies the $25-byte body to $D112 and mirrors
-- the max-energy word at $D119 onto $D117. $D389 is set to 1 (bit 0 set,
-- bit 1 clear), so the following SpendMeasureHundred passes leave the
-- measure word at record+5 alone. WriteD110RecordBody ($5C45) stores
-- that body back. The caller's WRAM bank at $C937 is restored.

local Engine = require("mn.battle.Engine")
local MnRom = require("mn.MnRom")
local Rng = require("mn.battle.Rng")

local M = {}

local function tables(rom)
  local g, b2 = {}, {}
  local go = MnRom.off(0x5B0F, 2)
  for i = 0, 0x25 do g[i] = rom and rom:u8(go + i) or 0 end
  local bo = MnRom.off(0x4000, 2)
  for i = 0, 0x13F do b2[i] = rom and rom:u8(bo + i) or 0 end
  return { growth = g, b2 = b2 }
end

local function loadRecord(vm, addr)
  vm:wr8(0xD110, vm:rd8(0xD017) ~= 0 and 1 or 0)
  vm:wr8(0xD111, 0)
  for i = 0, 0x24 do vm:wr8(0xD112 + i, vm:rd8((addr + i) % 65536)) end
  vm:wr8(0xD117, vm:rd8(0xD119))
  vm:wr8(0xD118, vm:rd8(0xD11A))
end

local function writeBody(vm, addr)
  for i = 0, 0x24 do vm:wr8((addr + i) % 65536, vm:rd8(0xD112 + i)) end
end

function M.apply(vm, rom)
  local addr = vm:rd8(0xCD52) + vm:rd8(0xCD53) * 256
  local saved = vm:rd8(0xC937)
  vm:wr8(0xC937, 7)
  loadRecord(vm, addr)
  vm:wr8(0xD389, 1)
  local n = (vm:rd8(0xCD50) - 1) % 256
  if n ~= 0 then
    local m = {}
    for a = 0xD000, 0xD3FF do m[a] = vm:rd8(a) end
    -- Bit 0 of $D389 skips the -100 on the measure word. The battle port
    -- folds that skip into its `creating` flag; the rank and stat writes
    -- still run, and bit 1 stays clear so the level-up script does not.
    local s = {
      m = m, data = tables(rom), rng = Rng.seeded((vm:rd8(0xFF04) % 255) + 1),
      events = {}, ffa9 = vm:rd8(0xFFA9), unimplemented = {},
    }
    while n ~= 0 do
      Engine.spendMeasureHundred(s, 0xD110, true)
      n = n - 1
    end
    for a = 0xD000, 0xD3FF do vm:wr8(a, m[a] or 0) end
    vm:wr8(0xFFA9, s.ffa9)
  end
  writeBody(vm, addr)
  vm:wr8(0xC937, saved)
end

return M
