-- The asm's logical map camera, kept apart from what is on screen.
--
-- wMapColumn/wMapRow ($C85F/$C860) and the fine bytes ($C85D/$C85E, 0-15) are the
-- camera the scroll steps, the sprite cull (QueueSpriteList: cell in column-2..column+11,
-- row-2..row+10), `$11` and the seam read. What is on screen is wCameraPixelX/Y
-- ($C935/$C934), copied to rSCX/rSCY at VBlank. Only ClampMapCamera (07, called by
-- DrawMetatileWindow under `$93` and by SeedCameraAndEnterLoop) rebuilds the pixel bytes
-- from the column and fine; StepHorizontalScroll / StepVerticalScroll add the same
-- clamped delta to both. `$82` (CenterFineScrollOnScriptBase, $1E30) and `$84`
-- (CenterFineScrollOnScriptWord, $1E8E) store cell - 5 and fine 8 and nothing else, so
-- with the LCD on they move the logical camera only.
--
-- This module is the first step of that split (docs/mn-transitions.md, "Camera split"):
-- the port records the logical camera next to its visible one; the visible camera
-- (Overworld camFix / camOff / cameraXY) is unchanged.
local bit = require("bit")
local M = {}

local FINE_SCROLL_CENTER = 8

-- $82 / $84: StoreMapCellFromDEMinus5 stores (cell - 5) & $FF; both fine bytes = 8
function M.center(col, row)
  return { col = col % 256, row = row % 256, fx = FINE_SCROLL_CENTER, fy = FINE_SCROLL_CENTER }
end

-- $2F37 header unpack (`$65`, `$67`): column, row and fine bytes zeroed
function M.origin() return { col = 0, row = 0, fx = 0, fy = 0 } end

-- one applied (already edge-clamped) scroll step: fine crossings move the column/row
function M.step(cam, dx, dy)
  local x, y = cam.col * 16 + cam.fx + dx, cam.row * 16 + cam.fy + dy
  cam.col, cam.fx = math.floor(x / 16) % 256, x % 16
  cam.row, cam.fy = math.floor(y / 16) % 256, y % 16
  return cam
end

-- ClampMapCamera (clamp_map_camera.asm). lim.w = $C847 (width / row stride), lim.col =
-- $C845 (last camera column), lim.row = $C846 (last camera row, $FF: no vertical
-- scroll). Returns the pinned camera, the $C842 edge flags and the pixel bytes
-- $C935 / $C934 (8-bit, as rSCX / rSCY take them).
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

-- the map header's limits as ClampMapCamera reads them (header bytes 3 / 4); a def
-- without them (made-up test maps) gets w - 11 / h - 10, what 361 of 369 headers hold
function M.limits(def) return { w = def.w, col = def.camCol or def.w - 11, row = def.camRow or def.h - 10 } end

return M
