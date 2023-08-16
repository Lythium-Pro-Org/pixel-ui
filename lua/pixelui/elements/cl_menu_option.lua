--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]
local PANEL = {}
AccessorFunc(PANEL, "m_pMenu", "Menu")
AccessorFunc(PANEL, "m_bChecked", "Checked")
AccessorFunc(PANEL, "m_bCheckable", "IsCheckable")
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Icon", "Icon", FORCE_STRING)
AccessorFunc(PANEL, "IconColor", "IconColor", FORCE_COLOR)
PIXEL.RegisterFont("UI.MenuOption", "Rubik", 18, 600)

function PANEL:Init()
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetFont("UI.MenuOption")
    self:SetChecked(false)
    self:SetIconColor(PIXEL.Colors.PrimaryText)
    self.NormalCol = PIXEL.Colors.Transparent
    self.HoverCol = PIXEL.Colors.Scroller
    self.BackgroundCol = PIXEL.CopyColor(self.NormalCol)
end

function PANEL:SetSubMenu(menu)
    self.SubMenu = menu
end

function PANEL:AddSubMenu()
    local subMenu = vgui.Create("PIXEL.Menu", self)
    subMenu:SetVisible(false)
    subMenu:SetParent(self)
    self:SetSubMenu(subMenu)

    return subMenu
end

function PANEL:OnCursorEntered()
    local parent = self.ParentMenu

    if not IsValid(parent) then
        parent = self:GetParent()
    end

    if not IsValid(parent) then return end
    if not parent.OpenSubMenu then return end
    parent:OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited()
end

function PANEL:Paint(w, h)
    if self.Hidden then return end
    self.BackgroundCol = PIXEL.LerpColor(FrameTime() * 12, self.BackgroundCol, self:IsHovered() and self.HoverCol or self.NormalCol)
    PIXEL.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)
    local iconSize = 0

    if self:GetIcon() then
        iconSize = self:GetTall() * .6
        PIXEL.DrawImgur(PIXEL.Scale(8), h / 2 - iconSize / 2, iconSize, iconSize, self:GetIcon(), self:GetIconColor())
    end

    PIXEL.DrawSimpleText(self:GetText(), self:GetFont(), PIXEL.Scale(14) + iconSize, h / 2, PIXEL.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    if not self.SubMenu then return end
    local dropBtnSize = PIXEL.Scale(8)
    PIXEL.DrawImgur(w - dropBtnSize - PIXEL.Scale(6), h / 2 - dropBtnSize / 2, dropBtnSize, dropBtnSize, "YTOZJoK", PIXEL.Colors.PrimaryText)
end

function PANEL:OnPressed(mousecode)
    self.m_MenuClicking = true
end

function PANEL:OnReleased(mousecode)
    if not self.m_MenuClicking and mousecode == MOUSE_LEFT then return end
    self.m_MenuClicking = false
    CloseDermaMenus()
end

function PANEL:DoRightClick()
    if self:GetIsCheckable() then
        self:ToggleCheck()
    end
end

function PANEL:DoClickInternal()
    if self:GetIsCheckable() then
        self:ToggleCheck()
    end

    if not self.m_pMenu then return end
    self.m_pMenu:OptionSelectedInternal(self)
end

function PANEL:ToggleCheck()
    self:SetChecked(not self:GetChecked())
    self:OnChecked(self:GetChecked())
end

function PANEL:OnChecked(enabled)
end

function PANEL:CalculateWidth()
    PIXEL.SetFont(self:GetFont())
    local textWide = PIXEL.GetTextSize(self:GetText())

    if self:GetIcon() then
        textWide = textWide + self:GetTall() * .6 + PIXEL.Scale(8)
    end

    return textWide + PIXEL.Scale(38)
end

function PANEL:PerformLayout(w, h)
    self:SetSize(math.max(self:CalculateWidth(), self:GetWide()), PIXEL.Scale(32))
end

vgui.Register("PIXEL.MenuOption", PANEL, "PIXEL.Button")
PANEL = {}
AccessorFunc(PANEL, "ConVar", "ConVar")
AccessorFunc(PANEL, "ValueOn", "ValueOn")
AccessorFunc(PANEL, "ValueOff", "ValueOff")

function PANEL:Init()
    self:SetChecked(false)
    self:SetIsCheckable(true)
    self:SetValueOn("1")
    self:SetValueOff("0")
end

function PANEL:Think()
    if not self.ConVar then return end
    self:SetChecked(GetConVar(self.ConVar):GetString() == self.ValueOn)
end

function PANEL:OnChecked(checked)
    if not self.ConVar then return end
    RunConsoleCommand(self.ConVar, checked and self.ValueOn or self.ValueOff)
end

vgui.Register("PIXEL.MenuOptionCVar", PANEL, "PIXEL.MenuOption")