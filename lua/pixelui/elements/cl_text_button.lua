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
]]
local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextSpacing", "TextSpacing", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Icon", "Icon")
PIXEL.RegisterFont("UI.TextButton", "Rubik", 20, 600)

function PANEL:Init()
    self:SetText("Button")
    self:SetTextAlign(TEXT_ALIGN_CENTER)
    self:SetTextSpacing(PIXEL.Scale(6))
    self:SetFont("UI.TextButton")
    self:SetSize(PIXEL.Scale(100), PIXEL.Scale(30))
    self:SetIcon(false)
end

function PANEL:SizeToText()
    PIXEL.SetFont(self:GetFont())

    if self:GetIcon() then
        local iconSize = self:GetTall() * .6
        self:SetSize(PIXEL.GetTextSize(self:GetText()) + PIXEL.Scale(20) + iconSize, PIXEL.Scale(30))

        return
    end

    self:SetSize(PIXEL.GetTextSize(self:GetText()) + PIXEL.Scale(14), PIXEL.Scale(30))
end

function PANEL:PaintExtra(w, h)
    local textAlign = self:GetTextAlign()
    local textX = (textAlign == TEXT_ALIGN_CENTER and w / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - self:GetTextSpacing()) or self:GetTextSpacing()
    local iconSize = 0

    if self:GetIcon() then
        iconSize = self:GetTall() * .6
        PIXEL.DrawImgur(PIXEL.Scale(8), h / 2 - iconSize / 2, iconSize, iconSize, self:GetIcon(), PIXEL.Colors.PrimaryText)
        iconSize = iconSize + PIXEL.Scale(6)
    end

    if not self:IsEnabled() then
        PIXEL.DrawSimpleText(self:GetText(), self:GetFont(), textX + iconSize, h / 2, PIXEL.Colors.DisabledText, textAlign, TEXT_ALIGN_CENTER)

        return
    end

    PIXEL.DrawSimpleText(self:GetText(), self:GetFont(), textX + iconSize, h / 2, PIXEL.Colors.PrimaryText, textAlign, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.TextButton", PANEL, "PIXEL.Button")