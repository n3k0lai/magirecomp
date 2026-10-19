-- Headless: love tools/mn_slice <rom> <mapIndex|all> <outdir>
package.path = "../../src/?.lua;" .. (love.filesystem.getSource() .. "/../../src/?.lua;") .. package.path
local MnRom = require("mn.MnRom")
function love.load(args)
  local rom = MnRom.fromFile(args[1]); local which = args[2] or "0"; local out = args[3] or "."
  local list = {}
  if which == "all" then for i = 0, MnRom.MAP_COUNT - 1 do list[#list + 1] = i end
  else list[1] = tonumber(which) end
  for _, i in ipairs(list) do
    local ok, err = pcall(function()
      local m = rom:loadMap(i)
      local img = love.image.newImageData(m.map.w * 16, m.map.h * 16)
      MnRom.render(m, function(x, y, r, g, b) img:setPixel(x, y, r, g, b, 1) end)
      local f = assert(io.open(string.format("%s/map%03d.png", out, i), "wb"))
      f:write(img:encode("png"):getString()); f:close()
      print(string.format("map %03d %dx%d meta ok", i, m.map.w, m.map.h))
    end)
    if not ok then print("map " .. i .. " FAIL " .. tostring(err)) end
  end
  love.event.quit(0)
end
