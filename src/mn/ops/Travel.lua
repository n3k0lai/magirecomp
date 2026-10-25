-- mn.ops.Travel: bank-$29 map-to-map travel cards, the bank-7 "take" twin of $87,
-- and the bank-3 choice calls. See src/mn/OpExt.lua for the handler contract.
local bit = require("bit")
local ListChoice = require("mn.ui.ListChoice")
local Picture = require("mn.Picture")
local bor, lshift = bit.bor, bit.lshift

local M = { handlers = {} }

local WRAM6 = 0x60000 -- bank 6 addresses, the same flat form as ScriptVM's bank-7 $7xxxx

local function setbit(e, n) return bor(e, lshift(1, n)) end

local function wordAt(vm, a)
  vm:wr8(a, 0x00); vm:wr8(a + 1, 0x00); vm:wr8(a + 2, 0x02); vm:wr8(a + 3, 0x14)
end

local function put16(vm, a, w)
  vm:wr8(a, w % 256); vm:wr8(a + 1, math.floor(w / 256))
end

-- clamp_map_camera.asm: pin the column and row, then the scroll bytes.
local function clampCamera(vm)
  local e = 0
  local width = vm:rd8(0xC847)
  local col = vm:rd8(0xC85F)
  local function pinCol()
    vm:wr8(0xC85F, 0); vm:wr8(0xC85D, 0); e = setbit(e, 2)
    if vm:rd8(0xC845) == 0 then e = setbit(e, 1) end
  end
  if width == 0x0A then
    e = setbit(e, 3); pinCol()
  elseif col == 0 or col >= width then pinCol()
  else
    local lim = vm:rd8(0xC845)
    if lim <= col then
      e = setbit(e, 1); vm:wr8(0xC85D, 0x0F); vm:wr8(0xC85F, lim)
      if lim == 0 then e = setbit(e, 2) end
    end
  end
  local rowLim = vm:rd8(0xC846)
  local height = (rowLim + 0x0A) % 256
  local row = vm:rd8(0xC860)
  local function pinRow()
    vm:wr8(0xC860, 0); vm:wr8(0xC85E, 0); e = setbit(e, 6)
    if rowLim == 0 then e = setbit(e, 5) end
  end
  if height == 0x09 then
    e = setbit(e, 7); pinRow()
  elseif row == 0 or row >= height then pinRow()
  else
    if rowLim <= row then
      e = setbit(e, 5); vm:wr8(0xC85E, 0x0F); vm:wr8(0xC860, rowLim)
      if rowLim == 0 then e = setbit(e, 6) end
    end
  end
  vm:wr8(0xC842, e)
  local scx = (vm:rd8(0xC85F) * 16 + vm:rd8(0xC85D)) % 256
  local scy = (vm:rd8(0xC860) * 16 + vm:rd8(0xC85E)) % 256
  vm:wr8(0xC935, scx); vm:wr8(0xFF43, scx)
  vm:wr8(0xC934, scy); vm:wr8(0xFF42, scy)
end

-- CopyPrefixedBlockToD000 ($1EF5): `len` bytes land at $D000 in WRAM bank 6.
local function copyBlock(vm, src, len)
  for i = 0, len - 1 do vm:wr8(WRAM6 + 0xD000 + i, vm.rom:u8(src + i)) end
  vm:wr8(0xC937, 6)
end

-- The armed-slot tail shared by the bank-3 choice openers. The choice loop
-- that follows is a window; it is not drawn, and the script resumes.
local function armSlot(vm, index, mark, ptr, w0, w1, flag)
  vm:wr8(0xCCB4, index)
  vm:wr8(0xCCA9, mark)
  vm:wr8(0xCCB8, vm:rd8(0xC937))
  put16(vm, 0xCCB6, ptr)
  put16(vm, 0xCCB0, w0)
  put16(vm, 0xCCB2, w1)
  vm:wr8(0xCCB9, flag)
  vm:wr8(0xCCBA, 0)
  vm:wr8(0xCCA7, 0xFF)
end

-- fill_choice_table_from_records.asm: eight bytes at $CCCD, one per record
-- (stride $0E from $D001) or $FF once the count at $CCCC runs out.
local function fillChoice(vm)
  local index = vm:rd8(0xCCD5)
  local step, fill = index, 0
  local limit = (index + 8) % 256
  local len = vm:rd8(0xCCCC)
  local padding = false
  while true do
    local v = padding and 0xFF or vm:rd8(WRAM6 + 0xD001 + step * 0x0E)
    vm:wr8(0xCCCD + fill, v)
    local nxt = (step + 1) % 256
    if nxt == limit then vm:wr8(0xCCC6, step); vm:wr8(0xCCC9, fill); return end
    step, fill = nxt, (fill + 1) % 256
    if not padding and len == step then padding = true end
  end
end

-- The list window runs only once a script coroutine is waiting on it.
-- vm.init (map setup) and a host with no overlay leave the staged bytes
-- and let the script continue, which is what the opcode used to do.
local function openList(vm, mode)
  if vm.init or not vm.host or not vm.host.runOverlay then return end
  local ctx = vm.host.uiContext and vm.host.uiContext()
  ctx = ctx or { rom = vm.rom, vm = vm, input = function() end, log = {} }
  vm.host.runOverlay(ListChoice.new(ctx, mode))
end

local function floorByte(vm, addr)
  local v = vm:rd8(addr) - vm:rd8(0xC9FE)
  if v < 0 then v = 0 end
  vm:wr8(addr, v)
end

-- AddByteToScanC ($743C). Bank7CopyIndexedName (give-table category 2)
-- jumps here with HL = $A019+id. The byte gains $C9FE. A carry stores $FF
-- and clears $C9FD; no carry stores the sum and sets $C9FD to 1.
-- The chest treats a zero $C9FD as full (22:4074).
function M.addScanByte(vm, addr, cnt)
  local sum = vm:rd8(addr) + cnt
  if sum > 0xFF then
    vm:wr8(addr, 0xFF)
    vm:wr8(0xC9FD, 0)
    return false
  end
  vm:wr8(addr, sum)
  vm:wr8(0xC9FD, 1)
  return true
end

-- StoreIndex3RecordByte (07:72FF). Give-table category 3, shared with
-- opcode $87: $A5A5+id becomes the ROM byte eight before that spell's
-- record. $C9FD becomes 1. The count is not used.
function M.grantSpell(vm, id)
  vm:wr8(0xA5A5 + id, vm.rom:u8(vm:recordOff(3, id) - 8))
  vm:wr8(0xC9FD, 1)
  return true
end

-- Categories opcode $A4 hands to CopyThreeBank7. The chest stores 1 at
-- $C9FE first (LCDOnAfterOffset7Record). Nil means some other category.
function M.grant(vm, cat, id, cnt)
  if cat == 2 then return M.addScanByte(vm, 0xA019 + id, cnt) end
  if cat == 3 then return M.grantSpell(vm, id) end
  return nil
end

-- $86 seed_camera_loop.asm ($1F50). Same opening as FinishStartup, without
-- clearing $CCA5 and without setting $C6F3. The following script is the
-- travel-card setup; $20 is the stride and both camera limits. The
-- destination map is the $65 later in that chain (host.loadMap).
M.handlers[0x86] = function(vm, o, n)
  wordAt(vm, 0xC70E) -- InitQuadRecords ($28A9)
  wordAt(vm, 0xC71C)
  wordAt(vm, 0xC715)
  for _, a in ipairs({ 0xC6F5, 0xC6F6, 0xC6F7, 0xC6F8, 0xC6FA, 0xC6FC }) do vm:wr8(a, 0) end
  local box = 0x20
  vm:wr8(0xC847, box); vm:wr8(0xC848, box); vm:wr8(0xC845, box); vm:wr8(0xC846, box)
  clampCamera(vm)
  if vm.host.seedCamera then vm.host.seedCamera(box) end
  return o + n
end

-- $6A and $63 share one picture. Later cards write over the same VRAM.
-- TODO(LoadFiveBankedMapSources): opcode $65 returns to the field map and
-- must call vm.host.picture(nil). That handler lives in ScriptVM.
local function livePicture(vm)
  local pic = vm.travelPicture
  if not pic then pic = Picture.new(); vm.travelPicture = pic end
  pic.vm = vm
  return pic
end

local function publishPicture(vm, pic)
  -- clamp_map_camera.asm stores SCX/SCY at $FF43/$FF42. draw() reads them.
  pic.scx, pic.scy = vm:rd8(0xFF43), vm:rd8(0xFF42)
  if vm.host.picture then vm.host.picture(pic) end
end

-- $63 call_banked_word_then_resume.asm ($17D7) -> UnpackScriptMapsAt9800 ($2D14).
M.handlers[0x63] = function(vm, o, n)
  local ptr, bank = vm.rom:u16(o + 1), vm.rom:u8(o + 3)
  if vm.host.travelBg then vm.host.travelBg(bank, ptr) end
  local pic = livePicture(vm)
  pic:unpackMaps(vm.rom, bank, ptr)
  publishPicture(vm, pic)
  return o + n
end

-- $6A call_script_map_records_then_fill_c72b.asm ($1903).
M.handlers[0x6A] = function(vm, o, n)
  local p1, b1 = vm.rom:u16(o + 1), vm.rom:u8(o + 3)
  local p2, b2 = vm.rom:u16(o + 4), vm.rom:u8(o + 6)
  if vm.host.travelTiles then vm.host.travelTiles(b1, p1) end
  local pic = livePicture(vm)
  pic:copyRecords(vm.rom, b1, p1) -- CopyMapRecords ($2FC0), both VRAM banks
  pic:loadPalettes(vm.rom, b2, p2) -- the $40 bytes copied onto $C7AB below
  publishPicture(vm, pic)
  local src = b2 * 0x4000 + p2 - 0x4000
  for i = 0, 63 do
    local v = vm.rom:u8(src + i)
    vm:wr8(0xC72B + i, v)
    -- RunPanelIndexThrough2EB6 with index $07 copies those 32 words onto
    -- the BG palette block at $C7AB. The palette upload itself is not done.
    vm:wr8(0xC7AB + i, v)
  end
  vm:wr8(0xC9D8, 7)
  vm:wr8(0xC831, 1)
  return o + n
end

-- $88 copy_three_call_7465.asm ($1FD4). Sibling of $87: the three bytes are
-- category, id, count, and $7465 indexes DefaultBank7ArgTable from word 7
-- (the floor/clear side). Items $A3A7+id, Animite word $A3A5, spells $A5A5+id.
M.handlers[0x88] = function(vm, o, n)
  local cat, id, cnt = vm.rom:u8(o + 1), vm.rom:u8(o + 2), vm.rom:u8(o + 3)
  vm:wr8(0xC9FC, cat); vm:wr8(0xC9FD, id); vm:wr8(0xC9FE, cnt)
  if cat == 0 then floorByte(vm, 0xA3A7 + id) -- FloorGroupSRAMByte
  elseif cat == 1 then floorByte(vm, 0xA4A6 + id) -- Bank7FloorScanC ($A4A6)
  elseif cat == 2 then floorByte(vm, 0xA019 + id) -- Bank7FloorEntryScan
  elseif cat == 3 then vm:wr8(0xA5A5 + id, 0) -- ClearIndex3SRAMByte; count unused
  elseif cat == 4 then
    -- SubC9FEClearOrWrapMapWord0: DE is the two's complement of the count.
    -- Carry (the word was at least the count) stores zero; no carry stores
    -- the wrapped difference.
    local word = vm:rd8(0xA3A5) + vm:rd8(0xA3A6) * 256
    local sum = word + ((65536 - cnt) % 65536)
    if sum >= 65536 then sum = 0 else sum = sum % 65536 end
    vm:wr8(0xA3A5, sum % 256); vm:wr8(0xA3A6, math.floor(sum / 256))
  end
  -- table words 12 and 13 (categories 5 and 6) are Bank7ArgReturn
  return o + n
end

-- $8B call_bank3_then_dispatch.asm ($2045) -> StageTilesArmSlot (bank 3 $50D0).
M.handlers[0x8B] = function(vm, o, n)
  vm:wr8(0xCC42, 0x10)
  put16(vm, 0xCC43, 0x52F2)
  put16(vm, 0xCC45, 0x8860)
  armSlot(vm, 0x08, 0xF3, 0xCCD6, 0x6B77, 0x42E3, 1)
  vm:wr8(0xCCE3, 0x03)
  vm:wr8(0xCCEB, 0xF9)
  -- DispatchArmedChoice ($4F83) runs the window, then the next opcode.
  -- ChoiceWindow writes $CCFD (and $CCFC on cancel) the way that loop does.
  if not vm.init and vm.host.runOverlay and vm.host.uiContext then
    vm.host.runOverlay(require("mn.ui.ChoiceWindow").new(vm.host.uiContext()))
  end
  return o + n
end

-- $8C rewind_copy_then_call_5400.asm ($205E) -> StageCopiedBlockArmSlot ($5400).
M.handlers[0x8C] = function(vm, o, n)
  local len = n - 3
  copyBlock(vm, o + 3, len)
  vm:wr8(0xCCCC, vm:rd8(WRAM6 + 0xD000))
  vm:wr8(0xCCD5, 0)
  vm:wr8(0xCCC6, 0)
  vm:wr8(0xCCEB, 0x0B)
  vm:wr8(0xCCC8, 0x08)
  put16(vm, 0xCCE6, 0xD001)
  vm:wr8(0xCCCB, 0x03)
  fillChoice(vm)
  vm:wr8(0xCCE3, 0)
  vm:wr8(0xCCE1, 0)
  vm:wr8(0xCCE2, vm:rd8(0xCCCC) > 8 and 1 or 0)
  vm:wr8(0xCD81, 3)
  armSlot(vm, 0x08, 0xF3, 0xCCD6, 0x6B77, 0x42E3, 1)
  openList(vm, "8c")
  return o + n
end

-- $8D call_bank3_5aae_then_dispatch.asm ($2070) -> StageWindowTilesArmSlot ($5AAE).
M.handlers[0x8D] = function(vm, o, n)
  vm:wr8(0xC728, 0); vm:wr8(0xC729, 0)
  vm:wr8(0xC6EB, 1)
  put16(vm, 0xC6E7, 0x41D0) -- second glyph source, the last store to wGlyphSrc
  put16(vm, 0xC6E9, 0x8900)
  vm:wr8(0xCC42, 0x05)
  put16(vm, 0xCC43, 0x52E0)
  put16(vm, 0xCC45, 0x8920)
  vm:wr8(0xCD58, vm:rd8(0xA122))
  vm:wr8(0xCC4E, 1)
  for i = 0, 3 do vm:wr8(0xCC56 + i, 1) end
  vm:wr8(0xCD81, 1)
  armSlot(vm, 0x07, 0xF3, 0xCC4D, 0x42E3, 0x42E3, 0)
  -- ServiceWindowChoice ($58CB) runs the window, then the next opcode.
  -- ChoiceWindow writes $CD74 the way that loop saves the choice.
  if not vm.init and vm.host.runOverlay and vm.host.uiContext then
    vm.host.runOverlay(require("mn.ui.ChoiceWindow").new(vm.host.uiContext()))
  end
  return o + n
end

-- $8F rewind_copy_then_call_7025.asm ($20C8) -> StageSramListArmSlot ($7025).
M.handlers[0x8F] = function(vm, o, n)
  copyBlock(vm, o + 3, n - 3)
  vm:wr8(0xCCD5, 0)
  vm:wr8(0xCCE9, 0)
  vm:wr8(0xCD81, 3)
  put16(vm, 0xCCE4, 0xA118)
  vm:wr8(0xCCCC, vm:rd8(0xA122))
  vm:wr8(0xCCE1, 0)
  vm:wr8(0xCCE2, vm:rd8(0xCCCC) > 8 and 1 or 0)
  armSlot(vm, 0x08, 0xF3, 0xCCD6, 0x6B77, 0x42E3, 1)
  vm:wr8(0xCCE3, 0x03)
  vm:wr8(0xCCEB, 0xF3)
  openList(vm, "8f")
  return o + n
end

-- $90 copy_prefixed_then_call_66be.asm ($20DA) -> SetupPrefixedBlockChoice ($66BE).
-- The first three operand bytes are the ones CopyPrefixedBlockToD000 skips.
M.handlers[0x90] = function(vm, o, n)
  copyBlock(vm, o + 6, n - 6)
  vm:wr8(0xCCC6, 0)
  vm:wr8(0xCCFB, 0)
  vm:wr8(0xCCC8, 0x08)
  vm:wr8(0xCCCB, 0x03)
  vm:wr8(0xCCE3, 0x03)
  vm:wr8(0xCCEB, 0x04)
  vm:wr8(0xCD81, 0)
  vm:wr8(0xCCCC, vm:rd8(WRAM6 + 0xD000))
  vm:wr8(0xCCE8, 0x22)
  vm:wr8(0xCCE9, 0x0C)
  put16(vm, 0xCCE6, 0x5DFF)
  put16(vm, 0xCCE4, 0xA3A7) -- item counts, the list the choice walks
  vm:wr8(0xCCEA, 0x0D)
  armSlot(vm, 0x06, 0xF3, 0xCCD6, 0x6B77, 0x42E3, 1)
  openList(vm, "90")
  return o + n
end

function M.host(ow, h)
  -- $86 writes $20 into the stride and the camera limits $C845/$C846.
  -- $84's cameraCell clamps through these same two fields on the map def.
  h.seedCamera = function(box)
    if ow.def then ow.def.camCol, ow.def.camRow = box, box end
    ow.camBox = box
  end
  -- $63 / $6A name the travel card's background map and its tile list.
  -- The gameplay map change stays on $65 -> h.loadMap.
  h.travelBg = function(bank, ptr) ow.travelBg = { bank, ptr } end
  h.travelTiles = function(bank, ptr) ow.travelTiles = { bank, ptr } end
end

return M
