local PANEL = {}
local sc = PIXEL.Scale

function PANEL:Init()
    self:SetSize(sc(200), sc(175))
    self:MakePopup()
    self:Center()

    self:SetTitle("Theme Changer")

    local panW, panH = self:GetSize()

    self.DropDown = self:Add("PIXEL.ComboBox")
    self.DropDown:SetPos((panW / 2) - (self.DropDown:GetWide() / 2), panH / 2 - sc(15))
    self.DropDown:SetSizeToText(false)

    for k, v in pairs(PIXEL.Themes) do
        self.DropDown:AddChoice(k, k, k)
    end
    self.DropDown:SetValue(LocalPlayer().PIXELTheme)

    local themeSelected
    function self.DropDown:OnSelect(index, text, data)
        themeSelected = data
    end

    self.Submit = self:Add("PIXEL.TextButton")
    self.Submit:Dock(BOTTOM)
    local dockMargin = sc(10)
    self.Submit:DockMargin(dockMargin, dockMargin, dockMargin, dockMargin)
    self.Submit:SetText("Submit")

    self.Submit.DoClick = function()
        PIXEL.SetTheme(themeSelected)
        self:Close()
        notification.AddLegacy("PIXELUI: Theme changed to " .. themeSelected, 0, 3)
    end
end

function PANEL:PaintOver(w, h)
    PIXEL.DrawSimpleText("Select new theme:", "Lyth_Pulsar.Font.Size20", w / 2, self.DropDown:GetY() - sc(15), PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXELUI.ThemeChanger", PANEL, "PIXEL.Frame")

concommand.Add("pixel_change_theme", function()
    local ThemeChanger
    if not ThemeChanger then
        ThemeChanger = vgui.Create("PIXELUI.ThemeChanger")
    else
        ThemeChanger:Close()
        ThemeChanger = vgui.Create("PIXELUI.ThemeChanger")
    end
end)