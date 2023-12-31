PulsarUI = PulsarUI or {}
local sc = PulsarUI.Scale
local PANEL = {}
PulsarUI.GenerateFont(25)

function PANEL:Init()
    self.ScrollPanel = vgui.Create("PulsarUI.ScrollPanel", self)
    self.ScrollPanel:Dock(FILL)

    self.Category = vgui.Create("PulsarUI.Category", self.ScrollPanel)
    self.Category:Dock(TOP)
    self.Category:DockMargin(sc(10), sc(10), sc(10), sc(10))
    self.Category:SetTitle("Categorys!")

    self.Slider = vgui.Create("PulsarUI.Slider", self.ScrollPanel)
    self.Slider:Dock(TOP)
    self.Slider:SetTall(PulsarUI.Scale(20))
    self.Slider:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.LabelledCheckbox = vgui.Create("PulsarUI.LabelledCheckbox", self.ScrollPanel)
    self.LabelledCheckbox:Dock(TOP)
    self.LabelledCheckbox:DockMargin(sc(50), sc(10), sc(50), sc(10))
    self.LabelledCheckbox:SetText("Labelled Checkbox!")
    self.LabelledCheckbox:SetFont("PulsarUI.Font.Size25")

    self.ComboBox = vgui.Create("PulsarUI.ComboBox", self.ScrollPanel)
    self.ComboBox:Dock(TOP)
    self.ComboBox:DockMargin(sc(50), sc(10), sc(50), sc(10))
    self.ComboBox:SetSizeToText(false)

    self.ComboBox:AddChoice("Choice 1", "Choice 1", "Choice 1")
    self.ComboBox:AddChoice("Choice 2", "Choice 2", "Choice 2")
    self.ComboBox:AddChoice("Choice 3", "Choice 3", "Choice 3")
    self.ComboBox:AddChoice("Choice 4", "Choice 4", "Choice 4")
    self.ComboBox:AddChoice("Choice 5", "Choice 5", "Choice 5")

    self.NumberEntry = vgui.Create("PulsarUI.NumberEntry", self.ScrollPanel)
    self.NumberEntry:Dock(TOP)
    self.NumberEntry:SetTall(PulsarUI.Scale(40))
    self.NumberEntry:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.StepCounter = vgui.Create("PulsarUI.StepCounter", self.ScrollPanel)
    self.StepCounter:Dock(TOP)
    self.StepCounter:SetStepCount(8)
    self.StepCounter:SetTall(PulsarUI.Scale(90))
    self.StepCounter:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.ColorPicker = vgui.Create("PulsarUI.ColorPickerV2", self.ScrollPanel)
    self.ColorPicker:SetAlphaBar(true)

    self.ScrollPanel.LayoutContent = function(s, w, h)
        self.ColorPicker:SetSize(w - PulsarUI.Scale(250), PulsarUI.Scale(120))
        self.ColorPicker:SetPos(PulsarUI.Scale(50), self.StepCounter:GetY() + self.StepCounter:GetTall() + PulsarUI.Scale(10))
    end
end

function PANEL:PaintMore(w, h)
end



vgui.Register("PulsarUI.Test.Other", PANEL)