PIXEL = PIXEL or {}
PIXEL.Configurator = PIXEL.Configurator or {}

function PIXEL.Configurator.GenerateInfo(addonName, addonTbl)
    PIXEL.GenerateFont(50)
    PIXEL.GenerateFont(25)
    PIXEL.GenerateFont(20)

    local PANEL = {}

    function PANEL:Init()
        self.Logo = vgui.Create("PIXEL.ImgurButton", self)
        self.Logo:SetSize(PIXEL.Scale(64), PIXEL.Scale(64))
        self.Logo:SetPos(PIXEL.Scale(10), PIXEL.Scale(5))
        self.Logo:SetImgurID(addonTbl.logo or "hw27Bk4")
        self.Logo.DoClick = function(s)
            if !addonTbl.url then return end
            gui.OpenURL(addonTbl.url)
        end

        self.Name = vgui.Create("PIXEL.Label", self)
        self.Name:SetText(addonName)
        self.Name:SetAutoWidth(true)
        self.Name:SetAutoHeight(true)
        self.Name:SetFont("PIXEL.Font.Size50")
        self.Name:SetTextColor(PIXEL.Colors.PrimaryText)
        self.Name:SetPos(self.Logo:GetX() + self.Logo:GetWide() + PIXEL.Scale(10), 0)
        self.Name:InvalidateLayout(true)

        self.Version = vgui.Create("PIXEL.Label", self)
        self.Version:SetText("v" .. addonTbl.version)
        self.Version:SetAutoWidth(true)
        self.Version:SetAutoHeight(true)
        self.Version:SetFont("PIXEL.Font.Size25")
        self.Version:SetTextColor(PIXEL.Colors.SecondaryText)
        self.Version:SetPos(self.Name:GetX() + self.Name:GetWide() + PIXEL.Scale(5), self.Name:GetY() + self.Version:GetTall() - PIXEL.Scale(5))
        if addonTbl.versionChcker then
            local latestVersion, upToDate = addonTbl.versionChecker.latestVersion, addonTbl.versionChecker.upToDate
            if !upToDate then
                self.Version:SetTextColor(PIXEL.Colors.Negative)
                self.Version:SetFont("PIXEL.Font.Size22")
                self.Version:SetText("v" .. addonTbl.version .. " (latest: " .. latestVersion .. ")")
                self.Version:InvalidateLayout(true)
            end
        end

        self.Author = vgui.Create("PIXEL.Label", self)
        self.Author:SetText(addonTbl.author)
        self.Author:SetAutoWidth(true)
        self.Author:SetAutoHeight(true)
        self.Author:SetFont("PIXEL.Font.Size20")
        self.Author:SetTextColor(PIXEL.Colors.SecondaryText)
        self.Author:SetPos(self.Name:GetX(), self.Name:GetY() + self.Name:GetTall() - PIXEL.Scale(5))

        if addonTbl.supportUrl then
            self.Support = vgui.Create("PIXEL.TextButton", self)
            self.Support:SetPos(self.Logo:GetX(), self.Logo:GetY() + self.Logo:GetTall() + PIXEL.Scale(10))
            self.Support:SetText("Support")
            self.Support.DoClick = function(s)
                gui.OpenURL(addonTbl.supportUrl)
            end
        end
    end

    function PANEL:PaintMore(w, h)

    end
    addonName = addonName:gsub(" ", "_")
    vgui.Register("PIXEL.Configurator." .. addonName .. ".Info", PANEL, "PIXEL.Configurator.BackPanel")
end
