

local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "ButtonText", "ButtonText", FORCE_STRING)

PulsarUI.RegisterFont("UI.Message", "Rubik", 18, 600)

function PANEL:Init()
    self:SetDraggable(true)
    self:SetSizable(true)

    self:SetMinWidth(PulsarUI.Scale(240))
    self:SetMinHeight(PulsarUI.Scale(80))

    self.Message = vgui.Create("PulsarUI.Label", self)
    self.Message:SetTextAlign(TEXT_ALIGN_CENTER)
    self.Message:SetFont("UI.Message")

    self.ButtonHolder = vgui.Create("Panel", self)

    self.Button = vgui.Create("PulsarUI.TextButton", self.ButtonHolder)
    self.Button.DoClick = function(s, w, h)
        self:Close(true)
    end
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(PulsarUI.Scale(8), PulsarUI.Scale(8), PulsarUI.Scale(8), PulsarUI.Scale(8))

    self.Button:SizeToText()
    self.ButtonHolder:Dock(TOP)
    self.ButtonHolder:DockMargin(0, 0, 0, PulsarUI.Scale(8))
    self.ButtonHolder:SetTall(self.Button:GetTall())

    self.Button:CenterHorizontal()

    if self.ButtonHolder:GetWide() < self.Button:GetWide() then
        self.ButtonHolder:SetWide(self.Button:GetWide())
    end

    if self:GetWide() < PulsarUI.Scale(240) then
        self:SetWide(PulsarUI.Scale(240))
        self:Center()
    end

    if self:GetWide() - PulsarUI.Scale(40) < self.Message:GetWide() then
        self.Message:SetWide(self:GetWide() + self.Message:GetWide() - (self:GetWide() - PulsarUI.Scale(40)))
    end


    if self.HasSized and self.HasSized > 1 then return end
    self.HasSized = (self.HasSized or 0) + 1

    self:SizeToChildren(true, true)
    self:Center()
end

function PANEL:SetText(text) self.Message:SetText(text) end
function PANEL:GetText(text) return self.Message:GetText() end

function PANEL:SetButtonText(text) self.Button:SetText(text) end
function PANEL:GetButtonText(text) return self.Button:GetText() end

vgui.Register("PulsarUI.Message", PANEL, "PulsarUI.Frame")

PulsarUI.Overrides.Derma_Message = PulsarUI.Overrides.Derma_Message or Derma_Message

Derma_Message = PulsarUI.CreateToggleableOverride(PulsarUI.Overrides.Derma_Message, function(text, title, buttonText)
    buttonText = buttonText or "OK"

    local msg = vgui.Create("PulsarUI.Message")
    msg:SetTitle(title)
    msg:SetText(text)
    msg:SetButtonText(buttonText)

    msg:MakePopup()
    msg:DoModal()

    return msg
end, PulsarUI.ShouldOverrideDermaPopups)