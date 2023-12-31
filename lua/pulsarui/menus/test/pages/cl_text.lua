PulsarUI = PulsarUI or {}
local sc = PulsarUI.Scale
local PANEL = {}

function PANEL:Init()
    self.TextEntry = vgui.Create("PulsarUI.TextEntry", self)
    self.TextEntry:Dock(TOP)
    self.TextEntry:DockMargin(sc(20), sc(20), sc(20), 0)
    self.TextEntry:SetTall(sc(35))
    self.TextEntry:SetPlaceholderText("Placeholder Text!")

    self.BadValidatedTextEntry = vgui.Create("PulsarUI.ValidatedTextEntry", self)
    self.BadValidatedTextEntry:Dock(TOP)
    self.BadValidatedTextEntry:DockMargin(sc(20), sc(20), sc(20), 0)
    self.BadValidatedTextEntry:SetPlaceholderText("Bad Text!")

    function self.BadValidatedTextEntry:IsTextValid(text)
        return false, "Bad Text!"
    end

    self.GoodValidatedTextEntry = vgui.Create("PulsarUI.ValidatedTextEntry", self)
    self.GoodValidatedTextEntry:Dock(TOP)
    self.GoodValidatedTextEntry:DockMargin(sc(20), sc(0), sc(20), 0)
    self.GoodValidatedTextEntry:SetPlaceholderText("Good Text!")

    function self.GoodValidatedTextEntry:IsTextValid(text)
        return true, "Good Text!"
    end
end

vgui.Register("PulsarUI.Test.Text", PANEL)