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
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "ImageSize", "ImageSize", FORCE_NUMBER)
AccessorFunc(PANEL, "NormalColor", "NormalColor")
AccessorFunc(PANEL, "HoverColor", "HoverColor")
AccessorFunc(PANEL, "ClickColor", "ClickColor")
AccessorFunc(PANEL, "DisabledColor", "DisabledColor")
AccessorFunc(PANEL, "FrameEnabled", "FrameEnabled")
AccessorFunc(PANEL, "Rounded", "Rounded", FORCE_NUMBER)

function PANEL:Init()
    self.ImageCol = PIXEL.CopyColor(color_white)
    self:SetImgurID("w72Iz3n")
    self:SetNormalColor(color_white)
    self:SetHoverColor(color_white)
    self:SetClickColor(color_white)
    self:SetDisabledColor(color_white)
    self:SetImageSize(1)
    self:SetFrameEnabled(false)
end

function PANEL:PaintBackground(w, h)
end

function PANEL:Paint(w, h)
    self:PaintBackground(w, h)

    if self:IsHovered() and self:GetFrameEnabled() then
        PIXEL.DrawRoundedBox(self:GetRounded(), 0, 0, w, h, self:GetHoverColor())
    end

    local imageSize = h * self:GetImageSize()
    local imageOffset = (h / 2) - (imageSize / 2)

    if self:GetFrameEnabled() then
        imageSize = imageSize * .45
        imageOffset = (h / 2) - (imageSize / 2) + PIXEL.Scale(1)
    end

    if not self:IsEnabled() then
        PIXEL.DrawImgur(imageOffset, imageOffset, imageSize, imageSize, self:GetImgurID(), self:GetDisabledColor())

        return
    end

    local col = self:GetNormalColor()

    if self:IsHovered() and not self:GetFrameEnabled() then
        col = self:GetHoverColor()
    end

    if self:IsDown() or self:GetToggle() then
        col = self:GetClickColor()
    end

    self.ImageCol = PIXEL.LerpColor(FrameTime() * 12, self.ImageCol, col)
    PIXEL.DrawImgur(imageOffset, imageOffset, imageSize, imageSize, self:GetImgurID(), self.ImageCol)
end

vgui.Register("PIXEL.ImgurButton", PANEL, "PIXEL.Button")