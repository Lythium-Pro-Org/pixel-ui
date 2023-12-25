

local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "ButtonText", "ButtonText", FORCE_STRING)

PIXEL.RegisterFont("UI.Message", "Rubik", 18, 600)

function PANEL:Init()
    self:SetDraggable(true)
    self:SetSizable(true)

    self:SetMinWidth(PIXEL.Scale(240))
    self:SetMinHeight(PIXEL.Scale(80))

    self.Message = vgui.Create("PIXEL.Label", self)
    self.Message:SetTextAlign(TEXT_ALIGN_CENTER)
    self.Message:SetFont("UI.Message")

    self.ButtonHolder = vgui.Create("Panel", self)

    self.Button = vgui.Create("PIXEL.TextButton", self.ButtonHolder)
    self.Button.DoClick = function(s, w, h)
        self:Close(true)
    end
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(PIXEL.Scale(8), PIXEL.Scale(8), PIXEL.Scale(8), PIXEL.Scale(8))

    self.Button:SizeToText()
    self.ButtonHolder:Dock(TOP)
    self.ButtonHolder:DockMargin(0, 0, 0, PIXEL.Scale(8))
    self.ButtonHolder:SetTall(self.Button:GetTall())

    self.Button:CenterHorizontal()

    if self.ButtonHolder:GetWide() < self.Button:GetWide() then
        self.ButtonHolder:SetWide(self.Button:GetWide())
    end

    if self:GetWide() < PIXEL.Scale(240) then
        self:SetWide(PIXEL.Scale(240))
        self:Center()
    end

    if self:GetWide() - PIXEL.Scale(40) < self.Message:GetWide() then
        self.Message:SetWide(self:GetWide() + self.Message:GetWide() - (self:GetWide() - PIXEL.Scale(40)))
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

vgui.Register("PIXEL.Message", PANEL, "PIXEL.Frame")

PIXEL.UI.Overrides.Derma_Message = PIXEL.UI.Overrides.Derma_Message or Derma_Message

Derma_Message = PIXEL.UI.CreateToggleableOverride(PIXEL.UI.Overrides.Derma_Message, function(text, title, buttonText)
    buttonText = buttonText or "OK"

    local msg = vgui.Create("PIXEL.Message")
    msg:SetTitle(title)
    msg:SetText(text)
    msg:SetButtonText(buttonText)

    msg:MakePopup()
    msg:DoModal()

    return msg
end, PIXEL.UI.ShouldOverrideDermaPopups)