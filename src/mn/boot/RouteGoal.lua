-- Route harness helpers for MN_ROUTE ">" chains (Boot.lua's far planner).
local M = {}

-- A text box or a bracelet kick ends a ">" goal's talk only once Tony stands on
-- that goal (farFace set, farPath used up). A scene's box on the way there (the
-- 249 18,5 pirate scene on the way to 27,3) must not end the goal unpressed.
function M.talkEndsGoal(ow)
  return (ow.textBox or ow.kickSeen) and ow.farFace and ow.farPath and #ow.farPath == 0 and true or false
end

return M
