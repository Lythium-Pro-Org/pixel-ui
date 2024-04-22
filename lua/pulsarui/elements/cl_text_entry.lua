---@class PulsarUI.TextEntry : Panel
---@field TextEntry PulsarUI.TextEntryInternal
---@field PlaceholderTextCol Color
---@field DisabledCol Color
---@field InnerColor Color
---@field OutlineColor Color
---@field FocusedOutlineCol Color
---@field InnerOutlineCol Color
---@field OverrideCol Color
local PANEL = {}

function PANEL:Init()
    self.TextEntry = vgui.Create("PulsarUI.TextEntryInternal", self)

    self.PlaceholderTextCol = PulsarUI.OffsetColor(PulsarUI.Colors.SecondaryText, -110)

    self.DisabledCol = PulsarUI.OffsetColor(PulsarUI.Colors.Background, 6)

    self.InnerColor = PulsarUI.OffsetColor(PulsarUI.Colors.Header, 5)

    self.OutlineColor = PulsarUI.CopyColor(PulsarUI.Colors.Transparent)
    self.FocusedOutlineCol = PulsarUI.Colors.PrimaryText

    self.InnerOutlineCol = PulsarUI.CopyColor(PulsarUI.Colors.Transparent)
end

function PANEL:PerformLayout(w, h)
    self.TextEntry:Dock(FILL)

    local xPad, yPad = PulsarUI.Scale(4), PulsarUI.Scale(8)
    self:DockPadding(xPad, yPad, xPad, yPad)

    self:LayoutContent(w, h)
end

function PANEL:Paint(w, h)
    if not self:IsEnabled() then
        PulsarUI.DrawRoundedBox(8, 0, 0, w, h, self.DisabledCol)
        PulsarUI.DrawSimpleText("Disabled", "UI.TextEntry", PulsarUI.Scale(4), h / 2, PulsarUI.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return
    end

    local col = PulsarUI.Colors.Transparent

    if self:IsEditing() then
        col = self.FocusedOutlineCol
    end

    if self.OverrideCol then
        col = self.OverrideCol
    end

    self.OutlineColor = PulsarUI.LerpColor(FrameTime() * 8, self.OutlineColor, col)

    PulsarUI.DrawRoundedBox(6, 0, 0, w, h, self.InnerColor)

    PulsarUI.DrawOutlinedRoundedBox(6, 0, 0, w, h, self.OutlineColor, 4)

    if self:GetValue() == "" then
        PulsarUI.DrawSimpleText(self:GetPlaceholderText() or "", "UI.TextEntry", PulsarUI.Scale(10), h / 2, self.PlaceholderTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:LayoutContent(w, h) end

function PANEL:OnChange() end
function PANEL:OnValueChange(value) end

function PANEL:IsEnabled() return self.TextEntry:IsEnabled() end
function PANEL:SetEnabled(enabled) self.TextEntry:SetEnabled(enabled) end

function PANEL:GetValue() return self.TextEntry:GetValue() end
function PANEL:SetValue(value) self.TextEntry:SetValue(value) end

function PANEL:IsMultiline() return self.TextEntry:IsMultiline() end
function PANEL:SetMultiline(isMultiline) self.TextEntry:SetMultiline(isMultiline) end

function PANEL:GetEnterAllowed() return self.TextEntry:GetEnterAllowed() end
function PANEL:SetEnterAllowed(allow) self.TextEntry:SetEnterAllowed(allow) end

function PANEL:GetUpdateOnType() return self.TextEntry:GetUpdateOnType() end
function PANEL:SetUpdateOnType(enabled) self.TextEntry:SetUpdateOnType(enabled) end

function PANEL:GetNumeric() return self.TextEntry:GetNumeric() end
function PANEL:SetNumeric(enabled) self.TextEntry:SetNumeric(enabled) end

function PANEL:GetHistoryEnabled() return self.TextEntry:GetHistoryEnabled() end
function PANEL:SetHistoryEnabled(enabled) self.TextEntry:SetHistoryEnabled(enabled) end

function PANEL:GetTabbingDisabled() return self.TextEntry:GetTabbingDisabled() end
function PANEL:SetTabbingDisabled(disabled) self.TextEntry:SetTabbingDisabled(disabled) end

function PANEL:GetPlaceholderText() return self.TextEntry:GetPlaceholderText() end
function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end

function PANEL:GetInt() return self.TextEntry:GetInt() end
function PANEL:GetFloat() return self.TextEntry:GetFloat() end

function PANEL:IsEditing() return self.TextEntry:IsEditing() end
function PANEL:SetEditable(enabled) self.TextEntry:SetEditable(enabled) end

function PANEL:AllowInput(value) end
function PANEL:GetAutoComplete(txt) end

function PANEL:OnKeyCode(code) end
function PANEL:OnEnter() end

function PANEL:OnGetFocus() end
function PANEL:OnLoseFocus() end

vgui.Register("PulsarUI.TextEntry", PANEL, "Panel")