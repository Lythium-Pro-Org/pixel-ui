--[[
	PulsarUI - Copyright Notice
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
]]
local PANEL = {}
AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "DrawOutline", "DrawOutline", FORCE_BOOL)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated

AccessorFunc(PANEL, "GradientEnabled", "GradientEnabled", FORCE_BOOL)
AccessorFunc(PANEL, "GradientColor", "GradientColor", FORCE_COLOR)
AccessorFunc(PANEL, "GradientColorLeft", "GradientColorLeft", FORCE_COLOR)
AccessorFunc(PANEL, "GradientColorRight", "GradientColorRight", FORCE_COLOR)

function PANEL:SetGradientColor(col)
	assert(type(col) == "table", "bad argument #1 to 'SetGradientColor' (table expected, got " .. type(col) .. ")")
	self:SetGradientColorLeft(col)
	local offsetCol = PulsarUI.OffsetColor(col, -40)
	self:SetGradientColorRight(offsetCol)
end

function PANEL:SetGradientColorLeft(color)
	self.GradientColorLeft = color
	self.GradientColorLeftHover = ColorAlpha(color, color.a - 30)
	self.GradientColorLeftSelect = ColorAlpha(color, color.a - 40)
end

function PANEL:SetGradientColorRight(color)
	self.GradientColorRight = color
	self.GradientColorRightHover = ColorAlpha(color, color.a - 30)
	self.GradientColorRightSelect = ColorAlpha(color, color.a - 40)
end

PulsarUI.RegisterFont("SidebarItem", "Rubik", 19, 600)

function PANEL:Init()
	self:SetName("N/A")
	self:SetDrawOutline(true)
	self:SetGradientColor(PulsarUI.Colors.Primary)
	self.TextCol = PulsarUI.CopyColor(PulsarUI.Colors.SecondaryText)
	self.BackgroundCol = PulsarUI.CopyColor(PulsarUI.Colors.Transparent)
	self.BackgroundHoverCol = ColorAlpha(PulsarUI.Colors.Primary, 40)
	self.BackgroundSelectCol = ColorAlpha(PulsarUI.Colors.Primary, 80)
end

function PANEL:Paint(w, h)
	local textCol = PulsarUI.Colors.SecondaryText
	local backgroundCol = PulsarUI.Colors.Transparent
	local leftGradCol = PulsarUI.Colors.Transparent
	local rightGradCol = PulsarUI.Colors.Transparent

	local gradientEnabled = self:GetGradientEnabled()

	if self:IsHovered() then
		textCol = PulsarUI.Colors.PrimaryText
		backgroundCol = self.BackgroundHoverCol

		if gradientEnabled then
			leftGradCol = self.GradientColorLeftHover
			rightGradCol = self.GradientColorRightHover
		end
	end

	if self:IsDown() or self:GetToggle() then
		textCol = PulsarUI.Colors.PrimaryText
		backgroundCol = self.BackgroundSelectCol

		if gradientEnabled then
			leftGradCol = self.GradientColorLeftSelect
			rightGradCol = self.GradientColorRightSelect
		end
	end

	local animTime = FrameTime() * 24
	self.TextCol = PulsarUI.LerpColor(animTime, self.TextCol, textCol)
	self.BackgroundCol = PulsarUI.LerpColor(animTime, self.BackgroundCol, backgroundCol)

	if gradientEnabled then
		self.GradientColorLeft = PulsarUI.LerpColor(animTime, self.GradientColorLeft, leftGradCol)
		self.GradientColorRight = PulsarUI.LerpColor(animTime, self.GradientColorRight, rightGradCol)
	end

	if self:GetDrawOutline() and gradientEnabled then
		PulsarUI.Mask(function()
			PulsarUI.DrawFullRoundedBox(8, 0, 0, w, h, color_white)
		end, function()
			local lX, lY = self:LocalToScreen()
			PulsarUI.DrawSimpleLinearGradient(lX, lY, w, h, self.GradientColorLeft, self.GradientColorRight, true)
		end)
	elseif self:GetDrawOutline() then
		PulsarUI.DrawRoundedBox(8, 0, 0, w, h, self.BackgroundCol)
	end

	local imageURL = self:GetImageURL()
	if imageURL then
		local iconSize = h * .65
		PulsarUI.DrawImage(PulsarUI.Scale(10), (h - iconSize) / 2, iconSize, iconSize, imageURL, self.TextCol)
		PulsarUI.DrawSimpleText(self:GetName(), "SidebarItem", PulsarUI.Scale(20) + iconSize, h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		return
	end

	PulsarUI.DrawSimpleText(self:GetName(), "SidebarItem", PulsarUI.Scale(10), h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("PulsarUI.SidebarItem", PANEL, "PulsarUI.Button")

PANEL = {}
AccessorFunc(PANEL, "ImageURL", "ImageURL", FORCE_STRING)
AccessorFunc(PANEL, "ImageScale", "ImageScale", FORCE_NUMBER)
AccessorFunc(PANEL, "ImageOffset", "ImageOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "ButtonOffset", "ButtonOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "GradientEnabled", "GradientEnabled", FORCE_BOOL)

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING) -- Deprecated
AccessorFunc(PANEL, "ImgurScale", "ImgurScale", FORCE_NUMBER) -- Deprecated
AccessorFunc(PANEL, "ImgurOffset", "ImgurOffset", FORCE_NUMBER) -- Deprecated

function PANEL:SetImgurID(id)
	assert(type(id) == "string", "bad argument #1 to 'SetImgurID' (string expected, got " .. type(id) .. ")")
	print("[PulsarUI] PulsarUI.Sidebar:SetImgurID is deprecated, use PulsarUI.Sidebar:SetImageURL instead")
	self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
	self.ImgurID = id
end

function PANEL:GetImgurID()
	print("[PulsarUI] PulsarUI.Sidebar:GetImgurID is deprecated, use PulsarUI.Sidebar:GetImageURL instead")
	return (self:GetImageURL() or ""):match("https://i.imgur.com/(.-).png")
end

function PANEL:SetImgurScale(scale)
	assert(type(scale) == "number", "bad argument #1 to 'SetImgurScale' (number expected, got " .. type(scale) .. ")")
	print("[PulsarUI] PulsarUI.Sidebar:SetImgurScale is deprecated, use PulsarUI.Sidebar:SetImageScale instead")
	self:SetImageScale(scale)
	self.ImgurScale = scale
end

function PANEL:GetImgurScale()
	print("[PulsarUI] PulsarUI.Sidebar:GetImgurScale is deprecated, use PulsarUI.Sidebar:GetImageScale instead")
	return self:GetImageScale()
end

function PANEL:SetImgurOffset(offset)
	assert(type(offset) == "number", "bad argument #1 to 'SetImgurOffset' (number expected, got " .. type(offset) .. ")")
	print("[PulsarUI] PulsarUI.Sidebar:SetImgurOffset is deprecated, use PulsarUI.Sidebar:SetImageOffset instead")
	self:SetImageOffset(offset)
	self.ImgurOffset = offset
end

function PANEL:GetImgurOffset()
	print("[PulsarUI] PulsarUI.Sidebar:GetImgurOffset is deprecated, use PulsarUI.Sidebar:GetImageOffset instead")
	return self:GetImageOffset()
end

function PANEL:Init()
	self.Items = {}
	self.Scroller = vgui.Create("PulsarUI.ScrollPanel", self)
	self.Scroller:SetBarDockShouldOffset(true)

	self.Scroller.LayoutContent = function(s, w, h)
		local spacing = PulsarUI.Scale(8)
		local height = PulsarUI.Scale(35)

		for k, v in pairs(self.Items) do
			v:SetTall(height)
			v:Dock(TOP)
			v:DockMargin(0, 0, 0, spacing)
		end
	end

	self:SetImageScale(.6)
	self:SetImageOffset(0)
	self:SetButtonOffset(0)

	self.BackgroundCol = PulsarUI.CopyColor(PulsarUI.Colors.Header)
end

function PANEL:AddItem(id, name, imageURL, doClick, order)
	local btn = vgui.Create("PulsarUI.SidebarItem", self.Scroller)
	btn:SetZPos(order or table.Count(self.Items) + 1)
	btn:SetName(name)

	if imageURL then
		local imgurMatch = (imageURL or ""):match("^[a-zA-Z0-9]+$")
		if imgurMatch then
			imageURL = "https://i.imgur.com/" .. imageURL .. ".png"
		end

		btn:SetImageURL(imageURL)
	end

	btn.Function = doClick

	btn.DoClick = function(s)
		self:SelectItem(id)
	end

	self.Items[id] = btn

	return btn
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
	self.SelectedItem = id

	for k, v in pairs(self.Items) do
		v:SetToggle(false)
	end

	item:SetToggle(true)
	item.Function(item)
end

function PANEL:PerformLayout(w, h)
	local sideSpacing = PulsarUI.Scale(7)
	local topSpacing = PulsarUI.Scale(7)
	self:DockPadding(sideSpacing, self:GetImageURL() and w * self:GetImageScale() + self:GetImageOffset() + self:GetButtonOffset() + topSpacing * 2 or topSpacing, sideSpacing, topSpacing)
	self.Scroller:Dock(FILL)
	self.Scroller:GetCanvas():DockPadding(0, 0, self.Scroller.VBar.Enabled and sideSpacing or 0, 0)
end

function PANEL:Paint(w, h)
	PulsarUI.DrawRoundedBoxEx(PulsarUI.Scale(6), 0, 0, w, h, self.BackgroundCol, false, false, true)

	local imageURL = self:GetImageURL()
	if imageURL then
		local imageSize = w * self:GetImageScale()
		PulsarUI.DrawImage((w - imageSize) / 2, self:GetImageOffset() + PulsarUI.Scale(15), imageSize, imageSize, imageURL, color_white)
	end
end

vgui.Register("PulsarUI.Sidebar", PANEL, "Panel")