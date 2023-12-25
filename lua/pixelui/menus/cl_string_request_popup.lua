

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

    self.TextEntry = vgui.Create("PIXEL.TextEntry", self)

    self.BottomPanel = vgui.Create("Panel", self)
    self.ButtonHolder = vgui.Create("Panel", self.BottomPanel)

    self.Buttons = {}
end

function PANEL:AddOption(name, callback)
    local btn = vgui.Create("PIXEL.TextButton", self.ButtonHolder)
    btn:SetText(name)
    btn.DoClick = function()
        self:Close(true)
        callback(self.TextEntry:GetValue())
    end
    table.insert(self.Buttons, btn)
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(0, 0, 0, PIXEL.Scale(8))

    if self:GetWide() - PIXEL.Scale(40) < self.Message:GetWide() then
        self.Message:SetWide(self:GetWide() + self.Message:GetWide() - (self:GetWide() - PIXEL.Scale(40)))
    end


    self.TextEntry:SetTall(PIXEL.Scale(32))
    self.TextEntry:Dock(TOP)
    self.TextEntry:DockMargin(0, 0, 0, PIXEL.Scale(8))

    for k, v in ipairs(self.Buttons) do
        v:SizeToText()
        v:SetTall(PIXEL.Scale(32))
        v:Dock(LEFT)
        v:DockMargin(PIXEL.Scale(8), 0, PIXEL.Scale(8), PIXEL.Scale(8))
    end

    self.ButtonHolder:SizeToChildren(true)

    local firstBtn = self.Buttons[1]

    self.BottomPanel:Dock(TOP)
    self.BottomPanel:SetTall(firstBtn:GetTall())
    self.ButtonHolder:SetTall(firstBtn:GetTall())

    self.ButtonHolder:CenterHorizontal()

    if self.ButtonHolder:GetWide() < firstBtn:GetWide() then
        self.ButtonHolder:SetWide(firstBtn:GetWide())
    end

    if self:GetWide() < PIXEL.Scale(240) then
        self:SetWide(240)
        self:Center()
    end

    if self.HasSized and self.HasSized > 1 then return end
    self.HasSized = (self.HasSized or 0) + 1

    self:SizeToChildren(true, true)
    self:Center()
end

function PANEL:SetText(text) self.Message:SetText(text) end
function PANEL:GetText(text) return self.Message:GetText() end

function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end
function PANEL:GetPlaceholderText(text) return self.TextEntry:GetPlaceholderText() end

vgui.Register("PIXEL.StringRequest", PANEL, "PIXEL.Frame")

PIXEL.UI.Overrides.Derma_StringRequest = PIXEL.UI.Overrides.Derma_StringRequest or Derma_StringRequest

Derma_StringRequest = PIXEL.UI.CreateToggleableOverride(PIXEL.UI.Overrides.Derma_StringRequest, function(title, text, placeholderText, enterCallback, cancelCallback, buttonText, cancelText)
    cancelCallback = cancelCallback or function() end
    buttonText = buttonText or "OK"
    cancelText = cancelText or "Cancel"

    local msg = vgui.Create("PIXEL.StringRequest")
    msg:SetTitle(title)
    msg:SetText(text)

    msg:SetPlaceholderText(placeholderText)

    msg:AddOption(buttonText, enterCallback)
    msg:AddOption(cancelText, cancelCallback)

    msg.CloseButton.DoClick = function(s)
        cancelCallback(msg.TextEntry:GetValue())
        msg:Close()
    end

    msg:MakePopup()
    msg:DoModal()

    return msg
end, PIXEL.UI.ShouldOverrideDermaPopups)