local M = {}

local function hex_to_rgb(h)
  h = h:gsub("#", "")
  return tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16)
end

local function rgb_to_hex(r,g,b)
  local function clamp(x) return math.max(0, math.min(255, math.floor(x+0.5))) end
  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

local function blend(c1, c2, t)
  local r1,g1,b1 = hex_to_rgb(c1)
  local r2,g2,b2 = hex_to_rgb(c2)
  return rgb_to_hex(r1+(r2-r1)*t, g1+(g2-g1)*t, b1+(b2-b1)*t)
end

function M.gradient(stops, n)
  if #stops == 1 then return vim.tbl_map(function() return stops[1] end, vim.fn.range(n)) end
  local out, segs = {}, #stops - 1
  for i=1,n do
    local pos = (i-1)/(n-1)
    local idx = math.min(math.floor(pos*segs)+1, segs)
    local seg_start, seg_end = (idx-1)/segs, idx/segs
    local t = (pos - seg_start) / (seg_end - seg_start)
    out[i] = blend(stops[idx], stops[idx+1], t)
  end
  return out
end

return M
