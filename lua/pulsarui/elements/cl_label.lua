--- @class PulsarUI.Label : Panel
--- @field SetText fun(self: PulsarUI.Label, value: string)
--- @field GetText fun(self: PulsarUI.Label): string
--- @field SetFont fun(self: PulsarUI.Label, value: string)
--- @field GetFont fun(self: PulsarUI.Label): string
--- @field SetTextAlign fun(self: PulsarUI.Label, value: number)
--- @field GetTextAlign fun(self: PulsarUI.Label): number
--- @field SetTextColor fun(self: PulsarUI.Label, value: Color)
--- @field GetTextColor fun(self: PulsarUI.Label): Color
--- @field SetEllipses fun(self: PulsarUI.Label, value: boolean)
--- @field GetEllipses fun(self: PulsarUI.Label): boolean
--- @field SetAutoHeight fun(self: PulsarUI.Label, value: boolean)
--- @field GetAutoHeight fun(self: PulsarUI.Label): boolean
--- @field SetAutoWidth fun(self: PulsarUI.Label, value: boolean)
--- @field GetAutoWidth fun(self: PulsarUI.Label): boolean
--- @field SetAutoSize fun(self: PulsarUI.Label, value: boolean)
--- @field GetAutoSize fun(self: PulsarUI.Label): boolean
--- @field SetAutoWrap fun(self: PulsarUI.Label, value: boolean)
--- @field GetAutoWrap fun(self: PulsarUI.Label): boolean
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