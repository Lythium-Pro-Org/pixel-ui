local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextSpacing", "TextSpacing", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Icon", "Icon")

function PANEL:SetIcon(icon)
    if type(icon) ~= "string" then
        self.Icon = icon
        return
    end

    local imgurMatch = (icon or ""):match("^[a-zA-Z0-9]+$")
    if imgurMatch then
        print("[PulsarUI UI] Using imgur icons inside of PulsarUI.TextButton is deprecated.")
        icon = "https://i.imgur.com/" .. icon .. ".png"
    end

    self.Icon = icon
end

PulsarUI.RegisterFont("UI.TextButton", "Rubik", 20, 600)

function PANEL:Init()
    self:SetText("Button")
    self:SetTextAlign(TEXT_ALIGN_CENTER)
    self:SetTextSpacing(PulsarUI.Scale(6))
    self:SetFont("UI.TextButton")
    self:SetSize(PulsarUI.Scale(100), PulsarUI.Scale(30))
    self:SetIcon(false)
end

function PANEL:SizeToText()
    PulsarUI.SetFont(self:GetFont())

    if self:GetIcon() then
        local iconSize = self:GetTall() * .6
        self:SetSize(PulsarUI.GetTextSize(self:GetText()) + PulsarUI.Scale(20) + iconSize, PulsarUI.Scale(30))

        return
    end

    self:SetSize(PulsarUI.GetTextSize(self:GetText()) + PulsarUI.Scale(14), PulsarUI.Scale(30))
end

function PANEL:PaintExtra(w, h)
    local textAlign = self:GetTextAlign()
    local textX = (textAlign == TEXT_ALIGN_CENTER and w / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - self:GetTextSpacing()) or self:GetTextSpacing()
    local iconSize = 0

    if self:GetIcon() then
        iconSize = self:GetTall() * .6
        PulsarUI.DrawImage(PulsarUI.Scale(8), h / 2 - iconSize / 2, iconSize, iconSize, self:GetIcon(), PulsarUI.Colors.PrimaryText)
        iconSize = iconSize + PulsarUI.Scale(6)
    end

    if not self:IsEnabled() then
        PulsarUI.DrawSimpleText(self:GetText(), self:GetFont(), textX + iconSize, h / 2, PulsarUI.Colors.DisabledText, textAlign, TEXT_ALIGN_CENTER)

        return
    end

    PulsarUI.DrawSimpleText(self:GetText(), self:GetFont(), textX + iconSize, h / 2, PulsarUI.Colors.PrimaryText, textAlign, TEXT_ALIGN_CENTER)
end

vgui.Register("PulsarUI.TextButton", PANEL, "PulsarUI.Button")