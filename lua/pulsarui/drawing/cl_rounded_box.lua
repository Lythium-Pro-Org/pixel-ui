local corners = {}

do
	local stupid_corners = {
		tex_corner8 = "gui/corner8",
		tex_corner16 = "gui/corner16",
		tex_corner32 = "gui/corner32",
		tex_corner64 = "gui/corner64",
		tex_corner512 = "gui/corner512"
	}

	for k, v in next, stupid_corners do
		corners[k] = CreateMaterial("better_" .. v:gsub("gui/", ""), "UnlitGeneric", {
			["$basetexture"] = v,
			["$alphatest"] = 1,
			["$alphatestreference"] = 0.5,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1
		})
	end
end

local round = math.Round
local min = math.min
local floor = math.floor
local setDrawColor = surface.SetDrawColor
local drawRect = surface.DrawRect
local drawTexturedRectUV = surface.DrawTexturedRectUV
local setTexture = surface.SetTexture
local setMaterial = surface.SetMaterial

function PulsarUI.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
	setDrawColor(col.r, col.g, col.b, col.a)

	if borderSize <= 0 then
		drawRect(x, y, w, h)

		return
	end

	x, y, w, h = round(x), round(y), round(w), round(h)
	borderSize = min(round(borderSize), floor(w / 2))

	local xAfterBorder, yAfterBorder = x + borderSize, y + borderSize
	local doubleHeightWithoutBorder = h - borderSize * 2
	local xPlusWidthWithoutBorder, yPlusHeightWithoutBorder = x + w - borderSize, y + h - borderSize

	drawRect(xAfterBorder, y, w - borderSize * 2, h)
	drawRect(x, yAfterBorder, borderSize, doubleHeightWithoutBorder)
	drawRect(xPlusWidthWithoutBorder, yAfterBorder, borderSize, doubleHeightWithoutBorder)

	local material = corners.tex_corner8
	if borderSize > 8 then material = corners.tex_corner16 end
	if borderSize > 16 then material = corners.tex_corner32 end
	if borderSize > 32 then material = corners.tex_corner64 end
	if borderSize > 64 then material = corners.tex_corner512 end

	setMaterial(material)

	if topLeft then
		drawTexturedRectUV(x, y, borderSize, borderSize, 0, 0, 1, 1)
	else
		drawRect(x, y, borderSize, borderSize)
	end

	if topRight then
		drawTexturedRectUV(xPlusWidthWithoutBorder, y, borderSize, borderSize, 1, 0, 0, 1)
	else
		drawRect(xPlusWidthWithoutBorder, y, borderSize, borderSize)
	end

	if bottomLeft then
		drawTexturedRectUV(x, yPlusHeightWithoutBorder, borderSize, borderSize, 0, 1, 1, 0)
	else
		drawRect(x, yPlusHeightWithoutBorder, borderSize, borderSize)
	end

	if bottomRight then
		drawTexturedRectUV(xPlusWidthWithoutBorder, yPlusHeightWithoutBorder, borderSize, borderSize, 1, 1, 0, 0)
	else
		drawRect(xPlusWidthWithoutBorder, yPlusHeightWithoutBorder, borderSize, borderSize)
	end
end

local drawRoundedBoxEx = PulsarUI.DrawRoundedBoxEx

function PulsarUI.DrawRoundedBox(borderSize, x, y, w, h, col)
	return drawRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end

local roundedBoxCache = {}
local whiteTexture = surface.GetTextureID("vgui/white")

local drawPoly = surface.DrawPoly

function PulsarUI.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, tl, tr, bl, br)
	setDrawColor(col.r, col.g, col.b, col.a)

	if borderSize <= 0 then
		drawRect(x, y, w, h)
		return
	end

	local fullRight = x + w
	local fullBottom = y + h

	local left, right = x + borderSize, fullRight - borderSize
	local top, bottom = y + borderSize, fullBottom - borderSize

	local halfBorder = borderSize * .7

	local cacheName = borderSize .. x .. y .. w .. h
	local cache = roundedBoxCache[cacheName]
	if not cache then
		cache = {
			{x = right, y = y}, --Top Right
			{x = right + halfBorder, y = top - halfBorder},
			{x = fullRight, y = top},

			{x = fullRight, y = bottom}, --Bottom Right
			{x = right + halfBorder, y = bottom + halfBorder},
			{x = right, y = fullBottom},

			{x = left, y = fullBottom}, --Bottom Left
			{x = left - halfBorder, y = bottom + halfBorder},
			{x = x, y = bottom},

			{x = x, y = top}, --Top Left
			{x = left - halfBorder, y = top - halfBorder},
			{x = left, y = y}
		}

		roundedBoxCache[cacheName] = cache
	end

	setTexture(whiteTexture)
	drawPoly(cache)

	if not tl then drawRect(x, y, borderSize, borderSize) end
	if not tr then drawRect(x + w - borderSize, y, borderSize, borderSize) end
	if not bl then drawRect(x, y + h - borderSize, borderSize, borderSize) end
	if not br then drawRect(x + w - borderSize, y + h - borderSize, borderSize, borderSize) end
end

function PulsarUI.DrawFullRoundedBox(borderSize, x, y, w, h, col)
	return PulsarUI.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end