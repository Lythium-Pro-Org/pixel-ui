---@class PulsarUI.RGBPicker : EditablePanel
---@field SetRGB fun(self: PulsarUI.RGBPicker, color: Color)
---@field GetRGB fun(self: PulsarUI.RGBPicker): Color
---@field SetHue fun(self: PulsarUI.RGBPicker, hue: number)
---@field GetHue fun(self: PulsarUI.RGBPicker): number
---@field PerformLayout fun(self: PulsarUI.RGBPicker, w: number, h: number)
local PANEL = {}

AccessorFunc(PANEL, "m_RGB", "RGB")
AccessorFunc(PANEL, "Hue", "Hue", FORCE_NUMBER)

function PANEL:Init()
    self:SetRGB(color_white)
    self.LastX = 0
    self.Steps = {}

    self.Material = Material( "gui/colors.png" )
end

function PANEL:PerformLayout(w, h)
    self.Steps = {}
    self.Times = 360 -- The max number that the hue can be

    for i = 0, self.Times do
        local step = (1 / self.Times) * i
        local color = HSLToColor(i, 1, 0.5)

        self.Steps[i] = {
            offset = step,
            color = color
        }
    end

    self.LastX = (1 / 360) * self:GetWide()
end

function PANEL:GetColor()
    local h = self:GetHue() or 0

    return HSLToColor(h, 1, 0.5)
end

function PANEL:GetRGB()
    return self:GetColor()
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    local wide = x / self:GetWide()
    local hue = math.Clamp(wide, 0, 1)
    hue = math.floor(hue * self.Times)
    self:SetHue(hue)
    local col = self:GetColor()

    if col then
        self:OnChange(col)
    end

    self.LastX = x
end

function PANEL:OnChange(col)
    print(col.r, col.g, col.b)
end

function PANEL:OnMousePressed(mcode)
    self:MouseCapture(true)
    self:OnCursorMoved(self:CursorPos())
end

function PANEL:OnMouseReleased(mcode)
    self:MouseCapture(false)
    self:OnCursorMoved(self:CursorPos())
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen(-PulsarUI.Scale(4), 0) // why the the fuck we have to -4 pixels idfk

    local barH = h - PulsarUI.Scale(4)

    PulsarUI.Mask(function()
        PulsarUI.DrawRoundedBox(barH / 2, 0, PulsarUI.Scale(2), w, barH, color_white)
    end,
    function()
        PulsarUI.DrawLinearGradient(x, y, w + PulsarUI.Scale(4), h, self.Steps, true)
    end)


    local newX = self.LastX

    if newX < (h / 2) then
        newX = h / 2
    end

    if newX > w - (h / 2) then
        newX = w - (h / 2)
    end

    PulsarUI.DrawRoundedBox(h / 2, newX - (h / 2), 0, h, h, self:GetColor())
    PulsarUI.DrawOutlinedRoundedBox(h / 2, newX - (h / 2), 0, h, h, color_black, 12)
end

vgui.Register("PulsarUI.RGBPicker", PANEL, "EditablePanel")
