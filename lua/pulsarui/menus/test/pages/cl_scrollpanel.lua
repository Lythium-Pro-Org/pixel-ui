PulsarUI = PulsarUI or {}
local sc = PulsarUI.Scale
local PANEL = {}

function PANEL:Init()
    self.ScrollPanel = vgui.Create("PulsarUI.ScrollPanel", self)
    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockMargin(0, 0, 0, 0)

    for i = 0, 250 do
        self.ClickyTextButton = vgui.Create("PulsarUI.TextButton", self.ScrollPanel)
        self.ClickyTextButton:Dock(TOP)
        self.ClickyTextButton:DockMargin(sc(5), sc(5), sc(5), sc(5))
        self.ClickyTextButton:SetTall(sc(50))
        self.ClickyTextButton:SetText("Clicky Button!")
    end
end

function PANEL:PaintMore(w,h)

end

vgui.Register("PulsarUI.Test.ScrollPanel", PANEL)