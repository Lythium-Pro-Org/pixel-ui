PIXEL = PIXEL or {}
local sc = PIXEL.Scale
local PANEL = {}

function PANEL:Init()
    self.TextEntry = vgui.Create("PIXEL.TextEntry", self)
    self.TextEntry:Dock(TOP)
    self.TextEntry:DockMargin(sc(20), sc(20), sc(20), 0)
    self.TextEntry:SetTall(sc(35))
    self.TextEntry:SetPlaceholderText("Placeholder Text!")

    self.BadValidatedTextEntry = vgui.Create("PIXEL.ValidatedTextEntry", self)
    self.BadValidatedTextEntry:Dock(TOP)
    self.BadValidatedTextEntry:DockMargin(sc(20), sc(20), sc(20), 0)
    self.BadValidatedTextEntry:SetPlaceholderText("Bad Text!")

    function self.BadValidatedTextEntry:IsTextValid(text)
        return false, "Bad Text!"
    end

    self.GoodValidatedTextEntry = vgui.Create("PIXEL.ValidatedTextEntry", self)
    self.GoodValidatedTextEntry:Dock(TOP)
    self.GoodValidatedTextEntry:DockMargin(sc(20), sc(0), sc(20), 0)
    self.GoodValidatedTextEntry:SetPlaceholderText("Good Text!")

    function self.GoodValidatedTextEntry:IsTextValid(text)
        return true, "Good Text!"
    end
end

vgui.Register("PIXEL.Test.Text", PANEL)