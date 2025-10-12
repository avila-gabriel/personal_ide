vim.cmd("highlight clear")
vim.opt.background = "dark"
vim.g.colors_name = "custom_colorscheme"

local set = vim.api.nvim_set_hl

-- Base UI
set(0, "Normal", { fg = "#e0dfe0", bg = "#0f0a0f" })
set(0, "NormalFloat", { bg = "#151015", blend = 10 })
set(0, "FloatBorder", { fg = "#8f8f8f", bg = "#151015" })
set(0, "LineNr", { fg = "#555555" })
set(0, "CursorLineNr", { fg = "#ffaa55", bold = true })
set(0, "Visual", { bg = "#332233" })
set(0, "StatusLine", { fg = "#ffffff", bg = "#332a33" })
set(0, "StatusLineNC", { fg = "#aaaaaa", bg = "#1a151a" })
set(0, "Pmenu", { bg = "#1a101a", fg = "#e0dfe0", blend = 15 })
set(0, "PmenuSel", { bg = "#332233", fg = "#ffd580" })
set(0, "VertSplit", { fg = "#332233" })

-- Gleam captures
local function hex_to_rgb(h)
	h = h:gsub("#", "")
	return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
	local function clamp(x)
		return math.max(0, math.min(255, math.floor(x + 0.5)))
	end
	return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

local function blend(c1, c2, t)
	local r1, g1, b1 = hex_to_rgb(c1)
	local r2, g2, b2 = hex_to_rgb(c2)
	return rgb_to_hex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end

local function gradient(stops, n)
	if #stops == 1 then
		local out = {}
		for i = 1, n do
			out[i] = stops[1]
		end
		return out
	end
	if n == 1 then
		return { stops[1] }
	end
	local segments = #stops - 1
	local out = {}
	for i = 1, n do
		local pos = (i - 1) / (n - 1)
		local idx = math.min(math.floor(pos * segments) + 1, segments)
		local local_t
		if segments == 0 then
			idx, local_t = 1, 0
		else
			local seg_start = (idx - 1) / segments
			local seg_end = idx / segments
			local_t = (pos - seg_start) / (seg_end - seg_start)
		end
		out[i] = blend(stops[idx], stops[idx + 1], local_t)
	end
	return out
end

local function assign_domain(groups, styles, stops)
	local cols = gradient(stops, #groups)
	for i, grp in ipairs(groups) do
		local style = styles[grp] or {}
		local hl = {}
		for k, v in pairs(style) do
			hl[k] = v
		end
		hl.fg = cols[i]
		set(0, grp, hl)
	end
end
local domain1_groups = {
	"@keyword",
	"@keyword.conditional",
	"@keyword.function",
	"@operator",
}
local domain1_styles = {
	["@keyword"] = { bold = true },
	["@keyword.conditional"] = { bold = true },
	["@keyword.function"] = { bold = true },
	["@operator"] = {},
}

local domain2_groups = {
	"@type",
	"@constructor",
	"@type.builtin",
}
local domain2_styles = {
	["@type"] = { italic = true },
	["@constructor"] = { bold = true, nocombine = true },
	["@type.builtin"] = { bold = true },
}

local domain3_groups = {
	"@attribute",
	"@constant",
	"@constant.builtin",
	"@number",
	"@boolean",
}
local domain3_styles = {
	["@attribute"] = {},
	["@constant"] = {},
	["@constant.builtin"] = {},
	["@number"] = {},
	["@boolean"] = { italic = false, nocombine = true },
}

local domain4_groups = {
	"@function",
	"@parameter",
	"@label",
}
local domain4_styles = {
	["@function"] = { italic = true },
	["@parameter"] = {},
	["@label"] = { italic = true },
}

local domain5_groups = {
	"@string",
	"@spell",
}
local domain5_styles = {
	["@string"] = {},
	["@spell"] = { italic = true },
}

local domain6_groups = {
	"@punctuation.delimiter",
	"@punctuation.bracket",
	"@punctuation.special",
}
local domain6_styles = {
	["@punctuation.delimiter"] = {},
	["@punctuation.bracket"] = {},
	["@punctuation.special"] = {},
}

local vars_groups = {
	"@variable",          -- white
	"@function.call",     -- pink
	"@variable.member",   -- soft grey
	"@variable.parameter",-- lighter grey
	"@variable.builtin",  -- mid grey
	"@module",            -- darker grey
}

local vars_stops = {
	"#ffffff",
	"#ffb6d9", -- pink for function.call
	"#dbdbdb",
	"#c4c4c4",
	"#aeaeae",
	"#9c9c9c",
}

local vars_styles = {
	["@variable"] = { bold = true },
	["@variable.member"] = {},
	["@variable.parameter"] = { italic = true },
	["@variable.builtin"] = { nocombine = true },
	["@module"] = { italic = true, nocombine = true },
	["@function.call"] = { nocombine = true },
}

local domain_bases = {
	domain1 = { base = "#ff8858", range = 0.10 },
	domain2 = { base = "#a57df8", range = 0.08 },
	domain3 = { base = "#8a93ff", range = 0.2 },
	domain4 = { base = "#ff8ed0", range = 0.12 },
	domain5 = { base = "#53ffa4", range = 0.15 },
	domain6 = { base = "#f5e4ee", range = 0.05 },
}

local function vary_around(base, range, n)
	local r, g, b = hex_to_rgb(base)
	local colors = {}
	for i = 1, n do
		local t = (i - 1) / (math.max(n - 1, 1))
		local f = (t - 0.5) * 2 * range
		local r2 = r * (1 + f)
		local g2 = g * (1 + f)
		local b2 = b * (1 + f)
		colors[i] = rgb_to_hex(r2, g2, b2)
	end
	return colors
end

local ranges = {
	domain1 = vary_around(domain_bases.domain1.base, domain_bases.domain1.range, #domain1_groups),
	domain2 = vary_around(domain_bases.domain2.base, domain_bases.domain2.range, #domain2_groups),
	domain3 = vary_around(domain_bases.domain3.base, domain_bases.domain3.range, #domain3_groups),
	domain4 = vary_around(domain_bases.domain4.base, domain_bases.domain4.range, #domain4_groups),
	domain5 = vary_around(domain_bases.domain5.base, domain_bases.domain5.range, #domain5_groups),
	domain6 = vary_around(domain_bases.domain6.base, domain_bases.domain6.range, #domain6_groups),
}


assign_domain(domain1_groups, domain1_styles, ranges.domain1)
assign_domain(domain2_groups, domain2_styles, ranges.domain2)
assign_domain(domain3_groups, domain3_styles, ranges.domain3)
assign_domain(domain4_groups, domain4_styles, ranges.domain4)
assign_domain(domain5_groups, domain5_styles, ranges.domain5)
assign_domain(domain6_groups, domain6_styles, ranges.domain6)

for i, grp in ipairs(vars_groups) do
	local style = vars_styles[grp] or {}
	local hl = {}
	for k, v in pairs(style) do hl[k] = v end
	hl.fg = vars_stops[i]
	vim.api.nvim_set_hl(0, grp, hl)
end
