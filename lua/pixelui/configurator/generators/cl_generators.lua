PIXEL = PIXEL or {}
PIXEL.Configurator = PIXEL.Configurator or {}

function PIXEL.Configurator.GeneratePanels(addonName, addonTbl)
    PIXEL.Configurator.GenerateIntro(addonName, addonTbl)
    PIXEL.Configurator.GenerateMainSettings(addonName, addonTbl)
    PIXEL.Configurator.GenerateInfo(addonName, addonTbl)

    for k, v in ipairs(addonTbl.tabs) do
        PIXEL.Configurator.GenerateTab(v.name, v, addonTbl)
    end
end
