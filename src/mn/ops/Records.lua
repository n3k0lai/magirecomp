-- mn.ops.Records: slot records and the map-cell planes.
-- Handler contract: src/mn/OpExt.lua.
--
-- WRAM banks at one address are separate planes (flat vm.mem cannot tell them
-- apart; VM:expr index 22 ignores the bank). The engine keeps the live map on
-- the overworld:
--   bank 5 = collision  (def.block)   bank 3 = metatile (def.cells)
--   bank 6 = collision overlay        bank 4 = metatile overlay
-- Opcode $68 unpacks banks 4 and 6 from the map record. That opcode is not
-- handled here, so the overlay starts as a snapshot of the live planes the
-- first time a handler touches it. $04/$0E patch the overlay. $7F copies it
-- onto the live planes. $7E copies a rectangle inside the live planes.
-- $03/$0D/$81 write the live planes through setCell.
local bit = require("bit")
local band, rshift = bit.band, bit.rshift

local M = { handlers = {} }

local function add8(a, b) return band((a or 0) + (b or 0), 0xFF) end
local function sub8(a, b) return band((a or 0) - (b or 0), 0xFF) end
local function add16(a, b) return band((a or 0) + (b or 0), 0xFFFF) end
local function s8(b) if b >= 128 then return b - 256 end return b end

-- LookupScriptIndexPointer doubles the index in eight bits (lookup_script_index_pointer.asm).
local function slotOf(i) return math.floor(band(i * 2, 0xFF) / 2) end

local function frame(vm)
  if not vm.init and coroutine.running() then coroutine.yield("wait", 1) end
end

local function rec(vm, index)
  if not (vm.host and vm.host.slotRecord) then return nil end
  return vm.host.slotRecord(slotOf(index))
end

local function commit(vm, ob)
  if ob and vm.host and vm.host.slotCommit then vm.host.slotCommit(ob) end
end

local function ptrOf(ob)
  return ob and (ob.cellPtr or 0) or 0
end

-- Banks 5 and 3: live collision, then live metatile (Overworld setCell).
local function live(vm, addr, col, mt)
  if vm.host and vm.host.setCell then vm.host.setCell(addr, col, mt) end
end

-- Banks 6 and 4: overlay collision, then overlay metatile.
local function overlay(vm, addr, col, mt)
  if vm.host and vm.host.setOverlayCell then vm.host.setOverlayCell(addr, col, mt) end
end

-- opcode_03.asm from `ld de, $0005`: dy, dx, word added to the cell pointer,
-- bank-5 byte, bank-3 byte. Column/row (cell + dx/dy) feed Opcode03ScrollEdge;
-- ScriptCellInView at bank 7 $4AA4 is still INCBIN.
-- visual: in-view scroll-edge reload, not drawn yet
-- o points at dy. The word and the two plane bytes follow dx.
local function addStore(vm, o, ob)
  local r = vm.rom
  local addr = add16(ptrOf(ob), r:u16(o + 2))
  live(vm, addr, r:u8(o + 4), r:u8(o + 5))
end

-- IndexedAddAndStore (opcode_03.asm). The bank-1 tail rets, so the burst ends.
M.handlers[0x03] = function(vm, o, n)
  local ob = rec(vm, vm.rom:u8(o + 1))
  if ob then addStore(vm, o + 2, ob) end
  frame(vm)
  return o + n
end

-- RecordAddAndStore (opcode_0d.asm): same store, record is the HRAM head at $FF8C.
M.handlers[0x0D] = function(vm, o, n)
  addStore(vm, o + 1, {
    x = vm:rd8(0xFF91), y = vm:rd8(0xFF92), cellPtr = vm:rd16(0xFF93),
  })
  frame(vm)
  return o + n
end

-- opcode_04.asm from Opcode04AddWord: word added to the pointer at record+7,
-- then a bank-6 byte and a bank-4 byte at that address.
local function overlayStore(vm, o, ob)
  local r = vm.rom
  overlay(vm, add16(ptrOf(ob), r:u16(o)), r:u8(o + 2), r:u8(o + 3))
end

-- SlotWordToWramBanks6And4 (opcode_04.asm). Returns through DispatchScriptOpcode.
M.handlers[0x04] = function(vm, o, n)
  local ob = rec(vm, vm.rom:u8(o + 1))
  if ob then overlayStore(vm, o + 2, ob) end
  return o + n
end

-- Opcode0E (opcode_0e.asm): opcode $04 with the head at $FF8C already chosen.
M.handlers[0x0E] = function(vm, o, n)
  overlayStore(vm, o + 1, { cellPtr = vm:rd16(0xFF93) })
  return o + n
end

-- WriteScriptBytesThroughBanks6And4 (write_script_bytes_through_banks_6_and_4.asm).
-- The two value bytes are script operands (the bank-6/4 select does not change
-- a ROM read). They land in bank 5 then bank 3, then Opcode03Continue rets.
-- visual: in-view scroll-edge reload, not drawn yet
M.handlers[0x81] = function(vm, o, n)
  local r = vm.rom
  live(vm, r:u16(o + 3), r:u8(o + 5), r:u8(o + 6))
  frame(vm)
  return o + n
end

local function putFine(ob, fx, fy)
  ob.fineX, ob.fineY = fx, fy
  if ob._linked then ob.ox, ob.oy = s8(fx) - 8, s8(fy) - 8 end
end

-- LookupTwoIndices (opcode_06.asm): fine X/Y of the first record become 8,
-- then cell X/Y and the cell pointer are copied from the second record.
M.handlers[0x06] = function(vm, o, n)
  local r = vm.rom
  local dst, src = rec(vm, r:u8(o + 1)), rec(vm, r:u8(o + 2))
  if dst and src then
    putFine(dst, 8, 8)
    dst.x, dst.y = src.x, src.y
    dst.cellPtr, dst.ptrSet = ptrOf(src), true
    commit(vm, dst)
  end
  return o + n
end

-- CopySixScriptBytesFromOffset3 (opcode_08.asm -> copy_six_script_bytes.asm):
-- six script bytes at record+3 (fine X/Y, cell X/Y, cell pointer).
M.handlers[0x08] = function(vm, o, n)
  local r = vm.rom
  local ob = rec(vm, r:u8(o + 1))
  if ob then
    putFine(ob, r:u8(o + 2), r:u8(o + 3))
    ob.x, ob.y = r:u8(o + 4), r:u8(o + 5)
    ob.cellPtr, ob.ptrSet = r:u16(o + 6), true
    commit(vm, ob)
  end
  return o + n
end

-- SetSlotByte9 (opcode_0a.asm): record byte 9, the sprite tile base ($05 stores it).
M.handlers[0x0A] = function(vm, o, n)
  local ob = rec(vm, vm.rom:u8(o + 1))
  if ob then ob.base = vm.rom:u8(o + 2) end
  return o + n
end

-- Head bytes $FF8F-$FF94 are hObjectFineX/Y, hObjectCellX/Y and the cell
-- pointer (queue_sprite_list.asm, copy_six_script_bytes.asm). WriteRecordHead
-- stores the head back through the running record, so a numeric curSlot moves.
local function writeHead(vm, fx, fy, x, y, ptr)
  vm:wr8(0xFF8F, fx); vm:wr8(0xFF90, fy)
  vm:wr8(0xFF91, x); vm:wr8(0xFF92, y)
  vm:wr8(0xFF93, ptr); vm:wr8(0xFF94, rshift(ptr, 8))
  if type(vm.curSlot) ~= "number" then return end
  local ob = rec(vm, vm.curSlot)
  if not ob then return end
  putFine(ob, fx, fy)
  ob.x, ob.y = x, y
  ob.cellPtr, ob.ptrSet = ptr, true
  commit(vm, ob)
end

-- CopySlotRecordFields (opcode_0f.asm): fine X/Y forced to 8, then four bytes
-- from record+5 into the head.
M.handlers[0x0F] = function(vm, o, n)
  local ob = rec(vm, vm.rom:u8(o + 1))
  if ob then writeHead(vm, 8, 8, ob.x or 0, ob.y or 0, ptrOf(ob)) end
  return o + n
end

-- Opcode17 (opcode_17.asm -> CopySixScriptBytesFromOffset3): six script bytes
-- at $FF8F. The running record is updated on the way back out of the burst.
M.handlers[0x17] = function(vm, o, n)
  local r = vm.rom
  writeHead(vm, r:u8(o + 1), r:u8(o + 2), r:u8(o + 3), r:u8(o + 4), r:u16(o + 5))
  return o + n
end

-- SetSpriteTileBase (opcode_18.asm): the next byte is hSpriteTileBase ($FF95).
-- visual: queued sprite lists add it to each tile; the object keeps it as .base
M.handlers[0x18] = function(vm, o, n)
  local b = vm.rom:u8(o + 1)
  vm:wr8(0xFF95, b)
  if type(vm.curSlot) == "number" then
    local ob = rec(vm, vm.curSlot)
    if ob then ob.base = b end
  end
  return o + n
end

-- QueueHeadWord (opcode_10.asm): little-endian word at $C186/$C187.
-- RunHeadWordScript (bank 1 $5DB5) replaces the record head word when the
-- high byte is not zero. Nothing in the engine reads the pair yet.
M.handlers[0x10] = function(vm, o, n)
  vm:wr8(0xC186, vm.rom:u8(o + 1))
  vm:wr8(0xC187, vm.rom:u8(o + 2))
  return o + n
end

-- PlantAddend01FFFromScript (plant_addend_01ff_from_script.asm): $01, $FF,
-- and the script byte minus one at $C6F5. The frame-end add (tickThreads)
-- folds $C6F5 into the rendezvous phase.
M.handlers[0x52] = function(vm, o, n)
  vm:wr8(0xC6F5, 0x01)
  vm:wr8(0xC6F6, 0xFF)
  vm:wr8(0xC6F7, sub8(vm.rom:u8(o + 1), 1))
  return o + n
end

-- StagePairSourceThenCopyWords (stage_pair_source_then_copy_words.asm).
-- Bank 7 StagePanelRowPtrAndPairCount: destination is $C72B plus eight times
-- the high nibble of the fourth byte; the pair count is four times one more
-- than the low nibble. CopyWordPairs copies that many words from the staged
-- ROM pointer. The routine rets, so the burst ends.
-- visual: panel glyphs at $C72B, not drawn yet
M.handlers[0x78] = function(vm, o, n)
  local r = vm.rom
  local ptr, bank, sel = r:u16(o + 1), r:u8(o + 3), r:u8(o + 4)
  local dest = 0xC72B + 8 * rshift(sel, 4)
  local pairs = 4 * (band(sel, 0x0F) + 1)
  vm:wr8(0xC9D5, ptr); vm:wr8(0xC9D6, rshift(ptr, 8)); vm:wr8(0xC9D7, bank)
  vm:wr8(0xC9D8, sel); vm:wr8(0xC9D9, pairs)
  vm:wr8(0xC9DA, dest); vm:wr8(0xC9DB, rshift(dest, 8))
  local src = bank * 0x4000 + ptr - 0x4000
  for i = 0, pairs * 2 - 1 do vm:wr8(dest + i, r:u8(src + i)) end
  frame(vm)
  return o + n
end

-- StageEightScriptBytes / StageEightScriptBytesCopy (stage_eight_script_bytes.asm).
-- Eight script bytes: source pointer, width, height, dest pointer, row, column.
-- AdvanceStagedCopy steps one cell. Width and height of 0 count 256 (`dec`
-- wraps). The stride is the map width ($C847). StagedByteEdgeCheck's reload
-- latch is not modeled.
-- wLCDC == 0 (map setup, vm.init) fills a row inside the handler, and
-- RunScriptLoop (finish_startup.asm) calls it again before DrawMetatileWindow,
-- so the rect is in the planes before the first draw. runInit cannot resume a
-- per-row return, so setup copies the whole rect in one pass. LCD on yields
-- one cell a frame.
local function stageRect(vm, o, n, blit)
  local r = vm.rom
  local src, w, rows = r:u16(o + 1), r:u8(o + 3), r:u8(o + 4)
  local dst, row, col = r:u16(o + 5), r:u8(o + 7), r:u8(o + 8)
  vm:wr8(0xC6FE, src); vm:wr8(0xC6FF, rshift(src, 8))
  vm:wr8(0xFFA6, w); vm:wr8(0xFFA7, w); vm:wr8(0xC704, rows)
  vm:wr8(0xC700, dst); vm:wr8(0xC701, rshift(dst, 8))
  vm:wr8(0xC702, row); vm:wr8(0xC703, col)
  local stride = (vm.host and vm.host.mapWidth and vm.host.mapWidth()) or 1
  local across = w == 0 and 256 or w
  local left = across
  while true do
    blit(src, dst)
    frame(vm)
    left = left - 1
    if left > 0 then
      src, dst = add16(src, 1), add16(dst, 1)
      col = add8(col, 1)
    else
      local back = sub8(w, 1)
      local pitch = sub8(stride, back)
      src, dst = add16(src, pitch), add16(dst, pitch)
      col, row = sub8(col, back), add8(row, 1)
      rows = sub8(rows, 1)
      if rows == 0 then break end
      left = across
    end
    vm:wr8(0xC6FE, src); vm:wr8(0xC6FF, rshift(src, 8))
    vm:wr8(0xC700, dst); vm:wr8(0xC701, rshift(dst, 8))
    vm:wr8(0xC702, row); vm:wr8(0xC703, col)
    vm:wr8(0xFFA6, left >= 256 and 0 or left); vm:wr8(0xC704, rows)
  end
  return o + n
end

-- CopyStagedByteIntoBanks5And3: the bank-5 byte, then the bank-3 byte.
-- Host copyCell writes the live collision plane and the live metatile plane.
M.handlers[0x7E] = function(vm, o, n)
  return stageRect(vm, o, n, function(src, dst)
    local h = vm.host
    if h and h.copyCell then h.copyCell(src - 0xD000, dst - 0xD000) end
  end)
end

-- StageEightScriptBytesCopy_7F (plant_bank1_handler_4552.asm) plants
-- CopyStagedByteFromBanks6And4: one cell, bank 6 -> bank 5 and bank 4 -> bank 3.
M.handlers[0x7F] = function(vm, o, n)
  return stageRect(vm, o, n, function(src, dst)
    if vm.host and vm.host.blitOverlayCell then vm.host.blitOverlayCell(src, dst) end
  end)
end

-- Record bases are $C189 + slot * $1B (record_slot_bases.asm). Spawned objects
-- already hold cell X/Y (.x/.y) and the tile base (.base). Fine X/Y and the
-- cell pointer are the bytes opcode $05 writes as $08,$08 and the address word;
-- they live on the same table. Slot 0 with no object is the player (ow.x/y).
function M.host(ow, h)
  local function derive(ob)
    local w = ow.def and ow.def.w or 0
    if w > 0 then ob.cellPtr = band(0xD000 + (ob.y or 0) * w + (ob.x or 0), 0xFFFF) end
  end

  h.slotRecord = function(slot)
    slot = slotOf(slot)
    local ob = ow.objects[slot]
    local linked = ob ~= nil
    if not ob then
      ow.looseRecords = ow.looseRecords or {}
      ob = ow.looseRecords[slot]
      if not ob then
        ob = { x = 0, y = 0, base = 0, fineX = 8, fineY = 8 }
        ow.looseRecords[slot] = ob
      end
      if slot == 0 then ob.x, ob.y = ow.x or 0, ow.y or 0 end
    end
    if ob.fineX == nil then ob.fineX = 8 end
    if ob.fineY == nil then ob.fineY = 8 end
    ob._linked, ob._slot = linked, slot
    if not ob.ptrSet then derive(ob) end
    return ob
  end

  h.slotCommit = function(ob)
    if ob and not ob._linked and ob._slot == 0 then ow.x, ow.y = ob.x, ob.y end
  end

  -- Banks 4 and 6. Snapshotted from the live planes until $68 fills them.
  local function planes()
    if ow._ovDef == ow.def and ow.ovCol then return end
    ow._ovDef = ow.def
    ow.ovCol, ow.ovMt = {}, {}
    local d = ow.def
    if not d then return end
    local n = (d.w or 0) * (d.h or 0)
    if n == 0 then n = d.block and #d.block or 0 end
    for i = 1, n do
      ow.ovCol[i] = (d.block and d.block[i]) or 0
      ow.ovMt[i] = (d.cells and d.cells[i]) or 0
    end
  end

  h.setOverlayCell = function(addr, col, mt)
    planes()
    local i = addr - 0xD000
    if i < 0 then return end
    ow.ovCol[i + 1] = band(col, 0xFF)
    ow.ovMt[i + 1] = band(mt, 0xFF)
  end

  -- $7F: overlay collision -> live collision, overlay metatile -> live metatile.
  h.blitOverlayCell = function(src, dst)
    planes()
    local i = src - 0xD000
    local col = ow.ovCol[i + 1] or 0
    local mt = ow.ovMt[i + 1] or 0
    if h.setCell then h.setCell(dst, col, mt) end
  end
end

return M
