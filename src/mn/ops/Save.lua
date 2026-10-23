-- SRAM save opcodes. See src/mn/OpExt.lua for the handler contract.
-- The cartridge image lives in src/mn/SaveFile.lua. vm.mem[$A000-$BFFF] is the
-- active SRAM bank (vm.sramBank, 0 or 2). The other three banks sit in
-- vm.sramBanks until a save mirrors them.
local bit = require("bit")
local SaveFile = require("mn.SaveFile")

local M = { handlers = {} }

local ZERO = string.rep("\0", SaveFile.BANK_SIZE)

local function banksOf(vm)
  if not vm.sramBanks then
    vm.sramBanks = { [0] = ZERO, [1] = ZERO, [2] = ZERO, [3] = ZERO }
  end
  if vm.sramBank ~= 0 and vm.sramBank ~= 2 then vm.sramBank = 2 end
  return vm.sramBanks
end

function M.install(vm, banks, w)
  vm.sramBanks = {
    [0] = banks[0], [1] = banks[1], [2] = banks[2], [3] = banks[3],
  }
  vm.sramBank = w
  local live = banks[w]
  for i = 0, SaveFile.BANK_SIZE - 1 do
    vm:wr8(SaveFile.BASE + i, live:byte(i + 1))
  end
end

-- Sixteen ROM bytes at bank 7 $4000. check_save_signature.asm compares SRAM
-- against that window while bank 7 is mapped (call_bank7_then_load_sram_script.asm).
function M.romStamp(vm)
  local base = 7 * 0x4000
  local t = {}
  for i = 0, SaveFile.STAMP_LEN - 1 do
    t[i + 1] = string.char(vm.rom:u8(base + i) or 0)
  end
  return table.concat(t)
end

-- Saved script triple ($A012 bank, $A013 pointer) and the cell pair at $A015.
function M.resume(vm)
  return vm:rd8(0xA012), vm:rd16(0xA013), vm:rd8(0xA015), vm:rd8(0xA016)
end

local function capture(vm)
  local w = vm.sramBank or 2
  local t = {}
  for i = 0, SaveFile.BANK_SIZE - 1 do
    t[i + 1] = string.char(vm:rd8(SaveFile.BASE + i))
  end
  return table.concat(t), w
end

local function filesystem(vm)
  if vm.saveFs then return vm.saveFs end
  if love and love.filesystem and love.filesystem.write then return love.filesystem end
end

-- format_start_digits.asm: low 10 bits of DE, as three decimal digits.
local function formatStartDigits(d, e)
  d = bit.band(d, 3)
  local h, tens, ones = 0, 0, 0
  if d == 3 then h, tens, ones = 7, 6, 8
  elseif d == 2 then h, tens, ones = 5, 1, 2
  elseif d == 1 then h, tens, ones = 2, 5, 6 end
  local b, c = h, e
  while true do
    local a = c - 0x64
    if a < 0 then break end
    b = b + 1
    c = a
  end
  h = b
  b = tens
  local a = c
  while true do
    local s = a - 0x0A
    if s < 0 then break end
    b = b + 1
    a = s
  end
  tens = b
  ones = ones + a
  if ones >= 0x0A then ones = ones - 0x0A; tens = tens + 1 end
  if tens >= 0x0A then tens = tens - 0x0A; h = h + 1 end
  return h, tens, ones
end

-- format_hl_word_three_digits.asm / format_hl_byte_three_digits.asm: digits at
-- $C949 and $FC after them. The window that would draw them is not drawn yet.
local function storeDigits(vm, h, tens, ones)
  vm:wr8(0xC92F, h)
  vm:wr8(0xC92E, tens)
  vm:wr8(0xC92D, ones)
  vm:wr8(0xC949, bit.band(h + 0x30, 0xFF))
  vm:wr8(0xC94A, bit.band(tens + 0x30, 0xFF))
  vm:wr8(0xC94B, bit.band(ones + 0x30, 0xFF))
  vm:wr8(0xC94C, 0xFC)
  vm:wr8(0xC93D, 0x49)
  vm:wr8(0xC93E, 0xC9)
end

local function read8(vm, cur, a)
  if a >= 0xA000 then return vm:rd8(a) end
  if a >= 0x4000 then
    return vm.rom:u8((cur.bank or 0) * 0x4000 + (a - 0x4000))
  end
  return vm.rom:u8(a)
end

-- $AD store_script_word_in_sram.asm: addr word, then the word stored there.
M.handlers[0xAD] = function(vm, o, n)
  local r = vm.rom
  local addr = r:u8(o + 1) + bit.lshift(r:u8(o + 2), 8)
  banksOf(vm)
  vm:wr8(addr, r:u8(o + 3))
  vm:wr8(addr + 1, r:u8(o + 4))
  return o + n
end

-- $92 stage_saved_script_pair.asm, then bank 7 $40D4 (store_sram_bank_flag.asm).
-- One operand: zero skips the map-word copy. The mirror is the save.
M.handlers[0x92] = function(vm, o, n)
  local copy = vm.rom:u8(o + 1)
  local banks = banksOf(vm)
  vm:wr8(0xA017, 1)
  local x, y = vm:rd8(0xC18E), vm:rd8(0xC18F)
  if vm.host and vm.host.playerCell then x, y = vm.host.playerCell() end
  vm:wr8(0xA015, x or 0)
  vm:wr8(0xA016, y or 0)
  if copy ~= 0 then
    -- sMapWord2 ($A007) onto sMapWord1 ($A005) in the next SRAM bank.
    local nb = vm.sramBank + 1
    local b = banks[nb]
    local lo, hi = SaveFile.peek(b, 0xA007), SaveFile.peek(b, 0xA008)
    b = SaveFile.poke(SaveFile.poke(b, 0xA005, lo), 0xA006, hi)
    banks[nb] = b
  end
  local stamp = M.romStamp(vm)
  local live, w = capture(vm)
  if not SaveFile.stampOk(live, stamp) then live = SaveFile.writeStamp(live, stamp) end
  local out, nw = SaveFile.commit(banks, live, w)
  if out then
    M.install(vm, out, nw)
    local fs = filesystem(vm)
    if fs then SaveFile.writeFile(fs, SaveFile.PATH, out) end
  end
  return o + n
end

-- $98 format_pointed_sram_byte.asm: the byte at the script's address, three digits.
-- visual: the three digits are text for a window, not drawn yet.
M.handlers[0x98] = function(vm, o, n, cur)
  local addr = vm.rom:u8(o + 1) + bit.lshift(vm.rom:u8(o + 2), 8)
  local h, tens, ones = formatStartDigits(0, read8(vm, cur, addr))
  storeDigits(vm, h, tens, ones)
  return o + n
end

-- $9E opcode_9e.asm: the little-endian word at the script's address, three digits.
-- visual: the three digits are text for a window, not drawn yet.
M.handlers[0x9E] = function(vm, o, n, cur)
  local addr = vm.rom:u8(o + 1) + bit.lshift(vm.rom:u8(o + 2), 8)
  local e, d = read8(vm, cur, addr), read8(vm, cur, addr + 1)
  local h, tens, ones = formatStartDigits(d, e)
  storeDigits(vm, h, tens, ones)
  return o + n
end

return M
