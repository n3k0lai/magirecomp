-- SRAM save image. Magi-Nation keeps one save in four 8 KiB SRAM banks.
-- Banks 0 and 1 are one copy; banks 2 and 3 are the mirror. check_save_signature.asm
-- accepts the image only when bank 0's flag at $A000 is 0 or 2 and the sixteen
-- bytes at $A002 match the ROM stamp (bank 7 $4000, the bank mapped for that
-- check), with those same bytes reversed at $BFF0. mirror_accepted_save.asm
-- then copies the pair named by the flag onto the other pair. A file here is
-- those four banks, in order, and nothing else. love.filesystem is passed in
-- so tests can stub it.
local bit = require("bit")

local M = {}

M.BANK_SIZE = 0x2000
M.BANK_COUNT = 4
M.BASE = 0xA000
M.STAMP_ADDR = 0xA002
M.STAMP_LEN = 16
M.STAMP_TAIL = 0xBFF0
M.FLAG_ADDR = 0xA000
M.FLAG_BACKUP = 2
-- store_save_stamp.asm writes these just past the forward stamp on a wipe.
M.WIPE_MARK = string.char(0x22, 0x8E, 0x41)
M.WIPE_MARK_ADDR = 0xA012
M.PATH = "mn_save/slot1.sav"

local ZERO = string.rep("\0", M.BANK_SIZE)

local function idx(addr)
  return addr - M.BASE + 1
end

function M.poke(bank, addr, val)
  local i = idx(addr)
  return bank:sub(1, i - 1) .. string.char(bit.band(val, 0xFF)) .. bank:sub(i + 1)
end

function M.peek(bank, addr)
  return bank:byte(idx(addr)) or 0
end

-- Forward stamp at $A002 and the reversed stamp at $BFF0 (store_save_stamp.asm).
function M.writeStamp(bank, stamp)
  local i = idx(M.STAMP_ADDR)
  bank = bank:sub(1, i - 1) .. stamp .. bank:sub(i + M.STAMP_LEN)
  local j = idx(M.STAMP_TAIL)
  return bank:sub(1, j - 1) .. stamp:reverse() .. bank:sub(j + M.STAMP_LEN)
end

function M.stampOk(bank, stamp)
  if type(stamp) ~= "string" or #stamp ~= M.STAMP_LEN then return false end
  if not bank or #bank ~= M.BANK_SIZE then return false end
  local i = idx(M.STAMP_ADDR)
  if bank:sub(i, i + M.STAMP_LEN - 1) ~= stamp then return false end
  local j = idx(M.STAMP_TAIL)
  return bank:sub(j, j + M.STAMP_LEN - 1) == stamp:reverse()
end

-- wipe_save_banks.asm: four banks of $00, stamp on banks 0 and 2, active bank 2.
function M.wipe(stamp)
  local marked = M.writeStamp(ZERO, stamp)
  local k = idx(M.WIPE_MARK_ADDR)
  marked = marked:sub(1, k - 1) .. M.WIPE_MARK .. marked:sub(k + #M.WIPE_MARK)
  return { [0] = marked, [1] = ZERO, [2] = marked, [3] = ZERO }, 2
end

-- mirror_accepted_save.asm. Returns the four banks and the new active bank,
-- or nil when the flag is neither 0 nor 2.
function M.mirror(banks)
  local flag = banks[0]:byte(1) or 0
  if flag ~= 0 and flag ~= M.FLAG_BACKUP then return nil, "flag" end
  local b = { [0] = banks[0], [1] = banks[1], [2] = banks[2], [3] = banks[3] }
  b[2] = M.poke(b[2], M.FLAG_ADDR, flag)
  local src = flag
  local dst = bit.bxor(flag, M.FLAG_BACKUP)
  b[dst] = b[src]
  b[dst + 1] = b[src + 1]
  return b, dst
end

-- check_save_signature.asm on bank 0, then the mirror. nil, reason on failure.
function M.accept(banks, stamp)
  if not banks or not banks[0] then return nil, "size" end
  local flag = banks[0]:byte(1) or 0
  if flag ~= 0 and flag ~= M.FLAG_BACKUP then return nil, "flag" end
  if not M.stampOk(banks[0], stamp) then return nil, "stamp" end
  return M.mirror(banks)
end

-- StoreSramBankFlagThenMirror: bank 0's flag becomes the active bank, then mirror.
function M.commit(banks, live, w)
  w = w or 2
  if w ~= 0 and w ~= M.FLAG_BACKUP then return nil, "flag" end
  local b = {}
  for i = 0, 3 do b[i] = banks[i] or ZERO end
  b[w] = live
  b[0] = M.poke(b[0], M.FLAG_ADDR, w)
  return M.mirror(b)
end

function M.encode(banks)
  local p = {}
  for i = 0, 3 do p[i + 1] = banks[i] or ZERO end
  return table.concat(p)
end

function M.decode(data)
  if type(data) ~= "string" or #data ~= M.BANK_SIZE * M.BANK_COUNT then return nil, "size" end
  local banks = {}
  for i = 0, 3 do
    local a = i * M.BANK_SIZE
    banks[i] = data:sub(a + 1, a + M.BANK_SIZE)
  end
  return banks
end

function M.writeFile(fs, path, banks)
  path = path or M.PATH
  if fs.createDirectory then fs.createDirectory("mn_save") end
  return fs.write(path, M.encode(banks))
end

function M.readFile(fs, path)
  path = path or M.PATH
  local data = fs.read(path)
  if not data then return nil, "missing" end
  return M.decode(data)
end

return M
