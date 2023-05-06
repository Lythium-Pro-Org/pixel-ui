local PANEL = {}
local clamp = math.Clamp
local floor = math.floor
AccessorFunc(PANEL, "Value", "Value")
AccessorFunc(PANEL, "Alpha", "Alpha")
AccessorFunc(PANEL, "BarColor", "BarColor")

function PANEL:Init()
    self:SetBarColor(color_white)
    self:SetSize(PIXEL.Scale(26), PIXEL.Scale(26))
    self:SetValue(1)
    self:SetAlpha(255)
    self.LastX = 0
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end

    local wide = x / self:GetWide()
    local value = 1 - clamp(wide, 0, 1)

    self.LastX = floor(wide * self:GetWide())

    self:SetValue(value)
    self:OnChange(value)
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
        PIXEL.DrawSimpleLinearGradient(x, y, w, h, self:GetBarColor(), Color(200, 200, 200, 0), true)
    end)

    local newX = self.LastX

    if newX < (h / 2) then
        newX = (h / 2)
    end

    if newX > w - (h / 2) then
        newX = w - (h / 2)
    end


    PIXEL.DrawFullRoundedBox(8, newX - (h / 2), 0, h, h, color_white)
    x, y, wh = newX + PIXEL.Scale(3), PIXEL.Scale(3), h - PIXEL.Scale(6)
    local barColor = self:GetBarColor()
    local r, g, b, a = barColor.r, barColor.g, barColor.b, self:GetAlpha()
    PIXEL.DrawFullRoundedBox(4, x - (h / 2), y, wh, wh, Color(r, g, b, a))
end

vgui.Register("PIXEL.AlphaBar", PANEL, "EditablePanel")