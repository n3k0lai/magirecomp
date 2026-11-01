-- The asm's logical map camera, apart from the port's visible pixels.
--
-- wMapColumn/wMapRow ($C85F/$C860) and the fine bytes ($C85D/$C85E, 0-15) are what
-- $82/$84 store and what StepHorizontalScroll / StepVerticalScroll step.
-- wCameraPixelX/Y ($C935/$C934, copied to rSCX/rSCY) are rebuilt from those
-- bytes only by ClampMapCamera (clamp_map_camera.asm: DrawMetatileWindow under
-- $93, and $86) and otherwise moved by the same applied scroll delta.
--
-- $82 (center_fine_scroll_on_script_base.asm) and $84
-- (center_fine_scroll_on_script_word.asm) store cell - 5 and fine 8. They do
-- not call ClampMapCamera. The bias is applied by the caller
-- (StoreMapCellFromDEMinus5, $FB).
local bit = require("bit")
local M = {}

local FINE_SCROLL_CENTER = 8

-- $82 / $84 after the -5 bias: both fine bytes = 8. Column and row are bytes.
function M.center(col, row)
  return { col = col % 256, row = row % 256, fx = FINE_SCROLL_CENTER, fy = FINE_SCROLL_CENTER }
end

-- $2F37 header unpack ($65, $67): column, row and fine bytes zeroed.
function M.origin() return { col = 0, row = 0, fx = 0, fy = 0 } end

-- One applied scroll step. The steps add the same delta to the fine byte and
-- to $C935/$C934; a fine borrow/carry changes the column or row (8-bit).
function M.step(cam, dx, dy)
  local x, y = cam.col * 16 + cam.fx + dx, cam.row * 16 + cam.fy + dy
  cam.col, cam.fx = math.floor(x / 16) % 256, x % 16
  cam.row, cam.fy = math.floor(y / 16) % 256, y % 16
  return cam
end

-- ClampMapCamera. lim.w = $C847 (width / row stride), lim.col = $C845,
-- lim.row = $C846 ($FF: no vertical scroll). Returns the pinned camera, the
-- $C842 edge flags, and the pixel bytes $C935 / $C934 (8-bit, as rSCX/rSCY).
function M.clamp(lim, cam)
  local col, row, fx, fy, e = cam.col, cam.row, cam.fx, cam.fy, 0
  local function pinColumnZero()
    col, fx = 0, 0; e = bit.bor(e, 4)
    if lim.col == 0 then e = bit.bor(e, 2) end
  end
  if lim.w == 10 then e = bit.bor(e, 8); pinColumnZero()
  elseif col == 0 or col >= lim.w then pinColumnZero()
  elseif col >= lim.col then
    e = bit.bor(e, 2); fx, col = 15, lim.col
    if col == 0 then e = bit.bor(e, 4) end
  end
  local d = (lim.row + 10) % 256
  local function pinRowZero()
    row, fy = 0, 0; e = bit.bor(e, 0x40)
    if lim.row == 0 then e = bit.bor(e, 0x20) end
  end
  if d == 9 then e = bit.bor(e, 0x80); pinRowZero()
  elseif row == 0 or row >= d then pinRowZero()
  elseif row >= lim.row then
    e = bit.bor(e, 0x20); fy, row = 15, lim.row
    if row == 0 then e = bit.bor(e, 0x40) end
  end
  return { col = col, row = row, fx = fx, fy = fy }, e, (col * 16 + fx) % 256, (row * 16 + fy) % 256
end

-- Header bytes 3 and 4. A def without them (made-up test maps) gets
-- w - 11 / h - 10. Zero is a real limit (a 10-row map's row limit); it must
-- not fall through the way a Lua `or` would.
function M.limits(def)
  -- `~= nil` then `or` still drops a 0, and 0 is a real header limit.
  local col, row = def.w - 11, def.h - 10
  if def.camCol ~= nil then col = def.camCol end
  if def.camRow ~= nil then row = def.camRow end
  return { w = def.w, col = col, row = row }
end

return M
