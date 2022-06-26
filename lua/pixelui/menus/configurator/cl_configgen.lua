PIXEL = PIXEL or {}
PIXELConfigurator = PIXELConfigurator or {}
PIXELConfigurator.RegisteredAddons = PIXELConfigurator.RegisteredAddons or {}

--[[
    addonData = {
        name = "",
        version = "",
        author = "",
        link = "",
        description = "",
        license = "",
        icon = "",
    }
]]

function PIXELConfigurator.CreatePanel(addonName, addonData)
    if addonName == nil or addonData == nil then return  end
    PIXELConfigurator.RegisteredAddons[addonName].vguiID = "PIXEL.Configurator.Panel." .. addonName

    local PANEL = {}
    function PANEL:Init()
        self:GetParent():SetVersion(addonData.version)
        self:GetParent():SetDescription(addonData.description)
        self:GetParent():SetDeveloper(addonData.developer)
    end
    vgui.Register(PIXELConfigurator.RegisteredAddons[addonName].vguiID, PANEL)
end

function PIXELConfigurator.RegisterContents(addonName, addonContents)
    PIXELConfigurator.RegisteredAddons[addonName].Contents = addonContents
end

function PIXELConfigurator.RegisterAddon(addonName, addonData, addonContents)
    PIXELConfigurator.RegisteredAddons[addonName] = addonData
    PIXELConfigurator.RegisterContents(addonName, addonContents)
    PIXELConfigurator.CreatePanel(addonName, addonData)
end

function PIXELConfigurator.UnRegisterAddon(addonName)
    PIXELConfigurator.RegisteredAddons[addonName] = nil
end

--[[
    addonContents = {
        tab1 = {
            whatever = {
                type = "label"
                text = "text",
                position = {x = 0, y = 0},
                align = "left",
                font = "font",
                color = "PIXEL.Colors.PrimaryText"
            },
            whatever2 = {
                type = "button"
                text = "text",
                position = {x = 0, y = 0},
                font = "font",
                clicky = true,
                sounds = true,
                color = "PIXEL.Colors.Primary",
                doClick = function() print("hi) end
            },
            whatever3 = {
                type = "checkbox"
                text = "text",
                position = {x = 0, y = 0},
                font = "font",
                color = "PIXEL.Colors.PrimaryText",
                checked = true,
                doClick = function() print("hi) end
            },
        },
        tab2 = {
            whatever = {
                type = "combobox"
                position = {x = 0, y = 0},
                sortItems = true,
                choices = {
                    "choice1",
                    "choice2",
                    "choice3",
                }
            },
            whatever2 = {
                type = "slider"
                position = {x = 0, y = 0},
                min = 0,
                max = 100,
                value = 50,
                OnValueChanged = function() print(fraction) end
            },
            whatever3 = {
                type = "colorpicker"
                position = {x = 0, y = 0},
                color = "PIXEL.Colors.Primary",
                OnValueChanged = function() print(color) end
            },
            whatever4 = {
                type = "textentry"
                position = {x = 0, y = 0},
                placeholder = "hi",
                OnValueChange = function() print(val) end
            },
        }
    }
]]


PIXELConfigurator.RegisterAddon("Test", {
    name = "Test",
    version = "1.5",
    developer = "Lythium",
    link = "",
    description = "PIXEL Configurator Test Menu",
    license = "",
    icon = "8bKjn4t",
})

PIXELConfigurator.RegisterAddon("Test 2", {
    name = "Test 2",
    version = "2.1",
    developer = "sex",
    link = "",
    description = "PIXEL Configurator Test 2 Menu",
    license = "",
    icon = "8bKjn4t",
})
