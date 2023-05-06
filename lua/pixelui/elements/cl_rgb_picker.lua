local PANEL = {}
local floor = math.floor
local clamp = math.Clamp
local colToHSV, HSVToCol = ColorToHSV, HSVToColor
local scale = PIXEL.Scale
AccessorFunc(PANEL, "RGBValue", "RGB")

function PANEL:Init()
    self:SetRGB(color_white)
    self.LastX = 0
    self.Steps = {}
end

function PANEL:PerformLayout(w, h)
    self.Steps = {}
    self.Times = 360 -- The max number that the hue can be

    for i = 0, self.Times do
        local step = (1 / self.Times) * i
        local color = HSVToCol(i, 1, 1)

        self.Steps[i] = {
            offset = step,
            color = color
        }
    end
end

function PANEL:GetPosColor(value)
    local position = floor(value * self.Times)
    local color = self.Steps[position].color

    return color
end

function PANEL:GetColorPos(color)
    local h, _, _ = colToHSV(color)
    local pos = floor((h * self:GetWide()) / self.Times)
    return pos
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    local wide = x / self:GetWide()
    local value = clamp(wide, 0, 1)
    local col = self:GetPosColor(value)

    if col then
        self.RGBValue = col
        self.RGBValue.a = 255
        self:OnChange(self.RGBValue)
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

    local newX = self.LastX

    if newX < (h / 2) then
        newX = (h / 2)
    end

    if newX > w - (h / 2) then
        newX = w - (h / 2)
    end

    PIXEL.DrawFullRoundedBox(8, newX - (h / 2), 0, h, h, color_white)
    x, y, wh = newX + scale(3), scale(3), h - scale(6)
    PIXEL.DrawFullRoundedBox(4, x - (h / 2), y, wh, wh, self:GetRGB())
end

vgui.Register("PIXEL.RGBPicker", PANEL, "EditablePanel")