
PulsarUI.RegisterFont("UI.TextEntryLabel", "Rubik", 10)

local PANEL = {}
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Label", "Label", FORCE_STRING)

function PANEL:SetFont(font, isPixel)
	self.TextEntry:SetFont(font, isPixel)
end

function PANEL:Init()
	self:SetLabel("test")
	self.TextEntry = vgui.Create("PulsarUI.TextEntryInternal", self)
	self.PlaceholderTextCol = PulsarUI.OffsetColor(PulsarUI.Colors.SecondaryText, -110)

	self.BackgroundCol = PulsarUI.OffsetColor(PulsarUI.Colors.Scroller, -25)
	self.BaseBackgroundCol = PulsarUI.CopyColor(self.BackgroundCol)
	self.HoveredCol = PulsarUI.OffsetColor(PulsarUI.Colors.Scroller, -15)
	self.FocusedCol = PulsarUI.OffsetColor(PulsarUI.Colors.Scroller, -5)
end

function PANEL:PerformLayout(w, h)
	self:LayoutContent(w, h)
	self.TextEntry:Dock(FILL)
	local xPad, yPad = PulsarUI.Scale(8), PulsarUI.Scale(8)
	self:DockPadding(xPad, yPad, xPad, yPad)
end

function PANEL:LayoutContent(w, h)
end

function PANEL:Paint(w, h)
	if not self:IsEnabled() then
		PulsarUI.DrawRoundedBoxEx(8, PulsarUI.Scale(3), 0, w - PulsarUI.Scale(3), h, self.BackgroundCol, false, true, false, true)
		PulsarUI.DrawRoundedBoxEx(8, 0, 0, PulsarUI.Scale(3), h, self.DisabledCol, true, false, true, false)

		PulsarUI.DrawSimpleText("Disabled", "UI.TextEntry", PulsarUI.Scale(8), h / 2, PulsarUI.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	if self:GetValue() == "" then
		PulsarUI.DrawSimpleText(self:GetPlaceholderText() or "", "UI.TextEntry", PulsarUI.Scale(10), h / 2, self.PlaceholderTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local label = self:GetLabel()

	local backgroundCol = self.BaseBackgroundCol
	local animTime = FrameTime() * 24

	if self:IsHovered() then
		backgroundCol = self.HoveredCol
	end

	if self:IsEditing() then
		backgroundCol = self.FocusedCol
	end

	if self.OverrideCol then
		backgroundCol = self.OverrideCol
	end

	self.BackgroundCol = PulsarUI.LerpColor(animTime, self.BackgroundCol, backgroundCol)

	local labelH = 0
	if label then
		_, labelH = PulsarUI.GetTextSize(label, "UI.TextEntryLabel")
	end

	print(labelH)

	PulsarUI.DrawRoundedBox((h - labelH) / 2, 0, labelH, w, h - labelH, self.BackgroundCol)

	if label then
		PulsarUI.DrawSimpleText(label, "UI.TextEntryLabel", PulsarUI.Scale(12), 0, PulsarUI.Colors.PrimaryText, TEXT_ALIGN_LEFT)
	end
end

function PANEL:OnChange()
end

function PANEL:OnValueChange(value)
end

function PANEL:IsHovered()
	return self.TextEntry:IsHovered()
end

function PANEL:IsEnabled()
	return self.TextEntry:IsEnabled()
end

function PANEL:SetEnabled(enabled)
	self.TextEntry:SetEnabled(enabled)
end

function PANEL:GetValue()
	return self.TextEntry:GetValue()
end

function PANEL:SetValue(value)
	self.TextEntry:SetValue(value)
end

function PANEL:IsMultiline()
	return self.TextEntry:IsMultiline()
end

function PANEL:SetMultiline(isMultiline)
	self.TextEntry:SetMultiline(isMultiline)
end

function PANEL:IsEditing()
	return self.TextEntry:IsEditing()
end

function PANEL:GetEnterAllowed()
	return self.TextEntry:GetEnterAllowed()
end

function PANEL:SetEnterAllowed(allow)
	self.TextEntry:SetEnterAllowed(allow)
end

function PANEL:GetUpdateOnType()
	return self.TextEntry:GetUpdateOnType()
end

function PANEL:SetUpdateOnType(enabled)
	self.TextEntry:SetUpdateOnType(enabled)
end

function PANEL:GetNumeric()
	return self.TextEntry:GetNumeric()
end

function PANEL:SetNumeric(enabled)
	self.TextEntry:SetNumeric(enabled)
end

function PANEL:GetHistoryEnabled()
	return self.TextEntry:GetHistoryEnabled()
end

function PANEL:SetHistoryEnabled(enabled)
	self.TextEntry:SetHistoryEnabled(enabled)
end

function PANEL:GetTabbingDisabled()
	return self.TextEntry:GetTabbingDisabled()
end

function PANEL:SetTabbingDisabled(disabled)
	self.TextEntry:SetTabbingDisabled(disabled)
end

function PANEL:GetPlaceholderText()
	return self.TextEntry:GetPlaceholderText()
end

function PANEL:SetPlaceholderText(text)
	self.TextEntry:SetPlaceholderText(text)
end

function PANEL:GetInt()
	return self.TextEntry:GetInt()
end

function PANEL:GetFloat()
	return self.TextEntry:GetFloat()
end

function PANEL:IsEditing()
	return self.TextEntry:IsEditing()
end

function PANEL:SetEditable(enabled)
	self.TextEntry:SetEditable(enabled)
end

function PANEL:AllowInput(value)
end

function PANEL:GetAutoComplete(txt)
end

function PANEL:OnKeyCode(code)
end

function PANEL:OnEnter()
end

function PANEL:OnGetFocus()
end

function PANEL:OnLoseFocus()
end

vgui.Register("PulsarUI.TextEntry", PANEL, "Panel")