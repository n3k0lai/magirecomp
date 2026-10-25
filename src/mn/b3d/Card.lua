-- Name card for a creature with no battle picture (the 3D twin of mn.Battle:drawCard: a 32x40
-- dark card with a white outline and the name in the battle window font, 4 letters per row).
-- The card is drawn the first time a slot needs it, which happens inside Presenter:render()
-- while the 3D shader, the depth canvas, depth testing and the 3D colour are all active. Those
-- must be switched off here, or the text and outline are drawn through the 3D matrices and the
-- card comes out blank. `g` is love.graphics (a stub in tests); `font` is mn.Font.
local C = {}

C.W, C.H = 32, 40
local WIN = { [0] = { 0, 0, 0 }, { 0.4, 0.4, 0.4 }, { 0.75, 0.75, 0.75 }, { 1, 1, 1 } } -- white on black

function C.draw(g, font, canvas, name)
  name = name or "?"
  local prev = g.getCanvas()
  g.push("all")
  g.setShader()            -- the 3D shader would project the 2D text off the card
  g.setDepthMode()         -- this canvas has no depth buffer
  g.origin()
  g.setBlendMode("alpha")
  g.setCanvas(canvas)
  g.clear(0.1, 0.1, 0.1, 1)
  g.setColor(1, 1, 1, 1)
  g.rectangle("line", 0.5, 0.5, C.W - 1, C.H - 1)
  font.drawText(name:sub(1, 4), 0, 8, WIN); font.drawText(name:sub(5, 8), 0, 16, WIN)
  g.pop()
  g.setCanvas(prev)
  return canvas
end

return C
