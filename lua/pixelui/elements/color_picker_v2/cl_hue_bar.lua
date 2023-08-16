local PANEL = {}
local floor = math.floor
local clamp = math.Clamp
local scale = PIXEL.Scale
AccessorFunc(PANEL, "Hue", "Hue", FORCE_NUMBER)
AccessorFunc(PANEL, "Saturation", "Saturation", FORCE_NUMBER)
AccessorFunc(PANEL, "Luminosity", "Luminosity", FORCE_NUMBER)

function PANEL:SetHue(value)
    self.Hue = clamp(value, 0, 360)
    self.LastX = (value / 360) * self:GetWide()
end

function PANEL:Init()
    self:SetHue(0)
    self:SetSaturation(1)
    self:SetLuminosity(.5)
    self.LastX = 0
    self.Steps = {}
end

function PANEL:PerformLayout(w, h)
    self.Steps = {}
    self.Times = 360 -- The max number that the hue can be

    for i = 0, self.Times do
        local step = (1 / self.Times) * i
        local color = HSLToColor(i, self:GetSaturation(), self:GetLuminosity())

        self.Steps[i] = {
            offset = step,
            color = color
        }
    end

    self.LastX = (self:GetHue() / 360) * self:GetWide()
end

function PANEL:GetColor()
    local h = self:GetHue() or 0
    local s = self:GetSaturation() or 1
    local l = self:GetLuminosity() or 0.5

    return HSLToColor(h, s, l)
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    local wide = x / self:GetWide()
    local hue = clamp(wide, 0, 1)
    hue = floor(hue * self.Times)
    self:SetHue(hue)
    local col = self:GetColor(hue)

    if col then
        self:OnChange(self:GetHue())
    end

    self.LastX = x
end

function PANEL:OnChange(hue)
end

function PANEL:OnMousePressed()
    self:MouseCapture(true)
    self:OnCursorMoved(self:CursorPos())
end

function PANEL:OnMouseReleased()
    self:MouseCapture(false)
    self:OnCursorMoved(self:CursorPos())
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen()
    local wh

    PIXEL.Mask(function()
        PIXEL.DrawFullRoundedBox(8, 0, 0, w, h, color_white)
    end, function()
        PIXEL.DrawLinearGradient(x, y, w, h, self.Steps, true)
    end)

    local newX = self.LastX

    if newX < (h / 2) then
        newX = h / 2
    end

    if newX > w - (h / 2) then
        newX = w - (h / 2)
    end

    PIXEL.DrawFullRoundedBox(8, newX - (h / 2), 0, h, h, color_white)
    x, y, wh = newX + scale(3), scale(3), h - scale(6)
    PIXEL.DrawFullRoundedBox(4, x - (h / 2), y, wh, wh, self:GetColor())
end

vgui.Register("PIXEL.HueBar", PANEL, "EditablePanel")