-- Battle event bus. mn.Battle:play computes each event's frame budget and emits it;
-- the 2D screen, the 3D presenter and test recorders subscribe. Pure Lua: no LÖVE,
-- no ROM. Subscribers must not yield or change how many frames play() waits.
local Bus = {}
Bus.__index = Bus

function Bus.new()
  return setmetatable({ subs = {} }, Bus)
end

-- fn(ev, frames) runs later, in the order on() was called
function Bus:on(fn)
  self.subs[#self.subs + 1] = fn
  return fn
end

function Bus:emit(ev, frames)
  for i = 1, #self.subs do self.subs[i](ev, frames) end
end

-- One row per emit, in order. `t` is the engine tag (ev.t); `kind` is ev.kind
-- when the event carries one, otherwise the same tag. `frames` is the budget.
function Bus.recorder(into)
  return function(ev, frames)
    into[#into + 1] = { t = ev.t, kind = ev.kind or ev.t, slot = ev.slot, frames = frames }
  end
end

return Bus
