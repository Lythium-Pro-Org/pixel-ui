local PANEL = {}
local floor = math.floor
AccessorFunc(PANEL, "Hue", "Hue")
AccessorFunc(PANEL, "BaseRGB", "BaseRGB")
AccessorFunc(PANEL, "RGB", "RGB")
AccessorFunc(PANEL, "SlideX", "SlideX")
AccessorFunc(PANEL, "SlideY", "SlideY")

function PANEL:Init()
    self.BackgroundSat = vgui.Create("PIXEL.Image", self)
    self.BackgroundSat:SetImage("vgui/gradient-r")
    self.BackgroundSat:Dock(FILL)

    self.BackgroundValue = vgui.Create("PIXEL.Image", self)
    self.BackgroundValue:Dock(FILL)
    self.BackgroundValue:SetImage("vgui/gradient-d")
    self.BackgroundValue:SetImageColor(color_black)

    self:SetBaseRGB(Color(255, 0, 0))
    self:SetRGB(Color(255, 0, 0))
    self:SetColor(Color(255, 0, 0))

    self.LastX = 0
    self.LastY = 0
end

function PANEL:OnCursorMoved(x, y)
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    local panelWide, panelTall = self:GetSize()
    local wide = x / panelWide
    local tall = y / panelTall
    self.LastX = floor(wide * panelWide)
    self.LastY = floor(tall * panelTall)

    self:TranslateValues(x, y)
end

function PANEL:LayoutContent(w, h)
    self.BackgroundSat:SetZPos(-9)
    self.BackgroundValue:SetZPos(-8)
end

function PANEL:Paint(w, h)
    PIXEL.Mask(
        function()
            PIXEL.DrawFullRoundedBox(8, 0, 0, w, h, color_white)
        end,
        function()
            PIXEL.DrawRoundedBox(0, 0, 0, w, h, Color(self.BaseRGB.r, self.BaseRGB.g, self.BaseRGB.b, 255))
            PIXEL.DrawOutlinedBox(0, 0, w, h, 1, Color(0, 0, 0, 250))
        end
    )
end

function PANEL:PaintOver(w, h)
    local scale = PIXEL.Scale(20)
    local newX = self.LastX
    local newY = self.LastY
    local x, y, wh

    if newX < (scale / 2) then
        newX = (scale / 2)
    end

    if newX > w - (scale / 2) then
        newX = w - (scale / 2)
    end

    if newY < (scale / 2) then
        newY = (scale / 2)
    end

    if newY > h - (scale / 2) then
        newY = h - (scale / 2)
    end

    newX = newX - (scale / 2)
    newY = newY - (scale / 2)

    PIXEL.DrawFullRoundedBox(8, newX, newY, scale, scale, color_white)
    x, y, wh = newX + PIXEL.Scale(3), newY + PIXEL.Scale(3), scale - PIXEL.Scale(6)
    PIXEL.DrawFullRoundedBox(4, x, y, wh, wh, self:GetRGB())
end

function PANEL:TranslateValues(x, y)
    self:UpdateColor(x, y)
    self:OnUserChanged(self.RGB)

    return x, y
end

function PANEL:UpdateColor(x, y)
    x = x or self:GetSlideX() or 0
    y = y or self:GetSlideY() or 0

    local value = 1 - math.Clamp(y / self:GetTall(), 0, 1)
    local saturation = 1 - math.Clamp(x / self:GetWide(), 0, 1)
    local h = ColorToHSV(self.BaseRGB)

    local color = HSVToColor(h, saturation, value)

    self:SetRGB(color)
end

function PANEL:OnUserChanged()
end

function PANEL:SetColor(color)
    local h, s, v = ColorToHSV(color)

    self:SetBaseRGB(HSVToColor(h, 1, 1))

    self:SetSlideY(1 - v)
    self:SetSlideX(1 - s)

    self:UpdateColor()
end

function PANEL:SetBaseRGB(color)
    self.BaseRGB = color
    self:UpdateColor()
end

vgui.Register("PIXEL.ColorCube", PANEL, "EditablePanel")