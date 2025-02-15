local PANEL = {}
local clamp = math.Clamp
local scale = PulsarUI.Scale
AccessorFunc(PANEL, "BaseColor", "BaseColor")
AccessorFunc(PANEL, "Hue", "Hue", FORCE_NUMBER)
AccessorFunc(PANEL, "Saturation", "Saturation", FORCE_NUMBER)
AccessorFunc(PANEL, "Luminosity", "Luminosity", FORCE_NUMBER)

function PANEL:Init()
    self:SetBaseColor(Color(255, 0, 0))
    self:SetHue(0)
    self:SetSaturation(1)
    self:SetLuminosity(.5)
end

function PANEL:PerformLayout(w, h)
    if not self.LastX then
        self.LastX = w
    end
end

function PANEL:GetColor()
    local h = self:GetHue() or 0
    local s = self:GetSaturation() or 1
    local l = self:GetLuminosity() or .5

    return HSLToColor(h, s, l)
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    local wide = x / self:GetWide()
    local saturation = clamp(wide, 0, 1)
    self:SetSaturation(saturation)
    local col = self:GetColor()

    if col then
        self:OnChange(self:GetSaturation())
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

    local color = HSLToColor(self:GetHue(), 1, self:GetLuminosity())
    PulsarUI.DrawSimpleLinearGradient(x, y, w, h, Color(128, 128, 128), Color(color.r, color.g, color.b), true)

    if not self.LastX then return end
    local newX = self.LastX

    if newX < (h / 2) then
        newX = h / 2
    end

    if newX > w - (h / 2) then
        newX = w - (h / 2)
    end

    PulsarUI.DrawRoundedBox(8, newX - (h / 2), 0, h, h, color_white)
    x, y, wh = newX + scale(3), scale(3), h - scale(6)
    PulsarUI.DrawRoundedBox(5, x - (h / 2), y, wh, wh, self:GetColor())
end

vgui.Register("PulsarUI.SaturationBar", PANEL, "EditablePanel")