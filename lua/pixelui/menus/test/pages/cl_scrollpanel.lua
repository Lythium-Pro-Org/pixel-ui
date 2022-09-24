PIXEL = PIXEL or {}
local sc = PIXEL.Scale
local PANEL = {}

function PANEL:Init()
    self.ScrollPanel = vgui.Create("PIXEL.ScrollPanel", self)
    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockMargin(0, 0, 0, 0)

    for i = 0, 250 do
        self.ClickyTextButton = vgui.Create("PIXEL.TextButton", self.ScrollPanel)
        self.ClickyTextButton:Dock(TOP)
        self.ClickyTextButton:DockMargin(sc(5), sc(5), sc(5), sc(5))
        self.ClickyTextButton:SetTall(sc(50))
        self.ClickyTextButton:SetText("Clicky Button!")
    end
end

function PANEL:PaintMore(w,h)

end

vgui.Register("PIXEL.Test.ScrollPanel", PANEL)