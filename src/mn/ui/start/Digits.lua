-- format_start_digits.asm ($041A). Low 10 bits of DE, three decimal digits.
-- Hundreds is not reduced past 9, so 1000-1023 leave 10 there.
local bit = require("bit")

local M = {}

function M.format(d, e)
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

return M
