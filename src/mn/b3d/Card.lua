-- Name card for a creature with no battle picture (the 3D twin of mn.Battle:drawCard: a dark
-- card with a white outline and the name in the battle window font, 8 px a letter).
-- The card is sized to its name instead of cutting it at 8 letters: a name splits at an inner
-- space or capital ("BlackAgovo" -> "Black" / "Agovo") or else in half, rows longer than 6 letters are
-- cut into 6-letter pieces, and the card widens past 32 px when a row needs it. Rows are
-- centred. Presenter scales the quad with the card, so letters keep their shape.
-- The card is drawn the first time a slot needs it, which happens inside Presenter:render()
-- while the 3D shader, the depth canvas, depth testing and the 3D colour are all active. Those
-- must be switched off here, or the text and outline are drawn through the 3D matrices and the
-- card comes out blank. `g` is love.graphics (a stub in tests); `font` is mn.Font.
local C = {}

C.W, C.H = 32, 40          -- smallest card (the 2D card size)
C.WORLD_W, C.WORLD_H = 1.6, 2.0 -- world size of a 32x40 card
local ROW = 6
local WIN = { [0] = { 0, 0, 0 }, { 0.4, 0.4, 0.4 }, { 0.75, 0.75, 0.75 }, { 1, 1, 1 } } -- white on black

-- rows, width and height (pixels) for a name
function C.layout(name)
  name = (name and name ~= "") and name or "?"
  local parts
  if #name <= 4 then
    parts = { name }
  else
    local sp = name:find(" ", 2, true)
    local cut = name:find("%u", 2)
    if sp and sp < #name then parts = { name:sub(1, sp - 1), name:sub(sp + 1) }
    elseif cut and cut > 2 and cut <= #name - 1 then parts = { name:sub(1, cut - 1), name:sub(cut) }
    else local h = math.ceil(#name / 2); parts = { name:sub(1, h), name:sub(h + 1) } end
  end
  local rows, wide = {}, 0
  for _, p in ipairs(parts) do
    for i = 1, #p, ROW do
      local r = p:sub(i, i + ROW - 1)
      rows[#rows + 1] = r
      if #r > wide then wide = #r end
    end
  end
  return rows, wide <= 4 and C.W or wide * 8 + 8, C.H -- 4 letters fill the 2D card edge to edge
end

-- world size of the quad for a name (same pixel scale as the 32x40 card)
function C.worldSize(name)
  local _, w, h = C.layout(name)
  return C.WORLD_W * w / C.W, C.WORLD_H * h / C.H
end

function C.draw(g, font, canvas, name)
  local rows, w, h = C.layout(name)
  local prev = g.getCanvas()
  g.push("all")
  g.setShader()            -- the 3D shader would project the 2D text off the card
  g.setDepthMode()         -- this canvas has no depth buffer
  g.origin()
  g.setBlendMode("alpha")
  g.setCanvas(canvas)
  g.clear(0.1, 0.1, 0.1, 1)
  g.setColor(1, 1, 1, 1)
  g.rectangle("line", 0.5, 0.5, w - 1, h - 1)
  local y = math.floor((h - #rows * 8) / 2)
  for i, r in ipairs(rows) do
    font.drawText(r, math.floor((w - #r * 8) / 2), y + (i - 1) * 8, WIN)
  end
  g.pop()
  g.setCanvas(prev)
  return canvas
end

return C
