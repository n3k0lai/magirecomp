-- Starting state for the battle-scene generator: the machine as the CGB boot ROM hands over at
-- $0100 (fixed register/IO/PPU/timer values, no cartridge data), and the save the Glade battle
-- reads, built by running the game's own new-file and creature-template routines.
local band, rshift = bit.band, bit.rshift
local S = {}

S.BOOT = {
  A = 0x11, F = 0x80, B = 0x00, C = 0x00, D = 0x00, E = 0x08, HL = 0x007C, SP = 0xFFFE, PC = 0x0100,
  IF = 0x01, IE = 0x00, cycles = 4507420,
  LCDC = 0x91, STAT = 0x81, LY = 145, BGP = 0xFC, OBP0 = 0xFF, OBP1 = 0xFF,
  clock = 66292, ctarget = 66576, nextmode = 1,
  DIV = 0xC71C, SB = 0xFF, SC = 0x7C, HRAM_FFFC = 0xB0,
  -- per-line SCX the boot ROM's logo animation leaves behind; PyBoy reports it for lines the
  -- first frame after the game turns the LCD on has not drawn yet
  SCXLINES = { [97] = 1, [98] = 2, [99] = 2, [100] = 3, [101] = 3, [102] = 3, [103] = 2, [104] = 1, [105] = 1, [106] = 1 },
}

function S.boot(m)
  local b = S.BOOT
  m.env.setregs({ A = b.A, B = b.B, C = b.C, D = b.D, E = b.E, H = rshift(b.HL, 8), L = band(b.HL, 0xFF), SP = b.SP,
    FZ = band(b.F, 0x80) ~= 0, FN = band(b.F, 0x40) ~= 0, FH = band(b.F, 0x20) ~= 0, FC = band(b.F, 0x10) ~= 0 })
  m.PC = b.PC; m.IME = false; m.IE = b.IE; m.IF = b.IF; m.env.cy(b.cycles)
  m.LCDC, m.STAT, m.LY, m.BGP, m.OBP0, m.OBP1 = b.LCDC, b.STAT, b.LY, b.BGP, b.OBP0, b.OBP1
  m.mode = band(b.STAT, 3); m.irqline = false; m:irqupdate()
  m.llast, m.clock, m.ctarget, m.nextmode, m.strans = b.cycles, b.clock, b.ctarget, b.nextmode, 0
  m.lcti = m.ctarget - m.clock; m.lctf = 70224 - m.clock
  m.DIVc, m.tlast = b.DIV, b.cycles
  m.hram[0x7C] = b.HRAM_FFFC
  m.SB, m.SC, m.P1 = b.SB, b.SC, 0
  for y, v in pairs(b.SCXLINES) do m.scan[y][1] = v end
  m.frames = 64
end

-- the save fields the battle reads, as a new file plus Furok in the party
function S.sram(Cgb, rom, blocks, o)
  o = o or {}
  local m = Cgb.new(rom, blocks); S.boot(m)
  -- the game's own start-up code up to its first script dispatch
  m.stopAt = 0x0A66; m.stopped = false
  while not m.stopped do m:step() end
  m.stopAt = nil
  m.IME = false; m.halted = false; m.eidelay = 0
  local function rombank(b) m:write(0xFFA1, b); m:write(0xC938, b) end
  rombank(1); m:call(1, 0x466D) -- FillSRAMAfterZeroScriptByte: the new-file fills and Tony's record
  m:write(0xFF70, 7) -- the battle-side WRAM bank the routine works in
  m:write(0xD068, o.species or 0x1C); m:write(0xD069, o.spends or 1); m:write(0xD06A, o.energy or 23); m:write(0xD103, 0)
  rombank(2); m:call(2, 0x4653) -- FillD110FromIndexedEntry: a creature from its template
  local bank = m:R(0xC727, m.env.cy(), 0)
  local rec = {}
  for k = 0, 0x24 do rec[k] = m:R(0xD112 + k, m.env.cy(), 0) end
  rec[5], rec[6] = rec[7], rec[8] -- saved energy = max
  local sram = {}
  for b = 0, 3 do sram[b] = {} for i = 0, 0x1FFF do sram[b][i] = m.sram[b][i] end end
  for k = 0, 0x24 do sram[bank + 1][0x25 + k] = rec[k] end
  sram[bank][0x118] = 1 -- creature list: record 1
  local an = o.animite or 50
  sram[bank][0x3A5] = band(an, 0xFF); sram[bank][0x3A6] = rshift(an, 8)
  return sram, bank
end
return S
