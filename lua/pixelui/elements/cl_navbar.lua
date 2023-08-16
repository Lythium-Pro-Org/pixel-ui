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
AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID")
AccessorFunc(PANEL, "ImgurScale", "ImgurScale")
AccessorFunc(PANEL, "Selected", "Selected", FORCE_BOOL)
PIXEL.RegisterFont("UI.NavbarItem", "Rubik", 22, 600)

function PANEL:SetColor(col)
    self.BackgroundCol = PIXEL.Colors.Transparent
    self.BackgroundHoverCol = ColorAlpha(col, 40)
    self.BackgroundSelectCol = ColorAlpha(col, 80)
end

function PANEL:Init()
    self:SetName("N/A")
    self:SetColor(PIXEL.Colors.Primary)
    self:SetImgurScale(0.2)
    self.NormalCol = PIXEL.Colors.PrimaryText
    self.HoverCol = PIXEL.Colors.SecondaryText
    self.TextCol = PIXEL.CopyColor(self.NormalCol)
    self.BackgroundCol = PIXEL.Colors.Transparent
    self.BackgroundHoverCol = ColorAlpha(PIXEL.Colors.Primary, 40)
    self.BackgroundSelectCol = ColorAlpha(PIXEL.Colors.Primary, 80)
end

function PANEL:GetItemSize()
    PIXEL.SetFont("UI.NavbarItem")

    return PIXEL.GetTextSize(self:GetName())
end

function PANEL:Paint(w, h)
    local textCol = self.NormalCol
    local backgroundCol = self.BackgroundCol

    if self:IsHovered() then
        textCol = self.HoverCol
        backgroundCol = self.BackgroundHoverCol
    end

    if self:IsDown() or self:GetToggle() then
        backgroundCol = self.BackgroundSelectCol
    end

    local animTime = FrameTime() * 12
    self.TextCol = PIXEL.LerpColor(animTime, self.TextCol, textCol)
    local imgurID = self:GetImgurID()

    if imgurID then
        local imageSize = w * self:GetImgurScale()
        PIXEL.DrawImgur(0, (self:GetTall() / 2) - (imageSize / 2), imageSize, imageSize, imgurID, color_white)
        PIXEL.DrawSimpleText(self:GetName(), "UI.NavbarItem", imageSize + PIXEL.Scale(3), h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        return
    end

    local boxW, boxH = w - PIXEL.Scale(16), h - PIXEL.Scale(16)
    PIXEL.DrawRoundedBox(8, PIXEL.Scale(8), PIXEL.Scale(8), boxW, boxH, backgroundCol)
    PIXEL.DrawSimpleText(self:GetName(), "UI.NavbarItem", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.NavbarItem", PANEL, "PIXEL.Button")
PANEL = {}

function PANEL:Init()
    self.Items = {}
    self.SelectionX = 0
    self.SelectionW = 0
    self.SelectionColor = Color(0, 0, 0)
    self.BackgroundCol = PIXEL.Colors.Header
end

function PANEL:AddItem(id, name, doClick, order, color, imgurID)
    local btn = vgui.Create("PIXEL.NavbarItem", self)
    btn:SetImgurID(imgurID)
    btn:SetName(name)
    btn:SetZPos(order or table.Count(self.Items) + 1)
    btn:SetColor((IsColor(color) and color) or PIXEL.Colors.Primary)
    btn.Function = doClick

    btn.DoClick = function(s)
        self:SelectItem(id)
    end

    self.Items[id] = btn
end

function PANEL:RemoveItem(id)
    local item = self.Items[id]
    if not item then return end
    item:Remove()
    self.Items[id] = nil
    if self.SelectedItem ~= id then return end
    self:SelectItem(next(self.Items))
end

function PANEL:SelectItem(id)
    local item = self.Items[id]
    if not item then return end
    if self.SelectedItem and self.SelectedItem == id then return end
    item:SetSelected(false)
    self.SelectedItem = id

    for k, v in pairs(self.Items) do
        v:SetToggle(false)
    end

    item:SetToggle(true)
    item.Function(item)
    item:SetSelected(true)
end

function PANEL:PerformLayout(w, h)
    self:DockMargin(PIXEL.Scale(8), PIXEL.Scale(8), PIXEL.Scale(8), PIXEL.Scale(8))

    for k, v in pairs(self.Items) do
        v:Dock(LEFT)
        v:SetWide(v:GetItemSize() + PIXEL.Scale(50))
    end
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)

    if not self.SelectedItem then
        self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionW = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionColor = PIXEL.LerpColor(FrameTime() * 10, self.SelectionColor, PIXEL.Colors.Primary)

        return
    end
end

vgui.Register("PIXEL.Navbar", PANEL, "Panel")