---@diagnostic disable: inject-field
---@class PulsarUI.ColorMixer : EditablePanel
---@field SetConVarR fun(self: PulsarUI.ColorMixer, cvar: string)
---@field GetConVarR fun(self: PulsarUI.ColorMixer): string
---@field SetConVarG fun(self: PulsarUI.ColorMixer, cvar: string)
---@field GetConVarG fun(self: PulsarUI.ColorMixer): string
---@field SetConVarB fun(self: PulsarUI.ColorMixer, cvar: string)
---@field GetConVarB fun(self: PulsarUI.ColorMixer): string
---@field SetConVarA fun(self: PulsarUI.ColorMixer, cvar: string)
---@field GetConVarA fun(self: PulsarUI.ColorMixer): string
---@field SetWangs fun(self: PulsarUI.ColorMixer, bEnabled: boolean)
---@field GetWangs fun(self: PulsarUI.ColorMixer): boolean
---@field SetColor fun(self: PulsarUI.ColorMixer, color: Color)
---@field GetColor fun(self: PulsarUI.ColorMixer): Color
local PANEL = {}

AccessorFunc(PANEL, "m_ConVarR", "ConVarR")
AccessorFunc(PANEL, "m_ConVarG", "ConVarG")
AccessorFunc(PANEL, "m_ConVarB", "ConVarB")
-- AccessorFunc(PANEL, "m_ConVarA", "ConVarA")
-- AccessorFunc(PANEL, "m_bAlpha", "AlphaBar", FORCE_BOOL)
AccessorFunc(PANEL, "m_bWangsPanel", "Wangs", FORCE_BOOL)
AccessorFunc(PANEL, "m_Color", "Color")

PulsarUI.RegisterFont("UI.ColorMixer.NumberEntry", "Rubik", 12, 500)

local function CreateWangFunction(self, colindex)
    local function OnValueChanged(ptxt, strvar)
        if (ptxt.notuserchange) then return end

        local targetValue = tonumber(strvar) or 0
        self:GetColor()[colindex] = targetValue
        -- if (colindex == "a") then
        --     self.Alpha:SetBarColor(ColorAlpha(self:GetColor(), 255))
        --     self.Alpha:SetValue(targetValue / 255)
        -- else
        --     self.HSV:SetColor(self:GetColor())

        --     local h, _, _ = ColorToHSV(self.HSV:GetBaseRGB())
        --     self.RGB.LastY = (1 - h / 360) * self.RGB:GetTall()
        -- end
        self.HSV:SetColor(self:GetColor())

        local h, _, _ = ColorToHSV(self.HSV:GetBaseRGB())
        self.RGB.LastY = (1 - h / 360) * self.RGB:GetTall()

        self:UpdateColor(self:GetColor())
    end

    return OnValueChanged
end

function PANEL:Init()
    -- The label
    self.Label = vgui.Create("PulsarUI.Label", self)
    self.Label:SetText("")
    self.Label:Dock(TOP)
    self.Label:SetTextColor(PulsarUI.Colors.PrimaryText)
    self.Label:SetVisible(false)

    --The number stuff
    self.WangsPanel = vgui.Create("Panel", self)
    self.WangsPanel:SetWide(PulsarUI.Scale(50))
    self.WangsPanel:Dock(RIGHT)
    self.WangsPanel:DockMargin(PulsarUI.Scale(4), 0, 0, 0)
    self:SetWangs(true)

    ---@class PulsarUI.NumberEntry
    self.RedInput = self.WangsPanel:Add("PulsarUI.NumberEntry")
    self.RedInput:SetMin(0)
    self.RedInput:SetMax(255)
    self.RedInput:SetTall(PulsarUI.Scale(24))
    self.RedInput:Dock(TOP)
    self.RedInput:DockMargin(0, 0, 0, 0)
    self.RedInput.TextEntry:SetFont("UI.ColorMixer.NumberEntry", true)
    self.RedInput.FocusedOutlineCol = Color(240, 100, 100)

    ---@class PulsarUI.NumberEntry
    self.GreenInput = self.WangsPanel:Add("PulsarUI.NumberEntry")
    self.GreenInput:SetMin(0)
    self.GreenInput:SetMax(255)
    self.GreenInput:SetTall(PulsarUI.Scale(24))
    self.GreenInput:Dock(TOP)
    self.GreenInput:DockMargin(0, PulsarUI.Scale(4), 0, 0)
    self.GreenInput.TextEntry:SetFont("UI.ColorMixer.NumberEntry", true)
    self.GreenInput.FocusedOutlineCol = Color(120, 240, 100)

    ---@class PulsarUI.NumberEntry
    self.BlueInput = self.WangsPanel:Add("PulsarUI.NumberEntry")
    self.BlueInput:SetMin(0)
    self.BlueInput:SetMax(255)
    self.BlueInput:SetTall(PulsarUI.Scale(24))
    self.BlueInput:Dock(TOP)
    self.BlueInput:DockMargin(0, PulsarUI.Scale(4), 0, 0)
    self.BlueInput.TextEntry:SetFont("UI.ColorMixer.NumberEntry", true)
    self.BlueInput.FocusedOutlineCol = Color(100, 109, 239)

    -- ---@class PulsarUI.NumberEntry
    -- self.AlphaInput = self.WangsPanel:Add("PulsarUI.NumberEntry")
    -- self.AlphaInput:SetMin(0)
    -- self.AlphaInput:SetMax(255)
    -- self.AlphaInput:SetTall(PulsarUI.Scale(24))
    -- self.AlphaInput:Dock(TOP)
    -- self.AlphaInput:DockMargin(0, PulsarUI.Scale(4), 0, 0)
    -- self.AlphaInput.TextEntry:SetFont("UI.ColorMixer.NumberEntry", true)
    -- self.AlphaInput.FocusedOutlineCol = Color(221, 221, 221)

    self.RedInput.OnValueChanged = CreateWangFunction(self, "r")
    self.GreenInput.OnValueChanged = CreateWangFunction(self, "g")
    self.BlueInput.OnValueChanged = CreateWangFunction(self, "b")
    -- self.AlphaInput.OnValueChanged = CreateWangFunction(self, "a")

    -- The colouring stuff
    self.HSV = vgui.Create("PulsarUI.ColorCube", self)
    self.HSV:Dock(FILL)
    self.HSV.OnUserChanged = function(ctrl, color)
        color.a = self:GetColor().a
        self:UpdateColor(color)
    end

    ---@class EditablePanel
    self.RGBEntryContainer = vgui.Create("EditablePanel", self)
    self.RGBEntryContainer:Dock(BOTTOM)
    self.RGBEntryContainer:SetTall(PulsarUI.Scale(32))
    self.RGBEntryContainer:DockMargin(0, PulsarUI.Scale(4), 0, 0)

    ---@class EditablePanel
    self.ColorPreview = vgui.Create("EditablePanel", self.RGBEntryContainer)
    self.ColorPreview.Paint = function(_, w, h)
        PulsarUI.DrawRoundedBox(h / 2, 0, 0, w, h, self:GetColor())
    end

    ---@class PulsarUI.RGBPicker
    self.RGB = vgui.Create("PulsarUI.RGBPicker", self.RGBEntryContainer)
    self.RGB.OnChange = function(ctrl, color)
        self:SetBaseColor(color)
    end

    self.RGBEntryContainer.PerformLayout = function(_, w, h)
        self.ColorPreview:SetSize(h, h)

        self.RGB:SetSize(w - h - PulsarUI.Scale(4), h - PulsarUI.Scale(12))
        self.RGB:SetPos(h + PulsarUI.Scale(4), PulsarUI.Scale(6))
    end

    ---TODO: Alpha Bar
    -- self.Alpha = vgui.Create("DAlphaBar", self)
    -- self.Alpha:DockMargin(4, 0, 0, 0)
    -- self.Alpha:Dock(RIGHT)
    -- self.Alpha:SetWidth(BarWide)
    -- self.Alpha.OnChange = function(ctrl, fAlpha)
    --     self:GetColor().a = math.floor(fAlpha * 255)
    --     self:UpdateColor(self:GetColor())
    -- end
    -- self:SetAlphaBar(true)

    -- Layout
    self:SetColor(Color(255, 0, 0))
    self:SetSize(256, 230)
    self:InvalidateLayout()
end

function PANEL:SetLabel(text)
    if (! text or text == "") then
        self.Label:SetVisible(false)

        return
    end

    self.Label:SetText(text)
    self.Label:SetVisible(true)

    self:InvalidateLayout()
end

-- function PANEL:SetAlphaBar(bEnabled)
--     self.m_bAlpha = bEnabled

--     self.Alpha:SetVisible(bEnabled)
--     self.AlphaInput:SetVisible(bEnabled)

--     self:InvalidateLayout()
-- end

function PANEL:SetWangs(bEnabled)
    self.m_bWangsPanel = bEnabled

    self.WangsPanel:SetVisible(bEnabled)

    self:InvalidateLayout()
end

function PANEL:SetConVarR(cvar)
    self.m_ConVarR = cvar
end

function PANEL:SetConVarG(cvar)
    self.m_ConVarG = cvar
end

function PANEL:SetConVarB(cvar)
    self.m_ConVarB = cvar
end

-- function PANEL:SetConVarA(cvar)
--     self.m_ConVarA = cvar
--     self:SetAlphaBar(cvar != nil)
-- end

function PANEL:PerformLayout(w, h)
    local hue, _, _ = ColorToHSV(self.HSV:GetBaseRGB())
    self.RGB.LastY = (1 - hue / 360) * self.RGB:GetTall()
end

function PANEL:Paint()
    -- Invisible background!
end

function PANEL:SetColor(color)
    local hue, _, _ = ColorToHSV(color)
    self.RGB.LastY = (1 - hue / 360) * self.RGB:GetTall()

    self.HSV:SetColor(color)

    self:UpdateColor(color)
end

function PANEL:SetVector(vec)
    self:SetColor(Color(vec.x * 255, vec.y * 255, vec.z * 255, 255))
end

function PANEL:SetBaseColor(color)
    self.HSV:SetBaseRGB(color)
    self.HSV:TranslateValues()
end

function PANEL:UpdateConVar(strName, strKey, color)
    if (! strName) then return end
    local col = color[strKey]

    RunConsoleCommand(strName, tostring(col))

    self["ConVarOld" .. strName] = col
end

function PANEL:UpdateConVars(color)
    self.NextConVarCheck = SysTime() + 0.2

    self:UpdateConVar(self.m_ConVarR, 'r', color)
    self:UpdateConVar(self.m_ConVarG, 'g', color)
    self:UpdateConVar(self.m_ConVarB, 'b', color)
    -- self:UpdateConVar(self.m_ConVarA, 'a', color)
end

function PANEL:UpdateColor(color)
    -- self.Alpha:SetBarColor(ColorAlpha(color, 255))
    -- self.Alpha:SetValue(color.a / 255)

    if (color.r != self.RedInput:GetValue()) then
        self.RedInput.notuserchange = true
        self.RedInput:SetValue(color.r)
        self.RedInput.notuserchange = nil
    end

    if (color.g != self.GreenInput:GetValue()) then
        self.GreenInput.notuserchange = true
        self.GreenInput:SetValue(color.g)
        self.GreenInput.notuserchange = nil
    end

    if (color.b != self.BlueInput:GetValue()) then
        self.BlueInput.notuserchange = true
        self.BlueInput:SetValue(color.b)
        self.BlueInput.notuserchange = nil
    end

    -- if (color.a != self.AlphaInput:GetValue()) then
    --     self.AlphaInput.notuserchange = true
    --     self.AlphaInput:SetValue(color.a)
    --     self.AlphaInput.notuserchange = nil
    -- end

    self:UpdateConVars(color)
    self:ValueChanged(color)

    self.m_Color = color
end

function PANEL:ValueChanged(color)
    -- Override
end

function PANEL:GetColor()
    self.m_Color.a = 255
    -- if (self.Alpha:IsVisible()) then
    --     self.m_Color.a = math.floor(self.Alpha:GetValue() * 255)
    -- end

    return self.m_Color
end

function PANEL:GetVector()
    local col = self:GetColor()
    return Vector(col.r / 255, col.g / 255, col.b / 255)
end

function PANEL:Think()
    self:ConVarThink()
end

function PANEL:ConVarThink()
    -- Don't update the convars while we're changing them!
    if (input.IsMouseDown(MOUSE_LEFT)) then return end
    if (self.NextConVarCheck > SysTime()) then return end

    local r, changed_r = self:DoConVarThink(self.m_ConVarR)
    local g, changed_g = self:DoConVarThink(self.m_ConVarG)
    local b, changed_b = self:DoConVarThink(self.m_ConVarB)
    -- local a, changed_a = 255, false

    -- if (self.m_ConVarA) then
    --     a, changed_a = self:DoConVarThink(self.m_ConVarA)
    -- end

    if (changed_r or changed_g or changed_b) then
        self:SetColor(Color(r, g, b, 255))
    end
end

function PANEL:DoConVarThink(convar)
    if (!convar) then return 255, false end

    local fValue = GetConVar(convar):GetInt()
    local fOldValue = self["ConVarOld" .. convar]
    if (fOldValue and fValue == fOldValue) then return fOldValue, false end

    self["ConVarOld" .. convar] = fValue

    return fValue, true
end

function PANEL:GenerateExample(ClassName, PropertySheet, Width, Height)
    local ctrl = vgui.Create(ClassName)
    ctrl:SetSize(256, 256)

    PropertySheet:AddSheet(ClassName, ctrl, nil, true, true)
end

vgui.Register("PulsarUI.ColorMixer", PANEL, "EditablePanel")
