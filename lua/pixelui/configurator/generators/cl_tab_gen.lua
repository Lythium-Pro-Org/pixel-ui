PIXEL.GenerateFont(20)
PIXEL.GenerateFont(22)

function PIXEL.Configurator.GenerateTab(tabName, tabInfo, addonTbl)
    local addonName = addonTbl.name
    local PANEL = {}

    function PANEL:Init()
        self.Created = false
        self.Option = {}
        self.ScrollPanel = vgui.Create("PIXEL.ScrollPanel", self)
        self.ScrollPanel:Dock(FILL)
        self.ScrollPanel:DockMargin(0, PIXEL.Scale(15), 0, 0)
    end

    local col = Color(60, 60, 60)

    function PANEL:CreateButton(id, data)
        self.Option[id] = vgui.Create("EditablePanel", self.ScrollPanel)
        self.Option[id]:Dock(TOP)
        self.Option[id]:DockMargin(PIXEL.Scale(15),PIXEL.Scale(5),PIXEL.Scale(15),PIXEL.Scale(5))
        self.Option[id]:SetTall(PIXEL.Scale(95))
        self.Option[id].Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(0, 0, h - PIXEL.Scale(2), w, PIXEL.Scale(2), col)
        end

        self.Option[id].Name = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Name:SetText(data.name)
        self.Option[id].Name:SetAutoWidth(true)
        self.Option[id].Name:SetFont("PIXEL.Font.Size22")

        self.Option[id].Button = vgui.Create("PIXEL.TextButton", self.Option[id])
        self.Option[id].Button:SetText(data.buttonText or "Button")
        self.Option[id].Button:SetY(self.Option[id].Name:GetY() + self.Option[id].Name:GetTall() + PIXEL.Scale(5))
        self.Option[id].Button.DoClick = function()
            if !data or !data.onClick or !isfunction(data.onClick) then return end
            data.onClick()
        end

        self.Option[id].Description = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Description:SetY(self.Option[id].Button:GetY() + self.Option[id].Button:GetTall() + PIXEL.Scale(7))
        self.Option[id].Description:SetText(data.desc)
        self.Option[id].Description:SetAutoWidth(true)
        self.Option[id].Description:SetFont("PIXEL.Font.Size20")
    end

    function PANEL:CreateSlider(id, data)
        self.Option[id] = vgui.Create("EditablePanel", self.ScrollPanel)
        self.Option[id]:Dock(TOP)
        self.Option[id]:DockMargin(PIXEL.Scale(15),PIXEL.Scale(5),PIXEL.Scale(15),PIXEL.Scale(5))
        self.Option[id]:SetTall(PIXEL.Scale(80))
        self.Option[id].Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(0, 0, h - PIXEL.Scale(2), w, PIXEL.Scale(2), col)
        end

        self.Option[id].Name = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Name:SetText(data.name)
        self.Option[id].Name:SetAutoWidth(true)
        self.Option[id].Name:SetFont("PIXEL.Font.Size22")

        self.Option[id].Slider = vgui.Create("PIXEL.Slider", self.Option[id])
        self.Option[id].Slider:SetWide(PIXEL.Scale(150))
        self.Option[id].Slider:SetTall(PIXEL.Scale(10))
        self.Option[id].Slider:SetY(self.Option[id].Name:GetY() + self.Option[id].Name:GetTall() + PIXEL.Scale(5))
        self.Option[id].Slider:SetX(PIXEL.Scale(5))
        self.Option[id].Slider.OnValueChanged = function(s, fraction)
            if !data or !data.onSlide or !isfunction(data.onSlide) then return end
            data.onSlide(math.Round(fraction, 3) * 100)
        end
        if data.num then
            self.Option[id].Slider.Fraction = data.num / 100
        end

        self.Option[id].Description = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Description:SetY(self.Option[id].Slider:GetY() + self.Option[id].Slider:GetTall() + PIXEL.Scale(10))
        self.Option[id].Description:SetText(data.desc)
        self.Option[id].Description:SetAutoWidth(true)
        self.Option[id].Description:SetFont("PIXEL.Font.Size20")
    end

    function PANEL:CreateCheckbox(id, data)
        self.Option[id] = vgui.Create("EditablePanel", self.ScrollPanel)
        self.Option[id]:Dock(TOP)
        self.Option[id]:DockMargin(PIXEL.Scale(15),PIXEL.Scale(5),PIXEL.Scale(15),PIXEL.Scale(5))
        self.Option[id]:SetTall(PIXEL.Scale(60))
        self.Option[id].Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(0, 0, h - PIXEL.Scale(2), w, PIXEL.Scale(2), col)
        end

        self.Option[id].Checkbox = vgui.Create("PIXEL.LabelledCheckbox", self.Option[id])
        self.Option[id].Checkbox:SetTall(PIXEL.Scale(10))
        self.Option[id].Checkbox:SetFont("PIXEL.Font.Size20")
        self.Option[id].Checkbox:SetText(data.name)
        self.Option[id].Checkbox.OnToggled = function(s, toggle)
            if !data or !data.onToggle or !isfunction(data.onToggle) then return end
            data.onToggle(toggle)
        end

        if data.state then
            self.Option[id].Checkbox.Checkbox:SetToggle(data.state)
        end

        self.Option[id].Description = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Description:SetY(self.Option[id].Checkbox:GetY() + self.Option[id].Checkbox:GetTall() + PIXEL.Scale(15))
        self.Option[id].Description:SetText(data.desc)
        self.Option[id].Description:SetAutoWidth(true)
        self.Option[id].Description:SetFont("PIXEL.Font.Size20")
    end

    function PANEL:CreateComboBox(id, data)
        self.Option[id] = vgui.Create("EditablePanel", self.ScrollPanel)
        self.Option[id]:Dock(TOP)
        self.Option[id]:DockMargin(PIXEL.Scale(15),PIXEL.Scale(5),PIXEL.Scale(15),PIXEL.Scale(5))
        self.Option[id]:SetTall(PIXEL.Scale(90))
        self.Option[id].Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(0, 0, h - PIXEL.Scale(2), w, PIXEL.Scale(2), col)
        end

        self.Option[id].Name = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Name:SetText(data.name)
        self.Option[id].Name:SetAutoWidth(true)
        self.Option[id].Name:SetFont("PIXEL.Font.Size22")

        self.Option[id].ComboBox = vgui.Create("PIXEL.ComboBox", self.Option[id])
        self.Option[id].ComboBox:SetTall(PIXEL.Scale(25))
        self.Option[id].ComboBox:SetSizeToText(false)
        self.Option[id].ComboBox:SetWide(PIXEL.Scale(100))
        self.Option[id].ComboBox:SetY(self.Option[id].Name:GetY() + self.Option[id].Name:GetTall() + PIXEL.Scale(5))

        if data.entries then
            for k, v in pairs(data.entries) do
                self.Option[id].ComboBox:AddChoice(v.value, v.value, false, v.icon)
            end
        end
        self.Option[id].ComboBox.OnSelect = function(s, i, v, d)
            if !data or !data.onSelect or !isfunction(data.onSelect) then return end
            data.onSelect(v)
        end

        if data.entry then
            self.Option[id].ComboBox:ChooseOption(data.entry)
        end

        self.Option[id].Description = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Description:SetY(self.Option[id].ComboBox:GetY() + self.Option[id].ComboBox:GetTall() + PIXEL.Scale(7))
        self.Option[id].Description:SetText(data.desc)
        self.Option[id].Description:SetAutoWidth(true)
        self.Option[id].Description:SetFont("PIXEL.Font.Size20")
    end

    function PANEL:CreateTextEntry(id, data)
        self.Option[id] = vgui.Create("EditablePanel", self.ScrollPanel)
        self.Option[id]:Dock(TOP)
        self.Option[id]:DockMargin(PIXEL.Scale(15),PIXEL.Scale(5),PIXEL.Scale(15),PIXEL.Scale(5))
        self.Option[id]:SetTall(PIXEL.Scale(95))
        self.Option[id].Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(0, 0, h - PIXEL.Scale(2), w, PIXEL.Scale(2), col)
        end

        self.Option[id].Name = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Name:SetText(data.name)
        self.Option[id].Name:SetAutoWidth(true)
        self.Option[id].Name:SetFont("PIXEL.Font.Size22")

        self.Option[id].TextEntry = vgui.Create("PIXEL.TextEntry", self.Option[id])
        self.Option[id].TextEntry:SetTall(PIXEL.Scale(30))
        self.Option[id].TextEntry:SetWide(PIXEL.Scale(150))
        self.Option[id].TextEntry:SetY(self.Option[id].Name:GetY() + self.Option[id].Name:GetTall() + PIXEL.Scale(5))

        if data.updateOnType then
            self.Option[id].TextEntry:SetUpdateOnType(true)
        end
        self.Option[id].TextEntry.OnValueChange = function(s, value)
            if !data or !data.onType or !isfunction(data.onType) then return end
            data.onType(value)
        end

        if data.text then
            self.Option[id].TextEntry.TextEntry:SetText(data.text)
        end

        self.Option[id].Description = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Description:SetY(self.Option[id].TextEntry:GetY() + self.Option[id].TextEntry:GetTall() + PIXEL.Scale(7))
        self.Option[id].Description:SetText(data.desc)
        self.Option[id].Description:SetAutoWidth(true)
        self.Option[id].Description:SetFont("PIXEL.Font.Size20")
    end

    function PANEL:CreateValidatedTextEntry(id, data)
        self.Option[id] = vgui.Create("EditablePanel", self.ScrollPanel)
        self.Option[id]:Dock(TOP)
        self.Option[id]:DockMargin(PIXEL.Scale(15),PIXEL.Scale(5),PIXEL.Scale(15),PIXEL.Scale(5))
        self.Option[id]:SetTall(PIXEL.Scale(95))
        self.Option[id].Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(0, 0, h - PIXEL.Scale(2), w, PIXEL.Scale(2), col)
        end

        self.Option[id].Name = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Name:SetText(data.name)
        self.Option[id].Name:SetAutoWidth(true)
        self.Option[id].Name:SetFont("PIXEL.Font.Size22")

        self.Option[id].TextEntry = vgui.Create("PIXEL.ValidatedTextEntry", self.Option[id])
        self.Option[id].TextEntry:SetTall(PIXEL.Scale(30))
        self.Option[id].TextEntry:SetWide(PIXEL.Scale(150))
        self.Option[id].TextEntry:SetY(self.Option[id].Name:GetY() + self.Option[id].Name:GetTall() + PIXEL.Scale(5))
        if data.updateOnType then
            self.Option[id].TextEntry.TextEntry:SetUpdateOnType(true)
        end
        self.Option[id].TextEntry.OnValueChange = function(s, value)
            if !data.validateFunc() then return false else return true end
            if !data or !data.onType or !isfunction(data.onType) then return end
            data.onType(value)
        end
        self.Option[id].TextEntry.IsTextValid = function(s, text)
            if !data.validateFunc(text) then return false else return true end
        end

        if data.text then
            self.Option[id].TextEntry.TextEntry:SetText(data.text)
        end

        self.Option[id].Description = vgui.Create("PIXEL.Label", self.Option[id])
        self.Option[id].Description:SetY(self.Option[id].TextEntry:GetY() + self.Option[id].TextEntry:GetTall() + PIXEL.Scale(7))
        self.Option[id].Description:SetText(data.desc)
        self.Option[id].Description:SetAutoWidth(true)
        self.Option[id].Description:SetFont("PIXEL.Font.Size20")
    end

    function PANEL:CreateType(id, data)
        local type = data.type
        if type == "button" then
            self:CreateButton(id, data)
        elseif type == "slider" then
            self:CreateSlider(id, data)
        elseif type == "checkbox" then
            self:CreateCheckbox(id, data)
        elseif type == "combobox" then
            self:CreateComboBox(id, data)
        elseif type == "textEntry" then
            self:CreateTextEntry(id, data)
        elseif type == "validatedTextEntry" then
            self:CreateValidatedTextEntry(id, data)
        end
    end

    function PANEL:PerformLayout(w, h)
        if self.Created then return end
        self.Created = true
        if !tabInfo.settings then return end
        for k, v in ipairs(tabInfo.settings) do
            self:CreateType(k, v)
        end
        self.ScrollPanel:Rebuild()
    end

    tabName = tabName:gsub(" ", "_")
    vgui.Register("PIXEL.Configurator." .. addonName .. ".Tab." .. tabName, PANEL)
end
