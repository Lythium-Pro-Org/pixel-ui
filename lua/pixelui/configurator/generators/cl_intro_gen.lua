PIXEL = PIXEL or {}
PIXEL.Configurator = PIXEL.Configurator or {}

function PIXEL.Configurator.GenerateIntro(addonName, addonTbl)
    local PANEL = {}

    function PANEL:Init()
        self.Created = false
        self.Icon = vgui.Create("PIXEL.ImgurButton", self)
        self.Icon:SetImgurID(addonTbl.logo)
    end

    function PANEL:PerformLayout(w, h)
        if self.Created then return end
        self.Created = true
        self.Icon:SetSize(w / 3, w / 3)
        self.Icon:Center()
        local parent = self:GetParent()
        self.Icon:SizeTo(0    , 0    , .2, .0, -1)
        self.Icon:MoveTo(w / 2, h / 2, .2, .0, -1, function()
            parent.ChangeTab("PIXEL.Configurator." .. addonName .. ".Settings")
        end)
    end

    function PANEL:PaintMore(w, h)
    end
    addonName = addonName:gsub(" ", "_")
    vgui.Register("PIXEL.Configurator." .. addonName .. ".Intro", PANEL, "PIXEL.Configurator.BackPanel")
end
