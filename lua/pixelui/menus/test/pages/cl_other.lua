PIXEL = PIXEL or {}
local sc = PIXEL.Scale
local PANEL = {}
PIXEL.GenerateFont(25)

function PANEL:Init()
    self.ScrollPanel = vgui.Create("PIXEL.ScrollPanel", self)
    self.ScrollPanel:Dock(FILL)

    self.Category = vgui.Create("PIXEL.Category", self.ScrollPanel)
    self.Category:Dock(TOP)
    self.Category:DockMargin(sc(10), sc(10), sc(10), sc(10))
    self.Category:SetTitle("Categorys!")

    self.Slider = vgui.Create("PIXEL.Slider", self.ScrollPanel)
    self.Slider:Dock(TOP)
    self.Slider:SetTall(PIXEL.Scale(20))
    self.Slider:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.LabelledCheckbox = vgui.Create("PIXEL.LabelledCheckbox", self.ScrollPanel)
    self.LabelledCheckbox:Dock(TOP)
    self.LabelledCheckbox:DockMargin(sc(50), sc(10), sc(50), sc(10))
    self.LabelledCheckbox:SetText("Labelled Checkbox!")
    self.LabelledCheckbox:SetFont("PIXEL.Font.Size25")

    self.ComboBox = vgui.Create("PIXEL.ComboBox", self.ScrollPanel)
    self.ComboBox:Dock(TOP)
    self.ComboBox:DockMargin(sc(50), sc(10), sc(50), sc(10))
    self.ComboBox:SetSizeToText(false)

    self.ComboBox:AddChoice("Choice 1", "Choice 1", "Choice 1")
    self.ComboBox:AddChoice("Choice 2", "Choice 2", "Choice 2")
    self.ComboBox:AddChoice("Choice 3", "Choice 3", "Choice 3")
    self.ComboBox:AddChoice("Choice 4", "Choice 4", "Choice 4")
    self.ComboBox:AddChoice("Choice 5", "Choice 5", "Choice 5")

    self.NumberEntry = vgui.Create("PIXEL.NumberEntry", self.ScrollPanel)
    self.NumberEntry:Dock(TOP)
    self.NumberEntry:SetTall(PIXEL.Scale(40))
    self.NumberEntry:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.StepCounter = vgui.Create("PIXEL.StepCounter", self.ScrollPanel)
    self.StepCounter:Dock(TOP)
    self.StepCounter:SetStepCount(8)
    self.StepCounter:SetTall(PIXEL.Scale(90))
    self.StepCounter:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.ColorPicker = vgui.Create("PIXEL.ColorPickerV2", self.ScrollPanel)
    self.ColorPicker:SetAlphaBar(true)

    self.ScrollPanel.LayoutContent = function(s, w, h)
        self.ColorPicker:SetSize(w - PIXEL.Scale(250), PIXEL.Scale(120))
        self.ColorPicker:SetPos(PIXEL.Scale(50), self.StepCounter:GetY() + self.StepCounter:GetTall() + PIXEL.Scale(10))
    end
end

function PANEL:PaintMore(w, h)
end



vgui.Register("PIXEL.Test.Other", PANEL)