
local PANEL = {}

function PANEL:Init()
    local boxSize = PIXEL.Scale(20)
    self:SetIsToggle(true)
    self:SetSize(boxSize, boxSize)
    self:SetImageURL("https://pixel-cdn.lythium.dev/i/tick")
    self:SetNormalColor(PIXEL.Colors.Transparent)
    self:SetHoverColor(PIXEL.Colors.PrimaryText)
    self:SetClickColor(PIXEL.Colors.PrimaryText)
    self:SetDisabledColor(PIXEL.Colors.Transparent)
    self:SetImageSize(.6)
    self.BackgroundCol = PIXEL.CopyColor(PIXEL.Colors.Primary)
end

function PANEL:PaintBackground(w, h)
    if not self:IsEnabled() then
        PIXEL.DrawRoundedBox(8, 0, 0, w, h, PIXEL.Colors.Disabled)
        self:PaintExtra(w, h)

        return
    end

    local bgCol = PIXEL.Colors.Primary

    if self:IsDown() or self:GetToggle() then
        bgCol = PIXEL.Colors.Positive
    end

    local animTime = FrameTime() * 12
    self.BackgroundCol = PIXEL.LerpColor(animTime, self.BackgroundCol, bgCol)
    PIXEL.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("PIXEL.Checkbox", PANEL, "PIXEL.ImageButton")