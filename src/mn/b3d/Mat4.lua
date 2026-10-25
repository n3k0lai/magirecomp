-- Small 4x4 matrix helpers for the 3D battle presentation (row-major flat tables of 16,
-- sent to LÖVE shaders with the default "row" layout). Pure Lua: no LÖVE needed, so the
-- math is unit-tested headless (tests/engine/mn_b3d_test.lua).
local M = {}

function M.identity() return { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 } end

function M.mul(a, b)
  local r = {}
  for i = 0, 3 do for j = 0, 3 do
    local s = 0
    for k = 0, 3 do s = s + a[i * 4 + k + 1] * b[k * 4 + j + 1] end
    r[i * 4 + j + 1] = s
  end end
  return r
end

function M.translate(x, y, z) return { 1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1 } end
function M.scale(x, y, z) return { x, 0, 0, 0, 0, y or x, 0, 0, 0, 0, z or x, 0, 0, 0, 0, 1 } end
function M.rotY(a)
  local c, s = math.cos(a), math.sin(a)
  return { c, 0, s, 0, 0, 1, 0, 0, -s, 0, c, 0, 0, 0, 0, 1 }
end

-- OpenGL-style perspective (fovy radians, aspect w/h), depth -1..1
function M.perspective(fovy, aspect, near, far)
  local f = 1 / math.tan(fovy / 2)
  return { f / aspect, 0, 0, 0, 0, f, 0, 0, 0, 0, (far + near) / (near - far), 2 * far * near / (near - far), 0, 0, -1, 0 }
end

local function sub(a, b) return { a[1] - b[1], a[2] - b[2], a[3] - b[3] } end
local function cross(a, b) return { a[2] * b[3] - a[3] * b[2], a[3] * b[1] - a[1] * b[3], a[1] * b[2] - a[2] * b[1] } end
local function norm(a) local l = math.sqrt(a[1] ^ 2 + a[2] ^ 2 + a[3] ^ 2); return { a[1] / l, a[2] / l, a[3] / l } end
local function dot(a, b) return a[1] * b[1] + a[2] * b[2] + a[3] * b[3] end

function M.lookAt(eye, at, up)
  local f = norm(sub(at, eye))
  local s = norm(cross(f, up or { 0, 1, 0 }))
  local u = cross(s, f)
  return { s[1], s[2], s[3], -dot(s, eye), u[1], u[2], u[3], -dot(u, eye), -f[1], -f[2], -f[3], dot(f, eye), 0, 0, 0, 1 }
end

-- m * {x, y, z, 1}
function M.apply(m, v)
  local x, y, z = v[1], v[2], v[3]
  local r = {}
  for i = 0, 3 do r[i + 1] = m[i * 4 + 1] * x + m[i * 4 + 2] * y + m[i * 4 + 3] * z + m[i * 4 + 4] end
  return r
end

return M
