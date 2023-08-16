local PANEL = {}
local clamp = math.Clamp
local floor = math.floor
AccessorFunc(PANEL, "BaseColor", "BaseColor")
AccessorFunc(PANEL, "Alpha", "Alpha")

function PANEL:Init()
	self:SetBaseColor(Color(255, 0, 0))
	self:SetSize(PIXEL.Scale(26), PIXEL.Scale(26))
	self:SetAlpha(255)
	self.LastX = 0
end

function PANEL:OnCursorMoved(x, y)
	if not input.IsMouseDown(MOUSE_LEFT) then return end
	local wide = x / self:GetWide()
	local value = 1 - clamp(wide, 0, 1)
	self.LastX = floor(wide * self:GetWide())
	self:OnChange(floor(value * 255))
	self:SetAlpha(floor(value * 255))
end

function PANEL:OnMousePressed()
	self:MouseCapture(true)
	self:OnCursorMoved(self:CursorPos())
end

function PANEL:OnMouseReleased()
	self:MouseCapture(false)
	self:OnCursorMoved(self:CursorPos())
end

function PANEL:OnChange(alpha)
end

function PANEL:Paint(w, h)
	local x, y = self:LocalToScreen()
	local wh

	PIXEL.Mask(function()
		PIXEL.DrawFullRoundedBox(8, 0, 0, w, h, color_white)
	end, function()
		for i = 0, w / 2 do
			local x2 = i * h
			if x2 > w then break end
			PIXEL.DrawImgur(x2, 0, h, h, "ewL9tYn", color_white)
		end

		PIXEL.DrawSimpleLinearGradient(x, y, w, h, self:GetBaseColor(), Color(200, 200, 200, 0), true)
	end)

	local newX = self.LastX

	if newX < (h / 2) then
		newX = h / 2
	end

	if newX > w - (h / 2) then
		newX = w - (h / 2)
	end

	PIXEL.DrawFullRoundedBox(8, newX - (h / 2), 0, h, h, color_white)
	x, y, wh = newX + PIXEL.Scale(3), PIXEL.Scale(3), h - PIXEL.Scale(6)
	PIXEL.DrawFullRoundedBox(4, x - (h / 2), y, wh, wh, ColorAlpha(self:GetBaseColor(), self:GetAlpha()))
end

vgui.Register("PIXEL.AlphaBar", PANEL, "EditablePanel")