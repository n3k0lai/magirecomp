-- Title boot. reset.asm stores the script bank $22, pointer $418E and handler
-- $0A66 after SetupDefaultState (default_state.asm) and LoadSave
-- (check_save_signature.asm). FinishStartup (finish_startup.asm, the
-- ContinueStartup jump at $2158) clears $CCA5, writes the quad records, and
-- runs that script. 22:418E is EnterScriptFromLookup into 2A:7247 ($86).
-- 2A:734B polls Start: lookup index 0 on $C932 bit 3 (read_joypad.asm,
-- wButtonsPressed). A set bit takes 2A:735B, which loads map 216 and lets
-- 2A:7368 split on $A017.
--
-- A valid slot file is installed the way Continue does, and the saved script
-- triple is left for the title script ($89 / $8A). It is not dispatched here.
local MnRom = require("mn.MnRom")
local SaveFile = require("mn.SaveFile")
local Save = require("mn.ops.Save")

local M = {}

M.BANK = 0x22
M.PTR = 0x418E
-- Flat offset of the $43 at Script_2A_734B.
M.POLL = MnRom.off(0x734B, 0x2A)

-- Bytes SetupDefaultState and the pre-script half of FinishStartup store.
-- The WRAM fill under the stack is not copied: a missing ScriptVM byte reads
-- as 0, which is that fill. LCD, OAM, VRAM and the timer are not represented.
-- InitQuadRecords ($28A9) writes 00 00 02 14 at $C70E and $C71C and clears
-- the rendezvous bytes; FinishStartup repeats the pattern at $C715.
local DEFAULTS = {
  { 0xC6DE, 0xFF },
  { 0xC6E6, 0x00 },
  { 0xC6E4, 0xA4 }, { 0xC6E5, 0x29 }, -- IdleCallback $29A4
  { 0xC6E2, 0x49 }, { 0xC6E3, 0x2A }, -- DefaultVBlank $2A49
  { 0xFF99, 0xB7 }, { 0xFF9A, 0x2A }, -- EmptyStatHandler $2AB7
  { 0xC728, 0x00 }, { 0xC729, 0x00 },
  { 0xC931, 0x00 }, { 0xC932, 0x00 }, { 0xC933, 0x00 },
  { 0xC9C5, 0x00 }, { 0xC9C6, 0x00 },
  { 0xC9FF, 0x22 }, { 0xCA00, 0x06 }, { 0xCA01, 0x40 },
  { 0xC937, 0x00 }, { 0xC938, 0x00 },
  { 0xC188, 0x00 }, { 0xC6D8, 0x00 },
  { 0xCCA5, 0x00 }, { 0xCCA6, 0x00 },
  { 0xC6F3, 0x00 }, { 0xC6EF, 0x03 },
  { 0xFFAA, 0x03 }, { 0xFFAB, 0x03 },
  { 0xC70E, 0x00 }, { 0xC70F, 0x00 }, { 0xC710, 0x02 }, { 0xC711, 0x14 },
  { 0xC715, 0x00 }, { 0xC716, 0x00 }, { 0xC717, 0x02 }, { 0xC718, 0x14 },
  { 0xC71C, 0x00 }, { 0xC71D, 0x00 }, { 0xC71E, 0x02 }, { 0xC71F, 0x14 },
  { 0xC6F5, 0x00 }, { 0xC6F6, 0x00 }, { 0xC6F7, 0x00 },
  { 0xC6F8, 0x00 }, { 0xC6FA, 0x00 }, { 0xC6FC, 0x00 },
}

function M.defaults()
  local out = {}
  for i, pair in ipairs(DEFAULTS) do out[i] = { pair[1], pair[2] } end
  return out
end

function M.applyDefaults(vm)
  for _, pair in ipairs(DEFAULTS) do vm:wr8(pair[1], pair[2]) end
end

-- "title" runs 22:418E. "continue" is today's keyboard Continue call, which
-- MN_NEWGAME makes a no-op. nil leaves MN_LOAD / MN_BATTLE_TEST / plain
-- --mn-test alone. MN_TITLE=1 wins over MN_NEWGAME and over --mn-test.
function M.choose(getenv, opts)
  opts = opts or {}
  local function on(name)
    local v = getenv(name)
    return v ~= nil and v ~= ""
  end
  if on("MN_LOAD") or on("MN_BATTLE_TEST") then return nil end
  if getenv("MN_TITLE") == "1" then return "title" end
  if opts.test then return nil end
  if getenv("MN_NEWGAME") == "1" then return "continue" end
  return "title"
end

-- check_save_signature.asm on bank 0, then mirror_accepted_save.asm.
-- false, "rejected" when the image is present but the stamp or flag fails.
-- false when there is nothing to install. Does not run $A012.
function M.installSave(vm, data)
  if type(data) ~= "string" or data == "" then return false end
  local banks = SaveFile.decode(data)
  if not banks then return false end
  local accepted, w = SaveFile.accept(banks, Save.romStamp(vm))
  if not accepted then return false, "rejected" end
  Save.install(vm, accepted, w)
  return true
end

-- The $43 at 2A:734B spins until [$C932] bit 3 is set, then falls into $46
-- back to itself. On hardware ReadJoypad runs from VBlank inside that spin.
-- One miss waits a frame so the attract loop stays alive. Start (bit 3)
-- returns without waiting and the opcode takes 2A:735B.
function M.attachPoll(vm, input)
  vm.pcs = vm.pcs or {}
  local raw = vm.rd8
  function vm:rd8(a)
    local co = coroutine.running()
    if a ~= 0xC932 or self.init or co ~= self.co or self.pcs[co] ~= M.POLL then
      return raw(self, a)
    end
    local function bit3()
      return input("start") and 0x08 or 0
    end
    local v = bit3()
    if v == 0 then
      coroutine.yield("wait", 1)
      v = bit3()
    end
    return v
  end
end

function M.start(ow, data)
  local vm = ow.vm
  M.applyDefaults(vm)
  local ok, why = M.installSave(vm, data)
  if ok then ow.log[#ow.log + 1] = "title save installed"
  elseif why == "rejected" then ow.log[#ow.log + 1] = "save rejected"
  else ow.log[#ow.log + 1] = "title no save" end
  M.attachPoll(vm, ow.input)
  ow:runScript(M.BANK, M.PTR, "title")
  return ok and true or false
end

return M
