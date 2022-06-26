local PANEL = {}
local sc = PIXEL.Scale
PIXEL.GenerateFont(18)
function PANEL:Init()
    self:SetSize(sc(200), sc(200))
    self:MakePopup()
    self:Center()

    self:SetTitle("Theme Changer")

    local panW, panH = self:GetSize()

    self.DropDown = self:Add("PIXEL.ComboBox")
    self.DropDown:SetPos((panW / 2) - (self.DropDown:GetWide() / 2), panH / 2 - sc(35))
    self.DropDown:SetSizeToText(false)

    for k, v in pairs(PIXEL.Themes) do
        self.DropDown:AddChoice(k, k, k)
    end
    self.DropDown:SetValue(LocalPlayer().PIXELTheme)


    self.SaveCross = self:Add("PIXEL.LabelledCheckbox")
    self.SaveCross:SetPos((panW / 2) - (self.SaveCross:GetWide() / 2) - sc(50), panH / 2 + sc(10))
    self.SaveCross:SetText("Save Across Servers?")
    self.SaveCross:SetFont("PIXEL.Font.Size18")
    local crossServer = false
    if not table.HasValue(PIXEL.DefaultThemes, LocalPlayer().PIXELTheme) then
        self.SaveCross.Checkbox:SetEnabled(false)
        crossServer = false
    end


    local themeSelected = LocalPlayer().PIXELTheme

    function self.DropDown:OnSelect(index, text, data)
        themeSelected = data
        if PIXEL.Themes[themeSelected].included then
            self:GetParent().SaveCross.Checkbox:SetEnabled(true)
            crossServer = true
        else
            self:GetParent().SaveCross.Checkbox:SetEnabled(false)
            crossServer = false
        end
    end

    self.Submit = self:Add("PIXEL.TextButton")
    self.Submit:Dock(BOTTOM)
    local dockMargin = sc(10)
    self.Submit:DockMargin(dockMargin, dockMargin, dockMargin, dockMargin)
    self.Submit:SetText("Submit")

    self.Submit.DoClick = function()
        PIXEL.SetTheme(themeSelected, crossServer)
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