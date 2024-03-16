
local PANEL = {}

function PANEL:Init()
    local boxSize = PulsarUI.Scale(20)
    self:SetIsToggle(true)
    self:SetSize(boxSize, boxSize)
    self:SetImageURL("https://pixel-cdn.lythium.dev/i/tick")
    self:SetNormalColor(PulsarUI.Colors.Transparent)
    self:SetHoverColor(PulsarUI.Colors.PrimaryText)
    self:SetClickColor(PulsarUI.Colors.PrimaryText)
    self:SetDisabledColor(PulsarUI.Colors.Transparent)
    self:SetImageSize(.6)
    self.BackgroundCol = PulsarUI.CopyColor(PulsarUI.Colors.Primary)
end

function PANEL:PaintBackground(w, h)
    if not self:IsEnabled() then
        PulsarUI.DrawRoundedBox(8, 0, 0, w, h, PulsarUI.Colors.Disabled)
        self:PaintExtra(w, h)

        return
    end

    local bgCol = PulsarUI.Colors.Primary

    if self:IsDown() or self:GetToggle() then
        bgCol = PulsarUI.Colors.Positive
    end

    local animTime = FrameTime() * 12
    self.BackgroundCol = PulsarUI.LerpColor(animTime, self.BackgroundCol, bgCol)
    PulsarUI.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("PulsarUI.Checkbox", PANEL, "PulsarUI.ImageButton")