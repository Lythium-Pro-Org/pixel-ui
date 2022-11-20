PIXEL = PIXEL or {}
PIXEL.Configurator = PIXEL.Configurator or {}
PIXEL.Configurator.Addons = PIXEL.Configurator.Addons or {}

--
--  Addon Registering
--

local AddonHandler = {}

function AddonHandler.New(name)
    local addon = setmetatable({}, {
        __index = AddonHandler
    })

    addon.name = name
    return addon
end

function AddonHandler:SetVersion(version)
    self.version = version
    return self
end

function AddonHandler:SetLogo(logo)
    self.logo = logo
    return self
end

function AddonHandler:SetAuthor(author)
    self.author = author
    return self
end

function AddonHandler:SetURL(url)
    self.url = url
    return self
end

function AddonHandler:SetSupportURL(supportUrl)
    self.supportUrl = supportUrl
    return self
end

function AddonHandler:SetDependancy(name, version, required)
    self.dependancys = self.dependancys or {}
    self.dependancys[name] = {
        name = name,
        version = version,
        required = required
    }
    return self
end

function PIXEL.LoadDependancy(name, version)
    PIXEL.Dependancies = PIXEL.Dependancies or {}
    PIXEL.Dependancies[name] = {
        name = name,
        version = version
    }
end

function AddonHandler:Load(basePath)
    PIXEL.LoadDirectoryRecursive(basePath, (self.onLoad and true) or nil)
    return self
end

function AddonHandler:OnLoad(func)
    self.onLoad = func
    return self
end

-- "button, slider, checkbox, combobox, textEntry, validatedTextEntry"
function AddonHandler:AddTab(name, icon, color, settings)
    self.tabs = self.tabs or {}
    local index = table.insert(self.tabs, {
        name = name,
        icon = icon,
        color = color,
        settings = settings
    })
    self.tabsByName = self.tabsByName or {}
    self.tabsByName[name] = index
    return self
end

function AddonHandler:GetTabByName(tabName)
    return self.tabs[self.tabsByName[tabName]]
end

function AddonHandler:AddButton(tabName, name, description, buttonText, onClick)
    local tabTbl = self:GetTabByName(tabName)
    if !tabTbl then ErrorNoHalt("[PIXELUI - Error] Unable to add button element to nil tab!") return end
    tabTbl.settings = tabTbl.settings or {}

    table.insert(tabTbl.settings, {
        type = "button",
        name = name,
        desc = description,
        buttonText = buttonText,
        onClick = onClick
    })

    return self
end

function AddonHandler:AddSlider(tabName, name, description, onSlide, startNum)
    local tabTbl = self:GetTabByName(tabName)
    if !tabTbl then ErrorNoHalt("[PIXELUI - Error] Unable to slide add element to nil tab!") return end
    tabTbl.settings = tabTbl.settings or {}

    table.insert(tabTbl.settings, {
        type = "slider",
        name = name,
        desc = description,
        num = startNum or 0,
        onSlide = onSlide
    })

    return self
end

function AddonHandler:AddCheckbox(tabName, name, description, onToggle, state)
    local tabTbl = self:GetTabByName(tabName)
    if !tabTbl then ErrorNoHalt("[PIXELUI - Error] Unable to slide add element to nil tab!") return end
    tabTbl.settings = tabTbl.settings or {}

    table.insert(tabTbl.settings, {
        type = "checkbox",
        name = name,
        desc = description,
        state = state or false,
        onToggle = onToggle
    })

    return self
end

function AddonHandler:AddComboBox(tabName, name, description, entries, entry, onSelect)
    local tabTbl = self:GetTabByName(tabName)
    if !tabTbl then ErrorNoHalt("[PIXELUI - Error] Unable to slide add element to nil tab!") return end
    tabTbl.settings = tabTbl.settings or {}

    table.insert(tabTbl.settings, {
        type = "combobox",
        name = name,
        desc = description,
        entries = entries,
        entry = entry or "",
        onSelect = onSelect
    })

    return self
end

function AddonHandler:AddTextEntry(tabName, name, description, text, updateOnType, onType)
    local tabTbl = self:GetTabByName(tabName)
    if !tabTbl then ErrorNoHalt("[PIXELUI - Error] Unable to slide add element to nil tab!") return end
    tabTbl.settings = tabTbl.settings or {}

    table.insert(tabTbl.settings, {
        type = "textEntry",
        name = name,
        desc = description,
        text = text,
        updateOnType = updateOnType or false,
        onType = onType
    })

    return self
end

function AddonHandler:AddValidatedTextEntry(tabName, name, description, text, updateOnType, onType, validateFunc)
    local tabTbl = self:GetTabByName(tabName)
    if !tabTbl then ErrorNoHalt("[PIXELUI - Error] Unable to slide add element to nil tab!") return end
    tabTbl.settings = tabTbl.settings or {}

    table.insert(tabTbl.settings, {
        type = "validatedTextEntry",
        name = name,
        desc = description,
        text = text,
        updateOnType = updateOnType or false,
        onType = onType,
        validateFunc = validateFunc
    })

    return self
end

function AddonHandler:Done()
    PIXEL.Configurator.Addons[self.name] = self
    PIXEL.Configurator.GeneratePanels(self.name, self)
end

PIXEL.RegisterAddon = AddonHandler.New

--[[
    table = {
        name = name
        version = version
        author
        url
        support
        dependencies = {
            addon = version
        },
        tabs = {
            [1] = {
                name = name,
                icon = icon,
                color = color
            }
        }
    }
--]]
function testShit()
PIXEL.RegisterAddon("Test Addon 1")
    :SetVersion("1.0")
    :SetAuthor("Lythium")
    :SetLogo("8bKjn4t")
    :SetURL("https://lythium.vip")
    :SetSupportURL("https://lythium.vip")
    :SetDependancy("PIXELUI", "any", true)

    :AddTab("Test Tab 1", "8bKjn4t", Color(255,255,255))
    :AddButton("Test Tab 1", "Test Button", "Test Description", "Button Text", function() print("Clicked!") end)
    :AddSlider("Test Tab 1", "Test Slider", "Test Description", function(num) print("Slide! " .. num) end, 50)
    :AddCheckbox("Test Tab 1", "Test Checkbox", "Test Description", function(check) print("Checked! " .. tostring(check)) end, true)
    :AddComboBox("Test Tab 1", "Test ComboBox", "Test Description", {
        [1] = {
            value = "Test1",
            icon = "kVbFLrX"
        },
        [2] = {
            value = "Test2",
            icon = "fd3MKOZ"
        },
        [3] = {
            value = "Test3",
            icon = "gPvSeuu"
        },
    }, "Test1", function(selected) print("Selected! " .. selected) end)
    :AddTextEntry("Test Tab 1", "Test Text Entry", "Test Description", "yo", true, function(text) print("Type! " .. text) end)
    :AddValidatedTextEntry("Test Tab 1", "Test Validated Text Entry", "Test Description", "yo", true,
    function(text)
        print("Type! " .. text)
    end,
    function(text)
        if text == "a" then
            return true
        else
            return false
        end
    end)
    :AddTab("Test Tab 2", "8bKjn4t")
    :AddTab("Test Tab 3", "8bKjn4t")
:Done()

PIXEL.RegisterAddon("Test Addon 2")
    :SetVersion("1.0")
    :SetAuthor("Lythium")
    :SetLogo("BpCb55H")
    :SetURL("https://lythium.vip")
    :SetSupportURL("https://lythium.vip")
    :SetDependancy("PIXELUI", "any", true)

    :AddTab("Test", "8bKjn4t")
    :AddTab("Test2", "8bKjn4t")
    :AddTab("Test3", "8bKjn4t")
:Done()
testShit2()

end

testShit()
