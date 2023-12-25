
PIXEL.RegisterFont("UI.TextEntryLabel", "Rubik", 10)

local PANEL = {}
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Label", "Label", FORCE_STRING)

function PANEL:SetFont(font, isPixel)
	self.TextEntry:SetFont(font, isPixel)
end

function PANEL:Init()
	self:SetLabel("test")
	self.TextEntry = vgui.Create("PIXEL.TextEntryInternal", self)
	self.PlaceholderTextCol = PIXEL.OffsetColor(PIXEL.Colors.SecondaryText, -110)

	self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Scroller, -25)
	self.BaseBackgroundCol = PIXEL.CopyColor(self.BackgroundCol)
	self.HoveredCol = PIXEL.OffsetColor(PIXEL.Colors.Scroller, -15)
	self.FocusedCol = PIXEL.OffsetColor(PIXEL.Colors.Scroller, -5)
end

function PANEL:PerformLayout(w, h)
	self:LayoutContent(w, h)
	self.TextEntry:Dock(FILL)
	local xPad, yPad = PIXEL.Scale(8), PIXEL.Scale(8)
	self:DockPadding(xPad, yPad, xPad, yPad)
end

function PANEL:LayoutContent(w, h)
end

function PANEL:Paint(w, h)
	if not self:IsEnabled() then
		PIXEL.DrawRoundedBoxEx(8, PIXEL.Scale(3), 0, w - PIXEL.Scale(3), h, self.BackgroundCol, false, true, false, true)
		PIXEL.DrawRoundedBoxEx(8, 0, 0, PIXEL.Scale(3), h, self.DisabledCol, true, false, true, false)

		PIXEL.DrawSimpleText("Disabled", "UI.TextEntry", PIXEL.Scale(8), h / 2, PIXEL.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	if self:GetValue() == "" then
		PIXEL.DrawSimpleText(self:GetPlaceholderText() or "", "UI.TextEntry", PIXEL.Scale(10), h / 2, self.PlaceholderTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

	self.BackgroundCol = PIXEL.LerpColor(animTime, self.BackgroundCol, backgroundCol)

	local labelH = 0
	if label then
		_, labelH = PIXEL.GetTextSize(label, "UI.TextEntryLabel")
	end

	print(labelH)

	PIXEL.DrawRoundedBox((h - labelH) / 2, 0, labelH, w, h - labelH, self.BackgroundCol)

	if label then
		PIXEL.DrawSimpleText(label, "UI.TextEntryLabel", PIXEL.Scale(12), 0, PIXEL.Colors.PrimaryText, TEXT_ALIGN_LEFT)
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

vgui.Register("PIXEL.TextEntry", PANEL, "Panel")