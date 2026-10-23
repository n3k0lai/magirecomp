-- Cursor for the bank-3 list windows.
-- Index 8: slot_list_index8.asm ($47AA), copied-block and SRAM lists.
-- Index 6: slot_list_index6.asm ($4742), the prefixed-block window.
-- Eight-byte records: column, row, then right/left/up/down, then A=4 and B=5
-- (store_selected_slot_index.asm / store_fe_slot_index.asm).
-- SelectSlotFromHighNibble re-reads the same direction field after
-- CopyIndexedSlot, so a zero mark walks that direction. LoadArmedSlotRecord
-- ($417C) does the same walk through the right field only.

local M = {}

local INDEX8 = {
  [0] = { 1, 0x0E, 0x0D, 0x0D, 2, 1 },
  { 1, 0x0F, 0x0D, 0x0D, 0, 2 },
  { 1, 0x10, 0x0D, 0x0D, 1, 0 },
  { 1, 3, 4, 0x0B, 0x0B, 4 },
  { 1, 4, 5, 3, 3, 5 },
  { 1, 5, 6, 4, 4, 6 },
  { 1, 6, 7, 5, 5, 7 },
  { 1, 7, 8, 6, 6, 8 },
  { 1, 8, 9, 7, 7, 9 },
  { 1, 9, 0x0A, 8, 8, 0x0A },
  { 1, 0x0A, 0x0C, 9, 9, 0x0C },
  { 8, 1, 3, 0x0A, 0x0C, 3 },
  { 8, 0x0C, 0x0B, 3, 0x0A, 0x0B },
  { 0x0D, 0x0F, 1, 1, 0, 2 },
}

local INDEX6 = {
  [0] = { 1, 0x0E, 1, 2, 2, 1 },
  { 1, 0x0F, 2, 0, 0, 2 },
  { 1, 0x10, 0, 1, 1, 0 },
  { 0, 3, 4, 0x0B, 0x0B, 4 },
  { 0, 4, 5, 3, 3, 5 },
  { 0, 5, 6, 4, 4, 6 },
  { 0, 6, 7, 5, 5, 7 },
  { 0, 7, 8, 6, 6, 8 },
  { 0, 8, 9, 7, 7, 9 },
  { 0, 9, 0x0A, 8, 8, 0x0A },
  { 0, 0x0A, 0x0C, 9, 9, 0x0C },
  { 8, 1, 3, 0x0A, 0x0C, 3 },
  { 8, 0x0C, 0x0B, 3, 0x0A, 0x0B },
}

local FIELD = { right = 0, left = 1, up = 2, down = 3 }

function M.records(index)
  if index == 6 then return INDEX6 end
  return INDEX8
end

function M.copy(vm, index)
  local rec = M.records(vm:rd8(0xCCB4))[index % 256]
  if not rec then return end
  vm:wr8(0xCD82, rec[1])
  vm:wr8(0xCD83, rec[2])
  vm:wr8(0xCD84, rec[3])
  vm:wr8(0xCD85, rec[4])
  vm:wr8(0xCD86, rec[5])
  vm:wr8(0xCD87, rec[6])
  vm:wr8(0xCD88, 4)
  vm:wr8(0xCD89, 5)
end

-- LoadArmedSlotRecord: a zero mark at $CCD6+$CD81 takes the right-hand slot.
function M.arm(vm)
  local guard = 0
  M.copy(vm, vm:rd8(0xCD81))
  while vm:rd8(0xCCD6 + vm:rd8(0xCD81)) == 0 and guard < 20 do
    vm:wr8(0xCD81, vm:rd8(0xCD84))
    M.copy(vm, vm:rd8(0xCD81))
    guard = guard + 1
  end
  vm:wr8(0xCD7F, 0)
  vm:wr8(0xCD80, 0)
end

function M.move(vm, dir)
  local field = FIELD[dir]
  if not field then return end
  local guard = 0
  while guard < 20 do
    local nxt = vm:rd8(0xCD84 + field)
    vm:wr8(0xCD81, nxt)
    M.copy(vm, nxt)
    if vm:rd8(0xCCD6 + nxt) ~= 0 then return end
    guard = guard + 1
  end
end

-- QueueBlinkSprite: $CD7F wraps at $1F. Hidden while the count is below $0F
-- when $CCB9 is set and $CD80 is not 1 (the handlers arm with $CCB9 = 1).
function M.blink(vm)
  local n = (vm:rd8(0xCD7F) + 1) % 0x20
  vm:wr8(0xCD7F, n)
  if vm:rd8(0xCCB9) ~= 0 and vm:rd8(0xCD80) ~= 1 then return n >= 0x0F end
  return true
end

return M
