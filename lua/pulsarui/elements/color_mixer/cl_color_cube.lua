---@class PulsarUI.ColorCube : DSlider
---@field SetHue fun(self: PulsarUI.ColorCube, hue: number)
---@field GetHue fun(self: PulsarUI.ColorCube): number
---@field SetBaseRGB fun(self: PulsarUI.ColorCube, color: Color)
---@field GetBaseRGB fun(self: PulsarUI.ColorCube): Color
---@field SetRGB fun(self: PulsarUI.ColorCube, color: Color)
---@field GetRGB fun(self: PulsarUI.ColorCube): Color
local PANEL = {}

AccessorFunc(PANEL, "m_Hue", "Hue")
AccessorFunc(PANEL, "m_BaseRGB", "BaseRGB")
AccessorFunc(PANEL, "m_OutRGB", "RGB")

function PANEL:Init()
    self.BGSaturation = vgui.Create("PulsarUI.Image", self)
    self.BGSaturation:SetImage("vgui/gradient-r")
    self.BGSaturation:SetPaintedManually(true)

    self.BGValue = vgui.Create("PulsarUI.Image", self)
    self.BGValue:SetImage("vgui/gradient-d")
    self.BGValue:SetImageColor(color_black)
    self.BGValue:SetPaintedManually(true)

    self:SetBaseRGB(Color(255, 0, 0))
    self:SetRGB(Color(255, 0, 0))
    self:SetColor(Color(255, 0, 0))

    self:SetLockX(nil)
    self:SetLockY(nil)
end

function PANEL:LayoutExtra(w, h)
    self.BGSaturation:StretchToParent(0, 0, 0, 0)
    self.BGSaturation:SetZPos(-9)

    self.BGValue:StretchToParent(0, 0, 0, 0)
    self.BGValue:SetZPos(-8)
end

function PANEL:Paint(w, h)
    PulsarUI.Mask(
        function()
            PulsarUI.DrawRoundedBox(8, 0, 0, w, h, self.m_BaseRGB)
        end,
        function()
            surface.SetDrawColor(self.m_BaseRGB.r, self.m_BaseRGB.g, self.m_BaseRGB.b, 255)
            self:DrawFilledRect()

            self.BGSaturation:PaintManual()
            self.BGValue:PaintManual()
        end
    )
end

function PANEL:TranslateValues(x, y)
    self:UpdateColor(x, y)
    self:OnUserChanged(self:GetRGB())

    return x, y
end

function PANEL:UpdateColor(x, y)
    x = x or self:GetSlideX()
    y = y or self:GetSlideY()

    local value = 1 - y
    local saturation = 1 - x
    local h = ColorToHSV(self.m_BaseRGB)

    local color = HSVToColor(h, saturation, value)
    print(PulsarUI.IsColorLight(color))
    if PulsarUI.IsColorLight(color) then
        self.KnobColor = color_black
    else
        self.KnobColor = color_white
    end

    self:SetRGB(color)
end

function PANEL:OnUserChanged(color)
end

function PANEL:SetColor(color)
    local h, s, v = ColorToHSV(color)

    self:SetBaseRGB(HSVToColor(h, 1, 1))

    self:SetSlideY(1 - v)
    self:SetSlideX(1 - s)
    self:UpdateColor()
end

function PANEL:SetBaseRGB(color)
    self.m_BaseRGB = color
    self:UpdateColor()
end

vgui.Register("PulsarUI.ColorCube", PANEL, "PulsarUI.ColorCube.Slider")