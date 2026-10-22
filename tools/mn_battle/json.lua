-- Minimal JSON decoder for the oracle traces (objects, arrays, strings, numbers, bools, null).
local M = {}

function M.decode(str)
  local pos = 1
  local function ws() pos = str:find("[^ \t\r\n]", pos) or #str + 1 end
  local value
  local function strv()
    local out, i = {}, pos + 1
    while true do
      local c = str:sub(i, i)
      if c == '"' then pos = i + 1; return table.concat(out) end
      if c == "\\" then
        local n = str:sub(i + 1, i + 1)
        if n == "u" then out[#out + 1] = string.char(tonumber(str:sub(i + 2, i + 5), 16) % 256); i = i + 6
        else out[#out + 1] = ({ n = "\n", t = "\t", r = "\r", b = "\b", f = "\f" })[n] or n; i = i + 2 end
      elseif c == "" then error("unterminated string")
      else
        local j = str:find('["\\]', i)
        out[#out + 1] = str:sub(i, j - 1); i = j
      end
    end
  end
  function value()
    ws()
    local c = str:sub(pos, pos)
    if c == "{" then
      local t = {}; pos = pos + 1; ws()
      if str:sub(pos, pos) == "}" then pos = pos + 1; return t end
      while true do
        ws(); local k = strv(); ws(); pos = pos + 1 -- ':'
        t[k] = value(); ws()
        local d = str:sub(pos, pos); pos = pos + 1
        if d == "}" then return t end
      end
    elseif c == "[" then
      local t = {}; pos = pos + 1; ws()
      if str:sub(pos, pos) == "]" then pos = pos + 1; return t end
      while true do
        t[#t + 1] = value(); ws()
        local d = str:sub(pos, pos); pos = pos + 1
        if d == "]" then return t end
      end
    elseif c == '"' then return strv()
    elseif str:sub(pos, pos + 3) == "true" then pos = pos + 4; return true
    elseif str:sub(pos, pos + 4) == "false" then pos = pos + 5; return false
    elseif str:sub(pos, pos + 3) == "null" then pos = pos + 4; return nil
    else
      local n = str:match("^-?[%d%.eE+-]+", pos)
      pos = pos + #n
      return tonumber(n)
    end
  end
  return value()
end

return M
