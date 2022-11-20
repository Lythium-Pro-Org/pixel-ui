PIXEL = PIXEL or {}
PIXEL.Configurator = PIXEL.Configurator or {}

local PANEL = {}

function PANEL:Init()
    self:SetSize(PIXEL.Scale(900), PIXEL.Scale(650))
    self:Center()
    self:MakePopup()
    self:SetTitle("PIXEL Configurator")
    self:SetImgurID("8bKjn4t")

    function self.ChangeTab(pnlName)
        if IsValid(self.ContentPanel) then
            self.ContentPanel:Remove()
        end
        self.ContentPanel = vgui.Create(pnlName, self)
        self.ContentPanel:Dock(FILL)
        self.ContentPanel:DockMargin(PIXEL.Scale(2), PIXEL.Scale(2), PIXEL.Scale(2), PIXEL.Scale(2))
    end

    self.Sidebar = self:CreateSidebar(1, "8bKjn4t")
    idNum = 1
    for k, v in pairs(PIXEL.Configurator.Addons) do
        self.Sidebar:AddItem(idNum, v.name, v.logo, function() self.ChangeTab("PIXEL.Configurator." .. v.name .. ".Intro") end)
        idNum = idNum + 1
    end
end

vgui.Register("PIXEL.Configurator", PANEL, "PIXEL.Frame")

concommand.Add("pixel_configurator", function()
    if IsValid(PIXEL.Configurator) then
        PIXEL.Configurator:Remove()
    end
    PIXEL.Configurator = vgui.Create("PIXEL.Configurator")
end)

PANEL = {}

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(3), 0, 0, w, h, PIXEL.Colors.Header)
    self:PaintMore(w, h)
end

function PANEL:PaintMore(w, h) end

vgui.Register("PIXEL.Configurator.BackPanel", PANEL, "EditablePanel")

function fuckery()
if IsValid(sexpanel) then
    sexpanel:Remove()
end
sexpanel = vgui.Create("PIXEL.Configurator")
end
