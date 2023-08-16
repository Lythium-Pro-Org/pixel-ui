local PANEL = {}
local clamp = math.Clamp
local scale = PIXEL.Scale
AccessorFunc(PANEL, "BaseColor", "BaseColor", FORCE_NUMBER)
AccessorFunc(PANEL, "Hue", "Hue", FORCE_NUMBER)
AccessorFunc(PANEL, "Saturation", "Saturation", FORCE_NUMBER)
AccessorFunc(PANEL, "Luminosity", "Luminosity", FORCE_NUMBER)

function PANEL:Init()
    self:SetHue(0)
    self:SetSaturation(100)
    self:SetLuminosity(50)
    self.Steps = {}
end

function PANEL:SetBaseColor(color)
    self.BaseColor = color
    self:GenerateGradient()
end

function PANEL:PerformLayout(w, h)
    self:GenerateGradient()

    if not self.LastX then
        self.LastX = w / 2
    end
end

function PANEL:GenerateGradient()
    self.Steps = {}
    self.Times = 100 -- The max number that the hue can be

    for i = 0, self.Times do
        local step = (1 / self.Times) * i
        local color = HSLToColor(self:GetHue(), self:GetSaturation(), i / 100)

        self.Steps[i] = {
            offset = step,
            color = color
        }
    end
end

function PANEL:GetColor()
    local h = self:GetHue()
    local s = self:GetSaturation()
    local l = self:GetLuminosity()

    return HSLToColor(h, s, l)
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    local wide = x / self:GetWide()
    local luminosity = clamp(wide, 0, 1)
    self:SetLuminosity(luminosity)
    local col = self:GetColor(hue)

    if col then
        self:OnChange(self:GetLuminosity())
    end

    self.LastX = x
end

function PANEL:OnChange(col)
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

    if not self.LastX then return end
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

vgui.Register("PIXEL.LuminosityBar", PANEL, "EditablePanel")