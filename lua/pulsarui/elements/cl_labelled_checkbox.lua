
local PANEL = {}

function PANEL:Init()
    self.Checkbox = vgui.Create("PulsarUI.Checkbox", self)

    self.Checkbox.OnToggled = function(s, enabled)
        self:OnToggled(enabled)
    end

    self.Label = vgui.Create("PulsarUI.Label", self)
    self.Label:SetAutoWidth(true)
    self.Label:SetAutoHeight(true)
end

function PANEL:PerformLayout(w, h)
    self.Checkbox:Dock(LEFT)
    self.Checkbox:SetWide(h)
    self.Checkbox:DockMargin(0, 0, PulsarUI.Scale(6), 0)
    self.Label:SetPos(self.Checkbox:GetWide() + PulsarUI.Scale(6), (h / 2) - (self.Label:GetTall() / 2) + 1)
end

function PANEL:OnToggled(enabled)
end

function PANEL:SetText(text)
    self.Label:SetText(text)
end

function PANEL:GetText()
    return self.Label:GetText()
end

function PANEL:SetFont(font)
    self.Label:SetFont(font)
end

function PANEL:GetFont()
    return self.Label:GetFont()
end

function PANEL:SetTextColor(col)
    self.Label:SetTextColor(col)
end

function PANEL:GetTextColor()
    return self.Label:GetTextColor()
end

function PANEL:SetAutoWrap(enabled)
    self.Label:SetAutoWrap(enabled)
end

function PANEL:GetAutoWrap()
    return self.Label:GetAutoWrap()
end

vgui.Register("PulsarUI.LabelledCheckbox", PANEL, "Panel")