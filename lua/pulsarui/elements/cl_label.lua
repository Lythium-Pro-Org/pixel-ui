
local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "Ellipses", "Ellipses", FORCE_BOOL)
AccessorFunc(PANEL, "AutoHeight", "AutoHeight", FORCE_BOOL)
AccessorFunc(PANEL, "AutoWidth", "AutoWidth", FORCE_BOOL)
AccessorFunc(PANEL, "AutoSize", "AutoSize", FORCE_BOOL)
AccessorFunc(PANEL, "AutoWrap", "AutoWrap", FORCE_BOOL)
PulsarUI.RegisterFont("UI.Label", "Rubik", 14)

function PANEL:SetAutoSize(autoSize)
    self:SetAutoWidth(autoSize)
    self:SetAutoHeight(autoSize)
end

function PANEL:Init()
    self:SetText("Label")
    self:SetFont("UI.Label")
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetTextColor(PulsarUI.Colors.SecondaryText)
end

function PANEL:SetText(text)
    self.Text = text
    self.OriginalText = text
end

function PANEL:CalculateSize()
    PulsarUI.SetFont(self:GetFont())

    return PulsarUI.GetTextSize(self:GetText())
end

function PANEL:PerformLayout(w, h)
    local desiredW, desiredH = self:CalculateSize()

    if self:GetAutoWidth() then
        self:SetWide(desiredW)
    end

    if self:GetAutoHeight() then
        self:SetTall(desiredH)
    end

    if self:GetAutoWrap() then
        self.Text = PulsarUI.WrapText(self.OriginalText, w, self:GetFont())
    end
end

function PANEL:Paint(w, h)
    local align = self:GetTextAlign()
    local text = self:GetEllipses() and PulsarUI.EllipsesText(self:GetText(), w, self:GetFont()) or self:GetText()

    if align == TEXT_ALIGN_CENTER then
        PulsarUI.DrawText(text, self:GetFont(), w / 2, 0, self:GetTextColor(), TEXT_ALIGN_CENTER)

        return
    elseif align == TEXT_ALIGN_RIGHT then
        PulsarUI.DrawText(text, self:GetFont(), w, 0, self:GetTextColor(), TEXT_ALIGN_RIGHT)

        return
    end

    PulsarUI.DrawText(text, self:GetFont(), 0, 0, self:GetTextColor())
end

vgui.Register("PulsarUI.Label", PANEL, "Panel")