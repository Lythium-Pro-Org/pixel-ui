PIXEL = PIXEL or {}
PIXEL.Configurator = PIXEL.Configurator or {}

function PIXEL.Configurator.GenerateMainSettings(addonName, addonTbl)
    local PANEL = {}

    function PANEL:Init()
        self.Navbar = vgui.Create("PIXEL.Navbar", self)
        self.Navbar:Dock(TOP)
        self.Navbar:SetTall(PIXEL.Scale(50))

        function self.ChangeTab(pnlName)
            if IsValid(self.ContentPanel) then
                self.ContentPanel:Remove()
            end
            self.ContentPanel = vgui.Create(pnlName, self)
            self.ContentPanel:Dock(FILL)
            self.ContentPanel:DockMargin(PIXEL.Scale(2), PIXEL.Scale(2), PIXEL.Scale(2), PIXEL.Scale(2))
        end

        for k, v in ipairs(addonTbl.tabs) do
            local data = v.name:gsub(" ", "_")

            self.Navbar:AddItem(k, v.name, function() self.ChangeTab("PIXEL.Configurator." .. addonName .. ".Tab." .. data) end, k, v.color, v.icon)
        end
        self.Navbar:AddItem(table.Count(addonTbl.tabs) + 1, "Info", function() self.ChangeTab("PIXEL.Configurator." .. addonName .. ".Info") end, table.Count(addonTbl.tabs) + 1, PIXEL.Colors.Diamond)

        self.Navbar:SelectItem(1)
    end

    vgui.Register("PIXEL.Configurator." .. addonName .. ".Settings", PANEL, "PIXEL.Configurator.BackPanel")
end
