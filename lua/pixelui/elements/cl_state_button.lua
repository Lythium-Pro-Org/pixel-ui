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
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextSpacing", "TextSpacing", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "State", "State")

function PANEL:Init()
    self.States = {
        ["default"] = {
            Color = PIXEL.Colors.PrimaryText,
            Icon = nil
        },
        ["loading"] = {
            Color = PIXEL.Colors.PrimaryText,
            Icon = nil
        },
        ["disabled"] = {
            Color = PIXEL.Colors.PrimaryText,
            Icon = "3myjhEM"
        },
        ["success"] = {
            Color = PIXEL.Colors.Positive,
            Icon = "Qf8Owl7"
        },
        ["failed"] = {
            Color = PIXEL.Colors.Negative,
            Icon = "qHORTll"
        }
    }

    self:SetState("default")
    self.StateColor = PIXEL.Colors.PrimaryText
end

function PANEL:SetState(state)
    if not self.States[state] then
        state = "default"
    end

    self.State = state
    self.StateColor = self.States[state].Color
    self:SetIcon(self.States[state].Icon)

    if state == ("success" or "failed") then
        timer.Simple(1.5, function()
            if IsValid(self) then
                self.FadeOut = true
            end
        end)
    end
end

function PANEL:PaintExtra(w, h)
    local textAlign = self:GetTextAlign()
    local textX = (textAlign == TEXT_ALIGN_CENTER and w / 2) or (textAlign == TEXT_ALIGN_RIGHT and w - self:GetTextSpacing()) or self:GetTextSpacing()
    local iconSize = self:GetTall() * .6

    if self:GetIcon() and self:GetState() ~= "loading" then
        PIXEL.DrawImgur(PIXEL.Scale(8), h / 2 - iconSize / 2, iconSize, iconSize, self:GetIcon(), self.StateColor)
        textX = textX + PIXEL.Scale(8)
    elseif self:GetState() == "loading" then
        PIXEL.DrawProgressWheel(PIXEL.Scale(8), h / 2 - iconSize / 2, iconSize, iconSize, PIXEL.Colors.PrimaryText)
        textX = textX + PIXEL.Scale(8)
    end

    if not self:IsEnabled() then
        PIXEL.DrawSimpleText(self:GetText(), self:GetFont(), textX + iconSize, h / 2, PIXEL.Colors.DisabledText, textAlign, TEXT_ALIGN_CENTER)

        return
    end

    PIXEL.DrawSimpleText(self:GetText(), self:GetFont(), textX, h / 2, PIXEL.Colors.PrimaryText, textAlign, TEXT_ALIGN_CENTER)
end

function PANEL:Think()
    if not self.FadeOut then return end
    self.StateColor = PIXEL.LerpColor(FrameTime() * 16, self.StateColor, Color(255, 255, 255, 0))

    if self.StateColor.a <= 10 then
        self:SetState("default")
        self.FadeOut = false
        self.StateColor = PIXEL.Colors.PrimaryText
    end
end

vgui.Register("PIXEL.StateButton", PANEL, "PIXEL.TextButton")