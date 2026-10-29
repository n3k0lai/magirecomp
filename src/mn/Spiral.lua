-- mn.Spiral: the $30 wipe, FillTilemapRect22x20 (07:56ED).
--
-- Opcode30 stores the word at $C840 (always 07:56ED in the scripts), plants
-- INITIAL_SCRIPT_HANDLER and jumps to 07:584A: CallCallback, then `jp [$C840]`.
-- 07:56ED stages tile $FF, attribute $8F (BG priority, VRAM bank 1, palette 7)
-- and paints the 22x20-tile rectangle at $C863 (the tile under the camera's
-- top-left pixel) as 2x2 blocks in a spiral: StageTilemapQuad, then calls to
-- the right/down/left/up steppers. Each block ends in CallCallback with the LCD
-- on, which waits for VBlank, so one block lands per frame. Tile $FF of VRAM
-- bank 1 is solid color 3 on the field maps, so the blocks are BG palette 7
-- color 3 and, with the priority bit, cover the sprites too. Nothing else runs
-- meanwhile: the main loop is inside the handler. The tail is FinishStartup.
local M = {}
M.__index = M

local STEP = { [0x56B1] = { 1, 0 }, [0x56CF] = { 0, 1 }, [0x56C0] = { -1, 0 }, [0x56DE] = { 0, -1 } }

-- Block cells (0-10, 0-9) in paint order, read from the routine's call list.
function M.order(rom)
  local base = 7 * 0x4000 - 0x4000
  local o = base + 0x56FD
  if rom:u8(o) ~= 0xCD or rom:u16(o + 1) ~= 0x566E then return nil end
  local x, y = 0, 0
  local t = { { 0, 0 } }
  o = o + 3
  while rom:u8(o) == 0xCD do
    local d = STEP[rom:u16(o + 1)]; if not d then return nil end
    x, y = x + d[1], y + d[2]; t[#t + 1] = { x, y }
    o = o + 3
  end
  return t
end

-- ow: the Overworld (camera, vm). The screen closes after the last block's frame.
function M.new(ow)
  return setmetatable({ ow = ow, t = 0, order = M.order(ow.vm.rom) or {} }, M)
end

function M:update()
  self.t = self.t + 1
  if self.t > #self.order then return true end
end

function M:draw()
  local ow = self.ow
  local cx, cy = ow:cameraXY()
  local LP = require("mn.LivePalette")
  local w = LP.words(ow.vm, 0xC7AB + 7 * 8, 4)[3]
  local r, g, b = LP.rgb(w)
  local ox, oy = math.floor(cx / 8) * 8 - cx, math.floor(cy / 8) * 8 - cy
  love.graphics.setColor(r, g, b)
  for i = 1, math.min(self.t, #self.order) do
    local c = self.order[i]
    love.graphics.rectangle("fill", ox + c[1] * 16, oy + c[2] * 16, 16, 16)
  end
  love.graphics.setColor(1, 1, 1)
end

return M
