local PANEL = {}
local clamp = math.Clamp
local floor = math.floor
AccessorFunc(PANEL, "BaseColor", "BaseColor")
AccessorFunc(PANEL, "Alpha", "Alpha")

function PANEL:Init()
	self:SetBaseColor(Color(255, 0, 0))
	self:SetSize(PulsarUI.Scale(26), PulsarUI.Scale(26))
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


	PulsarUI.DrawSimpleLinearGradient(x, y, w, h, self:GetBaseColor(), Color(200, 200, 200, 0), true)

	local newX = self.LastX

	if newX < (h / 2) then
		newX = h / 2
	end

	if newX > w - (h / 2) then
		newX = w - (h / 2)
	end

	PulsarUI.DrawFullRoundedBox(8, newX - (h / 2), 0, h, h, color_white)
	x, y, wh = newX + PulsarUI.Scale(3), PulsarUI.Scale(3), h - PulsarUI.Scale(6)
	PulsarUI.DrawFullRoundedBox(4, x - (h / 2), y, wh, wh, ColorAlpha(self:GetBaseColor(), self:GetAlpha()))
end

vgui.Register("PulsarUI.AlphaBar", PANEL, "EditablePanel")