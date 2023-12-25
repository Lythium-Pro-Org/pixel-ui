local PANEL = {}

AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "ImageSize", "ImageSize", FORCE_NUMBER)
AccessorFunc(PANEL, "FrameEnabled", "FrameEnabled", FORCE_BOOL)
AccessorFunc(PANEL, "Rounded", "Rounded", FORCE_NUMBER)
AccessorFunc(PANEL, "NormalColor", "NormalColor")
AccessorFunc(PANEL, "HoverColor", "HoverColor")
AccessorFunc(PANEL, "ClickColor", "ClickColor")
AccessorFunc(PANEL, "DisabledColor", "DisabledColor")

function PANEL:Init()
    self.ImageCol = PIXEL.CopyColor(color_white)
    self:SetImageURL("https://pixel-cdn.lythium.dev/i/loading")

    self:SetNormalColor(color_white)
    self:SetHoverColor(color_white)
    self:SetClickColor(color_white)
    self:SetDisabledColor(color_white)

    self:SetImageSize(1)
    self:SetFrameEnabled(false)
end

function PANEL:PaintBackground(w, h) end

function PANEL:Paint(w, h)
    self:PaintBackground(w, h)

    if self:IsHovered() and self:GetFrameEnabled() then
        PIXEL.DrawRoundedBox(self:GetRounded(), 0, 0, w, h, self:GetHoverColor())
    end

    local imageSize = h * self:GetImageSize()
    local imageOffset = (h / 2) - (imageSize / 2)

    if self:GetFrameEnabled() then
        imageSize = imageSize * .45
        imageOffset = (h / 2) - (imageSize / 2) + PIXEL.Scale(1)
    end

    if not self:IsEnabled() then
        PIXEL.DrawImage(imageOffset, imageOffset, imageSize, imageSize, self:GetImageURL(), self:GetDisabledColor())

        return
    end

    local col = self:GetNormalColor()

    if self:IsHovered() and not self:GetFrameEnabled() then
        col = self:GetHoverColor()
    end

    if self:IsDown() or self:GetToggle() then
        col = self:GetClickColor()
    end

    self.ImageCol = PIXEL.LerpColor(FrameTime() * 12, self.ImageCol, col)
    PIXEL.DrawImage(imageOffset, imageOffset, imageSize, imageSize, self:GetImageURL(), self.ImageCol)
end

vgui.Register("PIXEL.ImageButton", PANEL, "PIXEL.Button")