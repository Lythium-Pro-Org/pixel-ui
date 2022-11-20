
function PIXEL.Configurator.GenerateInfo(addonName, addonTbl)
    local PANEL = {}

    function PANEL:Init()

    end


    vgui.Register("PIXEL.Configurator." .. addonName .. ".Info", PANEL, "PIXEL.Configurator.BackPanel")
end