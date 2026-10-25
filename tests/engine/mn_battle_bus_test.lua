-- Battle event bus: subscribers see one stream, in subscription order, with the
-- frame budget the emitter passed. No LÖVE and no ROM.
--   luajit tests/engine/mn_battle_bus_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
local Bus = require("mn.battle.Bus")

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local function same(a, b)
  return a.t == b.t and a.kind == b.kind and a.slot == b.slot and a.frames == b.frames
end

-- no subscribers: emit returns
do
  local bus = Bus.new()
  bus:emit({ t = "end" }, 0)
  bus:emit({ t = "damage", slot = 1 }, 16)
  ok(true, "unsubscribed bus emit is a no-op")
end

-- two recorders see the same rows, including frame budgets, in emit order
do
  local bus = Bus.new()
  local a, b, order = {}, {}, {}
  bus:on(function(ev, frames)
    order[#order + 1] = "a"
    Bus.recorder(a)(ev, frames)
  end)
  bus:on(function(ev, frames)
    order[#order + 1] = "b"
    Bus.recorder(b)(ev, frames)
  end)
  local evs = {
    { t = "act", kind = "act", slot = 1 },
    { t = "anim", kind = "anim", slot = 1 },
    { t = "damage", kind = "damage", slot = 5 },
    { t = "summon", kind = "summon", slot = 2 },
    { t = "eliminated", kind = "eliminated", slot = 5 },
    { t = "msg", kind = "msg" },
  }
  local budgets = { 0, 0, 16, 8, 121, 0 }
  for i, ev in ipairs(evs) do bus:emit(ev, budgets[i]) end
  ok(#a == #evs and #b == #evs, "both recorders saw every event")
  local match = true
  for i, row in ipairs(a) do
    if not same(row, b[i]) then match = false end
    if row.t ~= evs[i].t or row.kind ~= evs[i].kind or row.slot ~= evs[i].slot or row.frames ~= budgets[i] then
      match = false
    end
  end
  ok(match, "recorders agree on t, kind, slot and frame budget")
  local ord = true
  for i = 1, #evs do
    if order[i * 2 - 1] ~= "a" or order[i * 2] ~= "b" then ord = false end
  end
  ok(ord, "subscribers run in subscription order")
  local c = {}
  local other = Bus.new()
  other:on(Bus.recorder(c))
  ok(#c == 0, "a new bus starts empty")
end

-- kind defaults to the engine tag when the event has none
do
  local rows = {}
  local bus = Bus.new()
  bus:on(Bus.recorder(rows))
  bus:emit({ t = "appear", slot = 3 }, 0)
  ok(rows[1].t == "appear" and rows[1].kind == "appear" and rows[1].slot == 3 and rows[1].frames == 0,
    "recorder fills kind from ev.t")
end

print(("mn_battle_bus_test: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
