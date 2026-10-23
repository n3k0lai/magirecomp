-- List windows for opcodes $8C, $8F and $90.
-- $8C StageCopiedBlockArmSlot ($5400) / DispatchCopiedBlockChoice ($52BC):
--   a copied block of id + 13 glyphs. A pick commits $CCFC and stays open.
-- $8F StageSramListArmSlot ($7025) / SpendSramListChoice ($729A):
--   SRAM records at $A025, prices from bank 7 $5AD7, stock at $A4A6.
-- $90 SetupPrefixedBlockChoice ($66BE) / DispatchPrefixedBlockChoice ($65D9):
--   buy from the $D000 block, or sell from the counts at $A3A7.
-- The ring-forge questions live in bank 4 (CopiedBlockWindowChoice, $582C),
-- not in these three opcodes. A short cost or a full stack only sets $C921.

local Font = require("mn.Font")
local MnRom = require("mn.MnRom")
local Slots = require("mn.ui.list.slots")
local Spend = require("mn.ui.list.spend")
local Win = require("mn.ui.list.window")

local M = {}
M.__index = M

local WRAM = 0x6D000 -- bank 6 $D000, the copied block
local NAME_PTR = 0x5AA6
local PRICE_PTR = 0x5AD7
local MENU_PTR = 0x52E5

local function rd16(vm, a)
  return vm:rd8(a) + vm:rd8(a + 1) * 256
end

local function wr16(vm, a, w)
  w = w % 65536
  vm:wr8(a, w % 256)
  vm:wr8(a + 1, math.floor(w / 256))
end

local function covers(have, cost)
  return have >= cost
end

local function subWord(vm, addr, cost)
  local lo = vm:rd8(addr) - (cost % 256)
  local hi = vm:rd8(addr + 1)
  if lo < 0 then lo = lo + 256; hi = hi - 1 end
  hi = hi - math.floor(cost / 256)
  vm:wr8(addr, lo % 256)
  vm:wr8(addr + 1, hi % 256)
end

-- format_start_digits.asm: low 10 bits, seeds 0 / 256 / 512 / 768.
local function digits(word)
  local d = math.floor(word / 256) % 4
  local h, t, o = 0, 0, 0
  if d == 1 then h, t, o = 2, 5, 6
  elseif d == 2 then h, t, o = 5, 1, 2
  elseif d == 3 then h, t, o = 7, 6, 8
  end
  local e = word % 256
  while e >= 100 do h = h + 1; e = e - 100 end
  while e >= 10 do t = t + 1; e = e - 10 end
  o = o + e
  if o >= 10 then o = o - 10; t = t + 1 end
  if t >= 10 then t = t - 10; h = h + 1 end
  return h, t, o
end

local function places(base, word, n)
  local h, t, o = digits(word)
  if n == 2 then return string.char(base + t, base + o) end
  return string.char(base + h, base + t, base + o)
end

local function normMode(mode)
  mode = tostring(mode or os.getenv("MN_UI_MODE") or "8c"):lower()
  if mode ~= "8c" and mode ~= "8f" and mode ~= "90" then mode = "8c" end
  return mode
end

-- fill_choice_table_from_records.asm. Same walk as Travel.fillChoice.
local function fillCopied(vm)
  local index = vm:rd8(0xCCD5)
  local step, fill = index, 0
  local limit = (index + 8) % 256
  local len = vm:rd8(0xCCCC)
  local padding = false
  while true do
    local v = padding and 0xFF or vm:rd8(WRAM + 1 + step * 0x0E)
    vm:wr8(0xCCCD + fill, v)
    local nxt = (step + 1) % 256
    if nxt == limit then vm:wr8(0xCCC6, step); vm:wr8(0xCCC9, fill); return end
    step, fill = nxt, (fill + 1) % 256
    if not padding and len == step then padding = true end
  end
end

-- copy_choice_record_tiles.asm: $CCD6+slot+3 is 1 when the choice byte is real.
local function stampRows(vm)
  for i = 0, 7 do
    vm:wr8(0xCCD9 + i, vm:rd8(0xCCCD + i) == 0xFF and 0 or 1)
  end
end

-- paint_map_attrs_seed_slot.asm plants the bottom three slots. Callers
-- rewrite $CD81 afterwards; the scroll marks stay whatever the opener set.
local function seedMarks(vm)
  vm:wr8(0xCCD6, 1)
  vm:wr8(0xCCD7, 1)
  vm:wr8(0xCCD8, 1)
end

-- fill_sram_list_ids.asm: eight SRAM indexes at $A025, stride $25. $FF skipped.
local function fillSramIds(vm)
  local start = vm:rd8(0xCCD5)
  vm:wr8(0xCCC6, start)
  vm:wr8(0xCCC7, 0)
  while true do
    local step = vm:rd8(0xCCC6)
    if step == (start + 8) % 256 then
      local c = vm:rd8(0xCCC7)
      while c < 8 do vm:wr8(0xCCCD + c, 0xFF); c = c + 1 end
      return
    end
    vm:wr8(0xCCC6, (step + 1) % 256)
    local id = vm:rd8(0xA025 + step * 0x25)
    if id ~= 0xFF then
      local n = vm:rd8(0xCCC7)
      vm:wr8(0xCCCD + n, id)
      n = n + 1
      vm:wr8(0xCCC7, n)
      if n == 8 then return end
    end
  end
end

-- paint_sram_list_record_bytes.asm: record byte 2, by SRAM index, into $CD17.
local function paintSramBytes(vm)
  local start = vm:rd8(0xCCD5)
  for step = 0, 7 do
    local b = vm:rd8(0xA025 + (start + step) * 0x25 + 2)
    vm:wr8(0xCD17 + step, b)
    vm:wr8(0xCCEC, b)
  end
  vm:wr8(0xCCC6, 8)
end

-- fill_sram_list_prices.asm: scan $D001 for the id; the price index is $CD17.
local function fillSramPrices(vm, rom)
  local n = vm:rd8(WRAM)
  for row = 0, 7 do
    local id = vm:rd8(0xCCCD + row)
    local found, e = false, 0
    while e < n do
      if vm:rd8(WRAM + 1 + e) == id then found = true; break end
      e = e + 1
    end
    local idx = vm:rd8(0xCD17 + row)
    local b = 0xCCFE + row * 3
    if not found or idx == 0x63 then
      vm:wr8(b, 0xFF); vm:wr8(b + 1, 0xFF); vm:wr8(b + 2, 0xFF)
    else
      local off = MnRom.off(PRICE_PTR + idx * 3, 7)
      vm:wr8(b, rom:u8(off))
      vm:wr8(b + 1, rom:u8(off + 1))
      vm:wr8(b + 2, rom:u8(off + 2))
    end
  end
end

local function stageSram(vm, rom)
  fillSramIds(vm)
  stampRows(vm)
  paintSramBytes(vm)
  fillSramPrices(vm, rom)
end

-- refresh_record_len_from_mode.asm / count_nonzero_choice_bytes.asm.
-- Mode 0 copies [$D000]. Any other mode counts $A3A7 for $EF bytes.
local function refreshLen(vm)
  if vm:rd8(0xCCCB) == 0 then
    vm:wr8(0xCCCC, vm:rd8(WRAM))
    return
  end
  local c, b, i = 0xF0, 0, 0
  while true do
    c = c - 1
    if c == 0 then break end
    if vm:rd8(0xA3A7 + i) ~= 0 then b = b + 1 end
    i = i + 1
  end
  vm:wr8(0xCCCC, b)
end

-- fill_choice_bytes_forward.asm. Stops when the next step equals $CCC8.
local function fillBuyForward(vm)
  local step = vm:rd8(0xCCD5)
  local fill = 0
  local len = vm:rd8(0xCCCC)
  local row = vm:rd8(0xCCC8)
  local padding = false
  while true do
    local v = 0xFF
    if not padding then v = vm:rd8(WRAM + 1 + (step % 256) * 3) end
    vm:wr8(0xCCCD + fill, v)
    local nxt = (step + 1) % 256
    if nxt == row then return end
    step, fill = nxt, fill + 1
    if not padding and step == len then padding = true end
  end
end

-- refill_choice_bytes_backward.asm. Slot 7 is the entry index.
local function refillBackward(vm)
  local step = vm:rd8(0xCCD5)
  local fill = 7
  while true do
    vm:wr8(0xCCCD + fill, vm:rd8(WRAM + 1 + (step % 256) * 3))
    if fill == 0 then vm:wr8(0xCCD5, step % 256); return end
    fill = fill - 1
    step = (step - 1) % 256
  end
end

-- collect_choice_indices_forward.asm. Index $FE is not read.
local function collectForward(vm)
  local c = vm:rd8(0xCCD5)
  local addr = 0xA3A7 + c
  local b = 0
  while b < 8 do
    c = (c + 1) % 256
    if c == 0xFF then break end
    local v = vm:rd8(addr)
    addr = addr + 1
    if v ~= 0 then
      vm:wr8(0xCCCD + b, (c - 1) % 256)
      b = b + 1
    end
  end
  while b < 8 do vm:wr8(0xCCCD + b, 0xFF); b = b + 1 end
end

-- collect_choice_indices_backward.asm. Stops at index 0 so a short page
-- cannot walk off the front of $A3A7; leftover slots stay $FF.
local function collectBackward(vm)
  for i = 0, 7 do vm:wr8(0xCCCD + i, 0xFF) end
  local c = (vm:rd8(0xCCD5) - 1) % 256
  local addr = 0xA3A7 + c
  local b, fill = 0, 7
  while b < 8 and addr >= 0xA3A7 do
    c = (c - 1) % 256
    local v = vm:rd8(addr)
    addr = addr - 1
    if v ~= 0 then
      local id = (c + 1) % 256
      vm:wr8(0xCCCD + fill, id)
      vm:wr8(0xCCD5, id)
      fill = fill - 1
      b = b + 1
    end
  end
end

-- ScanArmedSlotMarks ($76E0). E starts at 3 and walks $CCD9-$CCE2.
-- A byte of 1 returns 1. Walking off the end returns 0.
local function scanMarks(vm)
  local e, last = 3, 0x0D
  while e ~= last do
    if vm:rd8(0xCCD6 + e) == 1 then return 1 end
    e = e + 1
  end
  return 0
end

-- sync_row_end_marks_then_scan.asm ($6D1F). An empty mark run sends the cursor home.
-- While the row is below the length, RefreshFrameMarkPair stamps [$CCEB]
-- on the lower pair. Once the row is at least 8 past the start,
-- RefreshFrameMarkWindowPair stamps the upper pair. Clearing a mark
-- does not paint; RepaintPrefixedBlockWindow recopied the tilemap first.
local function syncMarks(self)
  local vm = self.vm
  local row, len = vm:rd8(0xCCC8), vm:rd8(0xCCCC)
  if row < len then
    vm:wr8(0xCCE2, 1)
    Win.markPair(self)
  else
    vm:wr8(0xCCE2, 0)
  end
  local prev = (row - 1) % 256
  if prev < 8 then
    vm:wr8(0xCCE1, 0)
  else
    vm:wr8(0xCCE1, 1)
    Win.markWindow(self)
  end
  if scanMarks(vm) == 0 then
    vm:wr8(0xCD81, 0)
    vm:wr8(0xCCE3, 3)
  end
end

local function repaint(self)
  local vm = self.vm
  Win.reset(self)
  stampRows(vm)
  syncMarks(self)
  Slots.arm(vm)
  vm:wr8(0xCCA7, 0xFF)
  vm:wr8(0xCCC9, 0)
end

local function refreshList(self)
  local vm = self.vm
  refreshLen(vm)
  if vm:rd8(0xCCCB) == 0 then fillBuyForward(vm) else collectForward(vm) end
  repaint(self)
end

-- commit_copied_block_choice.asm ($55E3). The first pick leaves $C91F alone.
local function commitCopied(vm, slot)
  if vm:rd8(0xCCCB) == 0 then vm:wr8(0xC91F, 1) end
  vm:wr8(0xCCCB, 0)
  local id = vm:rd8(0xCCCD + (slot - 3) % 256)
  vm:wr8(0xCCFC, id)
  if id ~= vm:rd8(0xC920) then
    vm:wr8(0xC920, id)
    vm:wr8(0xC91E, 1)
  end
  vm:wr8(0xC92A, 0)
  vm:wr8(0xC92C, 0x0F)
  vm:wr8(0xCCA7, 0xFF)
end

local function deny(vm)
  vm:wr8(0xC921, 2)
  vm:wr8(0xCCA7, 0xFF)
end

-- clamp_group_sram.asm, inlined. The 13-byte tail copied to $C949 is display
-- only. TODO(ClampGroupSRAMByte): that tail is not staged.
local function clampCount(vm, rom, id)
  local cap = rom:u8(vm:recordOff(0, id) - 6)
  local have = vm:rd8(0xA3A7 + id)
  vm:wr8(0xC9FD, 0)
  if have == cap then return false end
  local sum = have + vm:rd8(0xC9FE)
  if sum > 255 or sum > cap then sum = cap end
  vm:wr8(0xA3A7 + id, sum)
  vm:wr8(0xC9FD, 1)
  return true
end

-- spend_prefixed_block_record.asm ($6A4D). Record is ($CCC8-8)+(slot-3).
local function spendPrefixed(vm, rom, slot)
  local rec = (vm:rd8(0xCCC8) - 8 + (slot - 3)) % 256
  local base = WRAM + 1 + rec * 3
  local id = vm:rd8(base)
  local cost = vm:rd8(base + 1) + vm:rd8(base + 2) * 256
  vm:wr8(0xC9FD, id)
  if not covers(rd16(vm, 0xA3A5), cost) then deny(vm); return end
  vm:wr8(0xC9FC, 0)
  vm:wr8(0xC9FE, 1)
  if not clampCount(vm, rom, id) then deny(vm); return end
  subWord(vm, 0xA3A5, cost)
  vm:wr8(0xCCC9, 0xFF)
  vm:wr8(0xCCA7, 0xFF)
end

-- copy_choice_record_word.asm: the word at bank 7 $5E09 + id*$22.
local function sellWord(vm, rom, id)
  local off = vm:recordOff(0, id) - 2
  return rom:u8(off) + rom:u8(off + 1) * 256
end

-- add_prefixed_choice_word.asm ($6930). A zero count clears that slot's mark.
local function sellPrefixed(self, rom, slot)
  local vm = self.vm
  local id = vm:rd8(0xCCCD + (slot - 3) % 256)
  local price = sellWord(vm, rom, id)
  if price == 0 then deny(vm); return end
  local sum = rd16(vm, 0xA3A5) + price
  if sum > 999 then sum = 999 end
  wr16(vm, 0xA3A5, sum)
  local left = (vm:rd8(0xA3A7 + id) - 1) % 256
  vm:wr8(0xA3A7 + id, left)
  if left ~= 0 then
    vm:wr8(0xCCC9, 0xFF)
    vm:wr8(0xCCA7, 0xFF)
    return
  end
  vm:wr8(0xCCD6 + slot, 0)
  vm:wr8(0xCCFB, 1)
  syncMarks(self)
  Slots.arm(vm)
  vm:wr8(0xCCA7, 0xFF)
end

-- commit_bought_sram_record.asm ($731C). $CD50 is 2, so
-- SpendNewEntryMeasures runs one pass, then the price table is filled again.
local function commitSram(vm, rom, slot)
  local idx = (vm:rd8(0xCCD5) + (slot - 3)) % 256
  local addr = 0xA025 + idx * 0x25
  vm:wr8(0xCD52, addr % 256)
  vm:wr8(0xCD53, math.floor(addr / 256))
  vm:wr8(0xCD50, 2)
  local bank = vm:rd8(0xC937)
  Spend.apply(vm, rom)
  vm:wr8(0xC937, bank)
  local step = (slot - 3) % 256
  vm:wr8(0xCCC6, step)
  local v = (vm:rd8(0xCD17 + step) + 1) % 256
  vm:wr8(0xCD17 + step, v)
  vm:wr8(0xCCEC, v)
  fillSramPrices(vm, rom)
  vm:wr8(0xCCA7, 0xFF)
end

-- spend_sram_list_choice.asm ($729A). Cost word, then quantity, at $CCFE.
local function spendSram(vm, rom, slot)
  local i = (slot - 3) % 256
  local rec = 0xCCFE + i * 3
  local cost = vm:rd8(rec) + vm:rd8(rec + 1) * 256
  local qty = vm:rd8(rec + 2)
  if not covers(rd16(vm, 0xA3A5), cost) then deny(vm); return end
  local id = vm:rd8(0xCCCD + i)
  local stock = vm:rd8(0xA4A6 + id)
  if stock < qty then deny(vm); return end
  vm:wr8(0xA4A6 + id, stock - qty)
  subWord(vm, 0xA3A5, cost)
  commitSram(vm, rom, slot)
end

-- step_copied_block_choice_0b.asm / step_copied_block_choice_0c.asm.
-- Scroll up always restores the lower arrow ($7751). At the first page
-- the upper pair is blank ($77C2); any later page stamps [$CCEB] ($7777).
-- Scroll down stamps the upper arrow, then either keeps the lower arrow
-- or blanks it ($779D) and parks the cursor on the up slot.
local function scrollCopied(self, slot, dir)
  local vm = self.vm
  if dir < 0 then
    vm:wr8(0xCCD5, (vm:rd8(0xCCD5) - 8) % 256)
    fillCopied(vm)
    stampRows(vm)
    Win.markPair(self)
    vm:wr8(0xCCE2, 1)
    if vm:rd8(0xCCD5) == 0 then
      vm:wr8(0xCCE1, 0)
      Win.windowPair(self)
    else
      Win.markWindow(self)
    end
    vm:wr8(0xCD81, slot)
  else
    vm:wr8(0xCCD5, (vm:rd8(0xCCD5) + 8) % 256)
    fillCopied(vm)
    stampRows(vm)
    vm:wr8(0xCD81, slot)
    Win.markWindow(self)
    vm:wr8(0xCCE1, 1)
    local more = (vm:rd8(0xCCD5) + 8) % 256
    if more < vm:rd8(0xCCCC) then
      Win.markPair(self)
    else
      vm:wr8(0xCCE2, 0)
      vm:wr8(0xCD81, 0x0B)
      Win.blankMark(self)
    end
  end
  Slots.arm(vm)
  vm:wr8(0xCCA7, 0xFF)
end

-- step_sram_list_choice_0b.asm / step_sram_list_choice_0c.asm. Same arrow
-- pairs as the copied-block steps. The floor test is $CCD5 < 8.
local function scrollSram(self, rom, slot, dir)
  local vm = self.vm
  if dir < 0 then
    vm:wr8(0xCCD5, (vm:rd8(0xCCD5) - 8) % 256)
    stageSram(vm, rom)
    Win.markPair(self)
    vm:wr8(0xCCE2, 1)
    if vm:rd8(0xCCD5) < 8 then
      vm:wr8(0xCCE1, 0)
      Win.windowPair(self)
    else
      Win.markWindow(self)
    end
    vm:wr8(0xCD81, slot)
  else
    vm:wr8(0xCCD5, (vm:rd8(0xCCD5) + 8) % 256)
    stageSram(vm, rom)
    vm:wr8(0xCD81, slot)
    Win.markWindow(self)
    vm:wr8(0xCCE1, 1)
    local more = (vm:rd8(0xCCD5) + 8) % 256
    if more < vm:rd8(0xCCCC) then
      Win.markPair(self)
    else
      vm:wr8(0xCCE2, 0)
      vm:wr8(0xCD81, 0x0B)
      Win.blankMark(self)
    end
  end
  Slots.arm(vm)
  vm:wr8(0xCCA7, 0xFF)
end

-- step_prefixed_block_choice_0b.asm / step_prefixed_block_choice_0c.asm.
local function scrollPrefixed(self, slot, dir)
  local vm = self.vm
  if dir < 0 then
    vm:wr8(0xCCFB, 0)
    refreshLen(vm)
    if vm:rd8(0xCCCB) == 0 then
      vm:wr8(0xCCD5, (vm:rd8(0xCCD5) - 1) % 256)
      refillBackward(vm)
    else
      collectBackward(vm)
    end
    vm:wr8(0xCCC8, (vm:rd8(0xCCC8) - 8) % 256)
    repaint(self)
    return
  end
  if vm:rd8(0xCCFB) == 0 then
    if vm:rd8(0xCCCB) == 0 then
      vm:wr8(0xCCD5, vm:rd8(0xCCC8))
    else
      vm:wr8(0xCCD5, (vm:rd8(0xCCD4) + 1) % 256)
    end
    vm:wr8(0xCCC8, (vm:rd8(0xCCC8) + 8) % 256)
  end
  vm:wr8(0xCCFB, 0)
  vm:wr8(0xCD81, slot)
  refreshList(self)
end

-- step_prefixed_block_choice_00.asm. A matching mode keeps the page.
local function enterMode(self, choice)
  local vm = self.vm
  vm:wr8(0xCD81, 3)
  if vm:rd8(0xCCCB) == choice then
    vm:wr8(0xCCE3, 1)
    vm:wr8(0xCD81, 3)
    syncMarks(self)
    Slots.arm(vm)
    vm:wr8(0xCCA7, 0xFF)
    return
  end
  vm:wr8(0xCCFB, 0)
  vm:wr8(0xCCC6, 0)
  vm:wr8(0xCCC8, 8)
  vm:wr8(0xCCE3, 9)
  vm:wr8(0xCCE1, 0)
  vm:wr8(0xCCE2, 1)
  vm:wr8(0xCCCB, choice)
  vm:wr8(0xCCD5, 0)
  refreshList(self)
end

-- step_prefixed_block_choice_fe.asm ($6CA8). $CCE3 == 3 leaves through
-- ReloadChoiceFrame, which this screen reports as a close. The script
-- reads $CCFC/$CCFD, so those are stored here the way StepFeChoiceByCce3
-- does before the same exit. $CCE3 == 0 calls ScanArmedSlotMarks ($76E0):
-- a copied mark arms slot 3 with $CCE3 = 1, and a miss only rearms.
-- Any other flag forces the menu ($CCE3 = 3, $CD81 = 0) and blanks the
-- three choice cells ($76B1).
local function stepFe(self)
  local vm = self.vm
  local flag = vm:rd8(0xCCE3)
  if flag == 3 then
    vm:wr8(0xCCFC, 0xFF)
    vm:wr8(0xCCFD, 0xFF)
    return "fe"
  end
  if flag == 0 then
    if scanMarks(vm) ~= 0 then
      vm:wr8(0xCD81, 3)
      vm:wr8(0xCCE3, 1)
    end
    Slots.arm(vm)
    vm:wr8(0xCCA7, 0xFF)
    return nil
  end
  vm:wr8(0xCCE3, 3)
  vm:wr8(0xCD81, 0)
  Win.blankChoice(self)
  Slots.arm(vm)
  vm:wr8(0xCCA7, 0xFF)
  return nil
end

local function copiedName(vm, rec)
  local a = WRAM + 1 + rec * 0x0E + 1
  local t = {}
  for i = 0, 12 do t[#t + 1] = string.char(vm:rd8(a + i)) end
  return (table.concat(t):gsub(" +$", ""))
end

local function sramName(rom, id)
  if not rom then return "" end
  local ptr = id == 0xFF and 0x5A9C or (NAME_PTR + id * 10)
  local off = MnRom.off(ptr, 6)
  local t = {}
  for i = 0, 9 do t[#t + 1] = string.char(rom:u8(off + i)) end
  return (table.concat(t):gsub(" +$", ""))
end

local function menuGlyphs(rom)
  if not rom then return "" end
  local off = MnRom.off(MENU_PTR, 6)
  local t = {}
  for i = 0, 12 do t[#t + 1] = string.char(rom:u8(off + i)) end
  return table.concat(t)
end

-- Harness setup. The opcode handlers already stage WRAM, so new() only
-- calls this when $CCA7 is not the armed $FF. Labels here are synthetic.
function M.demo(vm, mode)
  mode = normMode(mode)
  local function arm(index, slot)
    vm:wr8(0xCCB4, index)
    vm:wr8(0xCCA9, 0xF3)
    wr16(vm, 0xCCB6, 0xCCD6)
    vm:wr8(0xCCB9, 1)
    vm:wr8(0xCD81, slot)
    vm:wr8(0xCCA7, 0xFF)
  end
  if mode == "8f" then
    local n = 10
    vm:wr8(0xA122, n)
    vm:wr8(WRAM, n)
    for i = 0, n - 1 do
      vm:wr8(0xA025 + i * 0x25, i)
      vm:wr8(0xA025 + i * 0x25 + 2, 1)
      vm:wr8(WRAM + 1 + i, i)
      vm:wr8(0xA4A6 + i, 9)
    end
    wr16(vm, 0xA3A5, 999)
    vm:wr8(0xCCCC, n)
    vm:wr8(0xCCD5, 0)
    vm:wr8(0xCCE1, 0)
    vm:wr8(0xCCE2, 1)
    vm:wr8(0xCCE3, 3)
    vm:wr8(0xCCEB, 0xF3)
    wr16(vm, 0xCCE4, 0xA118)
    arm(8, 3)
  elseif mode == "90" then
    local id = 0
    if vm.rom and vm.recordOff then
      for i = 0, 80 do
        if vm.rom:u8(vm:recordOff(0, i) - 6) > 0 then id = i; break end
      end
    end
    local n = 10
    vm:wr8(WRAM, n)
    for i = 0, n - 1 do
      local a = WRAM + 1 + i * 3
      vm:wr8(a, (id + i) % 256)
      vm:wr8(a + 1, 1) -- synthetic unit cost, so a harness buy can finish
      vm:wr8(a + 2, 0)
      vm:wr8(0xA3A7 + ((id + i) % 256), 0)
    end
    wr16(vm, 0xA3A5, 100)
    vm:wr8(0xCCC6, 0)
    vm:wr8(0xCCFB, 0)
    vm:wr8(0xCCC8, 8)
    vm:wr8(0xCCCB, 3)
    vm:wr8(0xCCE3, 3)
    vm:wr8(0xCCEB, 4)
    vm:wr8(0xCCCC, n)
    vm:wr8(0xCCE8, 0x22)
    vm:wr8(0xCCE9, 0x0C)
    vm:wr8(0xCCEA, 0x0D)
    wr16(vm, 0xCCE6, 0x5DFF)
    wr16(vm, 0xCCE4, 0xA3A7)
    arm(6, 0)
  else
    local n = 10
    vm:wr8(WRAM, n)
    for i = 0, n - 1 do
      local a = WRAM + 1 + i * 0x0E
      vm:wr8(a, i + 1)
      local label = string.format("ROW %02d", i)
      for j = 1, 13 do vm:wr8(a + j, label:byte(j) or 0x20) end
    end
    vm:wr8(0xCCCC, n)
    vm:wr8(0xCCD5, 0)
    vm:wr8(0xCCC6, 0)
    vm:wr8(0xCCC8, 8)
    vm:wr8(0xCCCB, 3)
    vm:wr8(0xCCE3, 0)
    vm:wr8(0xCCE1, 0)
    vm:wr8(0xCCE2, 1)
    vm:wr8(0xCCEB, 0x0B)
    wr16(vm, 0xCCE6, 0xD001)
    arm(8, 3)
  end
end

function M.new(ctx, mode)
  mode = normMode(mode)
  local vm = ctx.vm
  if vm and vm:rd8(0xCCA7) ~= 0xFF then M.demo(vm, mode) end
  local s = setmetatable({
    ctx = ctx, vm = vm, rom = ctx.rom or (vm and vm.rom), mode = mode,
    lastDir = nil, show = false, textOk = true,
  }, M)
  s:open()
  return s
end

function M:open()
  local vm = self.vm
  seedMarks(vm)
  Win.reset(self)
  if self.mode == "8c" then
    fillCopied(vm)
    stampRows(vm)
  elseif self.mode == "8f" then
    stageSram(vm, self.rom)
  end
  -- StageCopiedBlockArmSlot / StageSramListArmSlot blank the upper pair
  -- ($77C2), then stamp or blank the lower pair from the length.
  if self.mode == "8c" or self.mode == "8f" then
    Win.windowPair(self)
    if vm:rd8(0xCCE2) ~= 0 then Win.markPair(self) else Win.blankMark(self) end
  end
  Slots.arm(vm)
end

function M:finish(reason, pick)
  self.result = { mode = self.mode, closed = reason, pick = pick }
  return self.result
end

function M:dispatch(slot)
  local vm, rom = self.vm, self.rom
  vm:wr8(0xCCA7, slot)
  if self.mode == "8c" then
    if slot == 0xFE or slot == 0x0D then return self:finish(slot == 0xFE and "fe" or "0d", slot) end
    if slot == 0x0B then scrollCopied(self, slot, -1); return nil end
    if slot == 0x0C then scrollCopied(self, slot, 1); return nil end
    commitCopied(vm, slot)
    return nil
  end
  if self.mode == "8f" then
    if slot == 0xFE then return self:finish("fe", slot) end
    if slot == 0x0B then scrollSram(self, rom, slot, -1); return nil end
    if slot == 0x0C then scrollSram(self, rom, slot, 1); return nil end
    vm:wr8(0xCCC9, 0xFF)
    spendSram(vm, rom, slot)
    return nil
  end
  if slot == 0xFE then
    local why = stepFe(self)
    if why then return self:finish(why, slot) end
    return nil
  end
  if slot == 0x0B then scrollPrefixed(self, slot, -1); return nil end
  if slot == 0x0C then scrollPrefixed(self, slot, 1); return nil end
  if slot == 0x00 or slot == 0x01 then enterMode(self, slot); return nil end
  if slot == 0x02 then return self:finish("done", slot) end
  if vm:rd8(0xCCCB) == 0 then spendPrefixed(vm, rom, slot) else sellPrefixed(self, rom, slot) end
  return nil
end

function M:update()
  if self.result then return self.result end
  self.show = Slots.blink(self.vm)
  local inp = self.ctx.input
  if inp("a") then return self:dispatch(self.vm:rd8(0xCD81)) end
  if inp("b") then return self:dispatch(0xFE) end
  local d = inp("dir")
  if d and d ~= self.lastDir then Slots.move(self.vm, d) end
  self.lastDir = d
  if self.mode == "90" then
    local cur = self.vm:rd8(0xCD81)
    if cur ~= self.vm:rd8(0xCCC9) and cur >= 3 and cur <= 10 then
      self.vm:wr8(0xCCC9, cur)
    end
  end
  return nil
end

local function glyph(self, s, x, y)
  if not self.textOk or not s or s == "" then return end
  local ok = pcall(Font.drawText, s, x, y)
  if not ok then self.textOk = false end
end

function M:draw()
  if not love or not love.graphics then return end
  local vm = self.vm
  local g = love.graphics
  if not Win.draw(self) then
    g.setColor(1, 1, 1)
    g.rectangle("fill", 0, 0, 160, 144)
    g.setColor(0, 0, 0)
    g.rectangle("fill", 0, 0, 160, 8)
    g.rectangle("fill", 0, 96, 160, 8)
    g.rectangle("fill", 0, 136, 160, 8)
    g.rectangle("fill", 0, 0, 8, 144)
    g.rectangle("fill", 152, 0, 8, 144)
    g.setColor(1, 1, 1)
  end
  for row = 0, 7 do
    local id = vm:rd8(0xCCCD + row)
    if id ~= 0xFF and vm:rd8(0xCCD9 + row) ~= 0 then
      local y = (3 + row) * 8
      if self.mode == "8c" then
        glyph(self, copiedName(vm, vm:rd8(0xCCD5) + row), 8, y)
      elseif self.mode == "8f" then
        glyph(self, sramName(self.rom, id), 8, y)
        local qty = vm:rd8(0xCD17 + row)
        if qty ~= 0xFF then glyph(self, places(0xDE, qty, 2), 14 * 8, y) end
        local abs = (vm:rd8(0xCCD5) + row) % 256
        for i = 0, 9 do
          local b = vm:rd8(0xA118 + i)
          if b ~= 0 and (b - 1) % 256 == abs then glyph(self, string.char(0xF7), 17 * 8, y); break end
        end
      else
        local name = vm.recordName and vm:recordName(0, id) or ""
        glyph(self, name, 8, y)
        local cost
        if vm:rd8(0xCCCB) == 0 then
          local rec = (vm:rd8(0xCCD5) + row) % 256
          cost = vm:rd8(WRAM + 2 + rec * 3) + vm:rd8(WRAM + 3 + rec * 3) * 256
          glyph(self, string.char(0xFE), 15 * 8, y)
        else
          cost = sellWord(vm, self.rom, id)
        end
        if cost and cost ~= 0xFFFF then glyph(self, places(0xEE, cost, 3), 16 * 8, y) end
      end
    end
  end
  if self.mode == "8f" then
    glyph(self, places(0xEE, rd16(vm, 0xA3A5), 3), 15 * 8, 15 * 8)
    local row = vm:rd8(0xCD81)
    if row >= 3 and row <= 10 then
      local i = row - 3
      local rec = 0xCCFE + i * 3
      local cost = vm:rd8(rec) + vm:rd8(rec + 1) * 256
      if cost ~= 0xFFFF then
        glyph(self, places(0xEE, cost, 3), 3 * 8, 15 * 8)
        glyph(self, places(0xDE, vm:rd8(rec + 2), 2), 3 * 8, 16 * 8)
      end
      local id = vm:rd8(0xCCCD + i)
      if id ~= 0xFF then glyph(self, places(0xDE, vm:rd8(0xA4A6 + id), 2), 15 * 8, 16 * 8) end
    end
  elseif self.mode == "90" then
    local menu = menuGlyphs(self.rom)
    if #menu >= 11 then
      glyph(self, menu:sub(1, 3), 16, 14 * 8)
      glyph(self, menu:sub(4, 6), 16, 15 * 8)
      glyph(self, menu:sub(8, 11), 16, 16 * 8)
    end
    glyph(self, places(0xEE, rd16(vm, 0xA3A5), 3), 14 * 8, 14 * 8)
    local row = vm:rd8(0xCD81)
    if row >= 3 and row <= 10 then
      local id = vm:rd8(0xCCCD + row - 3)
      if id ~= 0xFF then glyph(self, places(0xEE, vm:rd8(0xA3A7 + id), 3), 14 * 8, 16 * 8) end
    end
  end
  if self.show then
    local ok, im = pcall(Font.hand)
    if ok and im then g.setColor(1, 1, 1); g.draw(im, vm:rd8(0xCD82) * 8, vm:rd8(0xCD83) * 8) end
  end
end

return M
