
--[[
PIXEL UI
Copyright (C) 2021 Tom O'Sullivan (Tom.bat)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local PANEL = {}
AccessorFunc(PANEL, "ConVarRed", "ConVarR")
AccessorFunc(PANEL, "ConVarGreen", "ConVarG")
AccessorFunc(PANEL, "ConVarBlue", "ConVarBlue")
AccessorFunc(PANEL, "ConVarAlpha", "ConVarAlpha")
AccessorFunc(PANEL, "AlphaBarEnabled", "AlphaBar", FORCE_BOOL)
AccessorFunc(PANEL, "ShowTextEntries", "ShowTextEntries", FORCE_BOOL)
AccessorFunc(PANEL, "Color", "Color")
PIXEL.RegisterFont("UI.ColorPickerWang", "Rubik", 14)

function PANEL:UpdateRGBEntryValues(panel, num, rgbType)
    if panel.Forced then return end
    local targetValue = tonumber(num) or 0

    self:GetColor()[rgbType] = targetValue

    self.ColorCube:SetColor(self:GetColor())
    local pos = self.RGBPicker:GetColorPos(self.ColorCube:GetBaseRGB())
    self.RGBPicker:SetRGB(self.ColorCube:GetBaseRGB())
    self.RGBPicker.LastX = pos

    self:UpdateColor(self:GetColor())
end

function PANEL:UpdateNumberEntries(color)
    self.RedEntry:SetValue(color.r)
    self.GreenEntry:SetValue(color.g)
    self.BlueEntry:SetValue(color.b)
end

function PANEL:Init()
    self:SetShowTextEntries(true)
    self:SetSize(PIXEL.Scale(256), PIXEL.Scale(230))

    self.RGBAPanel = vgui.Create("Panel", self)
    self.RGBAPanel:Dock(BOTTOM)
    self.RGBAPanel:DockMargin(0, PIXEL.Scale(10), 0, PIXEL.Scale(10))
    self.RGBAPanel:SetTall(PIXEL.Scale(35))

    self.RedEntry = self.RGBAPanel:Add("PIXEL.NumberEntry")
    self.RedEntry:SetMin(0)
    self.RedEntry:SetMax(255)
    self.RedEntry:SetTall(PIXEL.Scale(25))
    self.RedEntry:SetWide(PIXEL.Scale(60))
    self.RedEntry:SetFont("UI.ColorPickerWang", true)
    self.RedEntry.OutlineCol = Color(238, 75, 43)

    self.GreenEntry = self.RGBAPanel:Add("PIXEL.NumberEntry")
    self.GreenEntry:SetMin(0)
    self.GreenEntry:SetMax(255)
    self.GreenEntry:SetTall(PIXEL.Scale(25))
    self.GreenEntry:SetWide(PIXEL.Scale(60))
    self.GreenEntry.TextEntry:SetFont("UI.ColorPickerWang", true)
    self.GreenEntry.OutlineCol = Color(170, 255, 0)

    self.BlueEntry = self.RGBAPanel:Add("PIXEL.NumberEntry")
    self.BlueEntry:SetMin(0)
    self.BlueEntry:SetMax(255)
    self.BlueEntry:SetTall(PIXEL.Scale(25))
    self.BlueEntry.TextEntry:SetFont("UI.ColorPickerWang", true)
    self.BlueEntry.OutlineCol = Color(0, 100, 255)

    self.AlphaEntry = self.RGBAPanel:Add("PIXEL.NumberEntry")
    self.AlphaEntry:SetMin(0)
    self.AlphaEntry:SetMax(255)
    self.AlphaEntry:SetTall(PIXEL.Scale(25))
    self.AlphaEntry:SetWide(PIXEL.Scale(60))
    self.AlphaEntry.TextEntry:SetFont("UI.ColorPickerWang", true)

    self.RGBAPanel.PerformLayout = function(s, w, h)
        local boxH = PIXEL.Scale(30)
        self.RedEntry:SetTall(boxH)
        self.GreenEntry:SetTall(boxH)
        self.BlueEntry:SetTall(boxH)

        if self.AlphaBarEnabled then
            self.AlphaEntry:SetTall(boxH)

            local boxW = (w / 4) - (PIXEL.Scale(5) * 4)

            self.RedEntry:SetWide(boxW)
            self.GreenEntry:SetWide(boxW)
            self.BlueEntry:SetWide(boxW)
            self.AlphaEntry:SetWide(boxW)

            for i = 1, 4 do
                local x = (boxW + PIXEL.Scale(5)) * (i - 1)

                self.RGBAPanel:GetChildren()[i]:SetPos(x, 0)
            end
        else
            local boxW = (w / 3) - (PIXEL.Scale(5) * 2)

            self.RedEntry:SetWide(boxW)
            self.GreenEntry:SetWide(boxW)
            self.BlueEntry:SetWide(boxW)

            for i = 1, 3 do
                local x = (boxW + PIXEL.Scale(5)) * (i - 1)

                self.RGBAPanel:GetChildren()[i]:SetPos(x, 0)
            end
        end
    end

    self.ColorCube = vgui.Create("PIXEL.ColorCube", self)
    self.ColorCube:Dock(FILL)

    self.ColorCube.OnUserChanged = function(ctrl, color)
        color.a = self:GetColor().a
        self:UpdateColor(color)
    end

    self.RGBPicker = vgui.Create("PIXEL.RGBPicker", self)
    self.RGBPicker:Dock(BOTTOM)
    self.RGBPicker:SetTall(PIXEL.Scale(20))
    self.RGBPicker:DockMargin(0, PIXEL.Scale(10), 0, 0)
    self.RGBPicker:SetRGB(Color(255, 0, 0))

    self.RGBPicker.OnChange = function(ctrl, color)
        self:SetBaseColor(color)
        self:UpdateNumberEntries(color)
    end

    self.AlphaBar = vgui.Create("PIXEL.AlphaBar", self)
    self.AlphaBar:Dock(BOTTOM)
    self.AlphaBar:SetTall(PIXEL.Scale(20))
    self.AlphaBar:DockMargin(0, PIXEL.Scale(10), 0, 0)

    self.AlphaBar.OnChange = function(ctrl, alpha)
        self:GetColor().a = math.floor(alpha * 255)
        self:UpdateColor(self:GetColor())
    end

    self:SetColor(Color(255, 0, 0, 255))


    -- RGB Picker Changes
    self.RedEntry.OnValueChanged = function(s, str)
        self:UpdateRGBEntryValues(s, str, "r")
    end

    self.GreenEntry.OnValueChanged = function(s, str)
        self:UpdateRGBEntryValues(s, str, "g")
    end

    self.BlueEntry.OnValueChanged = function(s, str)
        self:UpdateRGBEntryValues(s, str, "b")
    end

    self.AlphaEntry.OnValueChanged = function(s, str)
        if s.Forced then return end
        local targetValue = tonumber(num) or 0

        local color = targetValue
        self:GetColor()[type] = color

        self.AlphaBar:SetBarColor(ColorAlpha(color, 255))
        self.AlphaBar:SetValue(targetValue / 255)

        self:UpdateColor(color)
    end

    self:SetAlphaBar(true)
    self:InvalidateLayout()
end

function PANEL:SetAlphaBar(enabled)
    self.AlphaBarEnabled = enabled

    if IsValid(self.AlphaBar) then
        self.AlphaBar:SetVisible(enabled)
    end

    if IsValid(self.AlphaEntry) then
        self.AlphaEntry:SetVisible(enabled)
    end
    self:InvalidateLayout()
end

function PANEL:SetShowRGBA(enabled)
    self:SetShowTextEntries(enabled)
    self.RGBAPanel:SetVisible(enabled)
    self:InvalidateLayout()
end

function PANEL:SetConVarR(cvar)
    self.ConVarRed = cvar
end

function PANEL:SetConVarG(cvar)
    self.ConVarGreen = cvar
end

function PANEL:SetConVarB(cvar)
    self.ConVarBlue = cvar
end

function PANEL:SetConVarA(cvar)
    self.ConVarAlpha = cvar
    self:SetAlphaBar(cvar ~= nil)
end

function PANEL:PerformLayout()
    local h, s, v = ColorToHSV(self.ColorCube:GetBaseRGB())
    self.RGBPicker.LastY = (PIXEL.Scale(1) - h / PIXEL.Scale(360)) * self.RGBPicker:GetWide()
end

function PANEL:TranslateValues(x, y)
end

function PANEL:SetColor(color)
    local h, s, v = ColorToHSV(color)
    self.RGBPicker.LastY = (PIXEL.Scale(1) - h / PIXEL.Scale(360)) * self.RGBPicker:GetTall()
    self.ColorCube:SetColor(color)
    self:UpdateColor(color)
end

function PANEL:SetVector(vec)
    self:SetColor(Color(vec.x * 255, vec.y * 255, vec.z * 255, 255))
end

function PANEL:SetBaseColor(color)
    self.ColorCube:SetBaseRGB(color)
    self.ColorCube:TranslateValues()
end

function PANEL:UpdateConVar(name, key, color)
    if not name then return end

    local col = color[key]
    RunConsoleCommand(name, tostring(col))
    self["ConVarOld" .. name] = col
end

function PANEL:UpdateConVars(color)
    self.NextConVarCheck = SysTime() + 0.2
    self:UpdateConVar(self.ConVarRed, 'r', color)
    self:UpdateConVar(self.ConVarGreen, 'g', color)
    self:UpdateConVar(self.ConVarBlue, 'b', color)
    self:UpdateConVar(self.ConVarAlpha, 'a', color)
end

function PANEL:UpdateColor(color)
    self.AlphaBar:SetBarColor(ColorAlpha(color, 255))
    self.AlphaBar:SetValue(color.a / 255)

    if color.r ~= self.RedEntry:GetValue() then
        self.RedEntry.Forced = true
        self.RedEntry:SetValue(color.r)
        self.RedEntry.Forced = nil
    end

    if color.g ~= self.GreenEntry:GetValue() then
        self.GreenEntry.Forced = true
        self.GreenEntry:SetValue(color.r)
        self.GreenEntry.Forced = nil
    end

    if color.b ~= self.BlueEntry:GetValue() then
        self.BlueEntry.Forced = true
        self.BlueEntry:SetValue(color.r)
        self.BlueEntry.Forced = nil
    end

    if color.a ~= self.AlphaEntry:GetValue() then
        self.AlphaEntry.Forced = true
        self.AlphaEntry:SetValue(color.r)
        self.AlphaEntry.Forced = nil
    end

    self:UpdateConVars(color)
    self:ValueChanged(color)
    self.Color = color
end

function PANEL:ValueChanged(color)
end

function PANEL:GetColor()
    self.Color.a = 255

    if self.AlphaBar:IsVisible() then
        self.Color.a = self.AlphaBar:GetAlpha()
    end

    return self.Color
end

function PANEL:GetVector()
    local col = self:GetColor()

    return Vector(col.r / 255, col.g / 255, col.b / 255)
end

function PANEL:Think()
    self:ConVarThink()
end

function PANEL:ConVarThink()
    if input.IsMouseDown(MOUSE_LEFT) then return end

    if self.NextConVarCheck > SysTime() then return end

    local r, changed_r = self:DoConVarThink(self.ConVarRed)
    local g, changed_g = self:DoConVarThink(self.ConVarGreen)
    local b, changed_b = self:DoConVarThink(self.ConVarBlue)
    local a, changed_a = 255, false

    if self.ConVarAlpha then
        a, changed_a = self:DoConVarThink(self.ConVarAlpha, "a")
    end

    if changed_r or changed_g or changed_b or changed_a then
        self:SetColor(Color(r, g, b, a))
    end
end

function PANEL:DoConVarThink(convar)
    if not convar then return end

    local value = GetConVar(convar):GetInt()
    local oldValue = self["ConVarOld" .. convar]

    if oldValue and value == oldValue then
        return oldValue, false
    end

    self["ConVarOld" .. convar] = value

    return value, true
end

vgui.Register("PIXEL.ColorPickerV2", PANEL, "EditablePanel")