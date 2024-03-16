

local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "ButtonText", "ButtonText", FORCE_STRING)

PulsarUI.RegisterFont("UI.Message", "Rubik", 18, 600)

function PANEL:Init()
    self:SetDraggable(true)
    self:SetSizable(true)

    self:SetMinWidth(PulsarUI.Scale(260))
    self:SetMinHeight(PulsarUI.Scale(80))

    self.Message = vgui.Create("PulsarUI.Label", self)
    self.Message:SetTextAlign(TEXT_ALIGN_CENTER)
    self.Message:SetFont("UI.Message")

    self.BottomPanel = vgui.Create("Panel", self)
    self.ButtonHolder = vgui.Create("Panel", self.BottomPanel)

    self.Buttons = {}
end

function PANEL:AddOption(name, callback)
    callback = callback or function() end

    local btn = vgui.Create("PulsarUI.TextButton", self.ButtonHolder)
    btn:SetText(name)
    btn.DoClick = function()
        self:Close(true)
        callback()
    end
    table.insert(self.Buttons, btn)
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(PulsarUI.Scale(8), PulsarUI.Scale(8), PulsarUI.Scale(8), PulsarUI.Scale(8))

    for k, v in ipairs(self.Buttons) do
        v:SizeToText()
        v:SetTall(PulsarUI.Scale(32))
        v:Dock(LEFT)
        v:DockMargin(PulsarUI.Scale(8), 0, PulsarUI.Scale(8), PulsarUI.Scale(8))
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

    if self.BottomPanel:GetWide() < self.ButtonHolder:GetWide() then
        self.BottomPanel:SetWide(self.ButtonHolder:GetWide())
    end

    if self:GetWide() < PulsarUI.Scale(240) then
        self:SetWide(240)
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

vgui.Register("PulsarUI.Query", PANEL, "PulsarUI.Frame")

PulsarUI.Overrides.Derma_Query = PulsarUI.Overrides.Derma_Query or Derma_Query

Derma_Query = PulsarUI.CreateToggleableOverride(PulsarUI.Overrides.Derma_Query, function(text, title, ...)
    local msg = vgui.Create("PulsarUI.Query")
    msg:SetTitle(title)
    msg:SetText(text)

    local args = {...}
    for i = 1, #args, 2 do
        msg:AddOption(args[i], args[i + 1])
    end

    msg:MakePopup()
    msg:DoModal()

    return msg
end, PulsarUI.ShouldOverrideDermaPopups)