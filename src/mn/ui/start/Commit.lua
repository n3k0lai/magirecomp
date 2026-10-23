-- Confirming Save (slot $24, command $4D) plants wThirdScriptRecord and leaves
-- the menu (slot24_script_record.asm, then LoadBothVRAMBanks). The bytes are
-- the same save opcode $92 writes: player cell, stamp, mirror, file
-- (src/mn/ops/Save.lua, src/mn/SaveFile.lua). The copy-operand of $92 is zero
-- here, so the other bank's map word is left alone.
local Save = require("mn.ops.Save")
local SaveFile = require("mn.SaveFile")

local M = {}
local ZERO = string.rep("\0", SaveFile.BANK_SIZE)

local function banksOf(vm)
  if not vm.sramBanks then
    vm.sramBanks = { [0] = ZERO, [1] = ZERO, [2] = ZERO, [3] = ZERO }
  end
  if vm.sramBank ~= 0 and vm.sramBank ~= 2 then vm.sramBank = 2 end
  return vm.sramBanks
end

local function filesystem(vm)
  if vm.saveFs then return vm.saveFs end
  if love and love.filesystem and love.filesystem.write then return love.filesystem end
end

-- WriteSlot24ScriptRecord: $CCA5 picks which five-byte record lands at $C714.
local function plantScript(vm)
  local bank, ptr = 0x12, 0x79D3
  if vm:rd8(0xCCA5) ~= 0 then bank, ptr = 0x22, 0x4127 end
  vm:wr8(0xC714, bank)
  vm:wr8(0xC715, ptr % 256)
  vm:wr8(0xC716, math.floor(ptr / 256))
  vm:wr8(0xC717, 0x66) -- INITIAL_SCRIPT_HANDLER $0A66
  vm:wr8(0xC718, 0x0A)
  return bank, ptr
end

function M.run(ctx)
  local vm = ctx.vm
  local banks = banksOf(vm)
  vm:wr8(0xA017, 1)
  local x = ctx.ow and ctx.ow.x or vm:rd8(0xC18E)
  local y = ctx.ow and ctx.ow.y or vm:rd8(0xC18F)
  vm:wr8(0xA015, x or 0)
  vm:wr8(0xA016, y or 0)
  local bank, ptr = plantScript(vm)
  local stamp = Save.romStamp(vm)
  local t = {}
  for i = 0, SaveFile.BANK_SIZE - 1 do t[i + 1] = string.char(vm:rd8(0xA000 + i)) end
  local live = table.concat(t)
  if not SaveFile.stampOk(live, stamp) then live = SaveFile.writeStamp(live, stamp) end
  local out, nw = SaveFile.commit(banks, live, vm.sramBank)
  local wrote = false
  if out then
    Save.install(vm, out, nw)
    local fs = filesystem(vm)
    if fs then wrote = SaveFile.writeFile(fs, SaveFile.PATH, out) and true or false end
  end
  -- LoadBothVRAMBanks tail: sound bytes back to the field values.
  vm:wr8(0xC92C, 0x0F)
  vm:wr8(0xC928, 0)
  vm:wr8(0xC929, 0)
  vm:wr8(0xC92A, 4)
  return { action = "save", bank = bank, ptr = ptr, wrote = wrote }
end

return M
