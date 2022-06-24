PIXEL = PIXEL or {}
local sc = PIXEL.Scale
local PANEL = {}

PIXEL.GenerateFont(25)

function PANEL:Init()
    self.Category = vgui.Create("PIXEL.Category", self)
    self.Category:Dock(TOP)
    self.Category:DockMargin(sc(10), sc(10), sc(10), sc(10))
    self.Category:SetTitle("Categorys!")

    self.Slider = vgui.Create("PIXEL.Slider", self)
    self.Slider:Dock(TOP)
    self.Slider:DockMargin(sc(50), sc(10), sc(50), sc(10))

    self.LabelledCheckbox = vgui.Create("PIXEL.LabelledCheckbox", self)
    self.LabelledCheckbox:Dock(TOP)
    self.LabelledCheckbox:DockMargin(sc(50), sc(10), sc(50), sc(10))
    self.LabelledCheckbox:SetText("Labelled Checkbox!")
    self.LabelledCheckbox:SetFont("PIXEL.Font.Size25")

    self.ComboBox = vgui.Create("PIXEL.ComboBox", self)
    self.ComboBox:Dock(TOP)
    self.ComboBox:DockMargin(sc(50), sc(10), sc(50), sc(10))
    self.ComboBox:SetSizeToText(false)
    self.ComboBox:AddChoice("Choice 1", "Choice 1", "Choice 1")
    self.ComboBox:AddChoice("Choice 2", "Choice 2", "Choice 2")
    self.ComboBox:AddChoice("Choice 3", "Choice 3", "Choice 3")
    self.ComboBox:AddChoice("Choice 4", "Choice 4", "Choice 4")
    self.ComboBox:AddChoice("Choice 5", "Choice 5", "Choice 5")

    self.ColorPicker = vgui.Create("PIXEL.ColorPicker", self)
    self.ColorPicker:Dock(FILL)
    self.ColorPicker:DockMargin(sc(50), sc(10), sc(50), sc(10))
end

function PANEL:PaintMore(w,h)

end

vgui.Register("PIXEL.Test.Other", PANEL)