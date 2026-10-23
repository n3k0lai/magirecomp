-- UnpackBytes (unpack_bytes.asm). A packed stream is a run of commands.
-- Bits 7 and 6 of the control byte pick the command. The low six bits are
-- a length. A short length of zero ends the stream ($00 or $80). A long
-- length is those six bits in the high byte and the next byte in the low
-- one. A long count of zero wraps through the decrement (65536).
--
--   00  copy that many following bytes
--   01  copy the 14-bit count of following bytes
--   10  repeat the next byte that many times
--   11  repeat the next byte for the 14-bit count
--
-- read(o) returns the byte at file offset o. emit(v) takes each output
-- byte. Returns the offset just past the terminating control byte.
local bit = require("bit")
local band, rshift, lshift = bit.band, bit.rshift, bit.lshift

local M = {}

-- 14-bit length: six bits already in n, next byte in the low eight.
local function len14(hi6, lo)
  return lshift(hi6, 8) + lo
end

function M.unpack(read, o, emit)
  while true do
    local c = read(o) or 0
    local kind, n = rshift(c, 6), band(c, 0x3F)
    if kind == 0 or kind == 2 then
      o = o + 1
      if n == 0 then return o end
      if kind == 0 then
        for _ = 1, n do emit(read(o) or 0); o = o + 1 end
      else
        local v = read(o) or 0
        o = o + 1
        for _ = 1, n do emit(v) end
      end
    else
      o = o + 1
      n = len14(n, read(o) or 0)
      o = o + 1
      if n == 0 then n = 65536 end
      if kind == 1 then
        for _ = 1, n do emit(read(o) or 0); o = o + 1 end
      else
        local v = read(o) or 0
        o = o + 1
        for _ = 1, n do emit(v) end
      end
    end
  end
end

return M
