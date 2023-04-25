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
AccessorFunc(PANEL, "Draggable", "Draggable", FORCE_BOOL)
AccessorFunc(PANEL, "Sizable", "Sizable", FORCE_BOOL)
AccessorFunc(PANEL, "MinWidth", "MinWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "MinHeight", "MinHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "ScreenLock", "ScreenLock", FORCE_BOOL)
AccessorFunc(PANEL, "RemoveOnClose", "RemoveOnClose", FORCE_BOOL)
AccessorFunc(PANEL, "SlideOut", "SlideOut", FORCE_BOOL)
AccessorFunc(PANEL, "SlideDirection", "SlideDirection", FORCE_NUMBER) -- 1 = up, 2 = right, 3 = down, 4 = left
AccessorFunc(PANEL, "SlideTime", "SlideTime", FORCE_NUMBER)
AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
PIXEL.RegisterFont("UI.FrameTitle", "Rubik", 20, 700)

function PANEL:Init()
    self.CloseButton = vgui.Create("PIXEL.ImgurButton", self)
    self.CloseButton:SetImgurID("z1uAU0b")
    self.CloseButton:SetNormalColor(PIXEL.Colors.PrimaryText)
    self.CloseButton:SetHoverColor(PIXEL.Colors.Negative)
    self.CloseButton:SetClickColor(PIXEL.Colors.Negative)
    self.CloseButton:SetDisabledColor(PIXEL.Colors.DisabledText)
    self.CloseButton:SetFrameEnabled(true)
    self.CloseButton:SetRounded(PIXEL.Scale(8))

    self.CloseButton.DoClick = function(s)
        self:Close()
    end

    self:SetSlideOut(false)
    self.ExtraButtons = {}
    self:SetTitle("PIXEL Frame")
    self:SetDraggable(true)
    self:SetScreenLock(true)
    self:SetRemoveOnClose(true)
    local size = PIXEL.Scale(200)
    self:SetMinWidth(size)
    self:SetMinHeight(size)
    local oldMakePopup = self.MakePopup

    function self:MakePopup()
        oldMakePopup(self)
        self:Open()
    end
end

function PANEL:DragThink(targetPanel, hoverPanel)
    local scrw, scrh = ScrW(), ScrH()
    local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

    if targetPanel.Dragging then
        local x = mousex - targetPanel.Dragging[1]
        local y = mousey - targetPanel.Dragging[2]

        if targetPanel:GetScreenLock() then
            x = math.Clamp(x, 0, scrw - targetPanel:GetWide())
            y = math.Clamp(y, 0, scrh - targetPanel:GetTall())
        end

        targetPanel:SetPos(x, y)
    end

    local _, screenY = targetPanel:LocalToScreen(0, 0)

    if (hoverPanel or targetPanel).Hovered and targetPanel:GetDraggable() and mousey < (screenY + PIXEL.Scale(30)) then
        targetPanel:SetCursor("sizeall")

        return true
    end
end

function PANEL:SizeThink(targetPanel, hoverPanel)
    local scrw, scrh = ScrW(), ScrH()
    local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

    if targetPanel.Sizing then
        local x = mousex - targetPanel.Sizing[1]
        local y = mousey - targetPanel.Sizing[2]
        local px, py = targetPanel:GetPos()
        local screenLock = self:GetScreenLock()

        if x < targetPanel.MinWidth then
            x = targetPanel.MinWidth
        elseif x > scrw - px and screenLock then
            x = scrw - px
        end

        if y < targetPanel.MinHeight then
            y = targetPanel.MinHeight
        elseif y > scrh - py and screenLock then
            y = scrh - py
        end

        targetPanel:SetSize(x, y)
        targetPanel:SetCursor("sizenwse")

        return true
    end

    local screenX, screenY = targetPanel:LocalToScreen(0, 0)

    if (hoverPanel or targetPanel).Hovered and targetPanel.Sizable and mousex > (screenX + targetPanel:GetWide() - PIXEL.Scale(20)) and mousey > (screenY + targetPanel:GetTall() - PIXEL.Scale(20)) then
        (hoverPanel or targetPanel):SetCursor("sizenwse")

        return true
    end
end

function PANEL:Think()
    if self:DragThink(self) then return end
    if self:SizeThink(self) then return end
    self:SetCursor("arrow")

    if self.y < 0 then
        self:SetPos(self.x, 0)
    end
end

function PANEL:OnMousePressed()
    local screenX, screenY = self:LocalToScreen(0, 0)
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()

    if self.Sizable and mouseX > (screenX + self:GetWide() - PIXEL.Scale(30)) and mouseY > (screenY + self:GetTall() - PIXEL.Scale(30)) then
        self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}

        self:MouseCapture(true)

        return
    end

    if self:GetDraggable() and mouseY < (screenY + PIXEL.Scale(30)) then
        self.Dragging = {mouseX - self.x, mouseY - self.y}

        self:MouseCapture(true)

        return
    end
end

function PANEL:OnMouseReleased()
    self.Dragging = nil
    self.Sizing = nil
    self:MouseCapture(false)
end

function PANEL:CreateSidebar(defaultItem, imgurID, imgurScale, imgurYOffset, buttonYOffset)
    if IsValid(self.SideBar) then return end
    self.SideBar = vgui.Create("PIXEL.Sidebar", self)

    if defaultItem then
        timer.Simple(0, function()
            if not IsValid(self.SideBar) then return end
            self.SideBar:SelectItem(defaultItem)
        end)
    end

    if imgurID then
        self.SideBar:SetImgurID(imgurID)
    end

    if imgurScale then
        self.SideBar:SetImgurScale(imgurScale)
    end

    if imgurYOffset then
        self.SideBar:SetImgurOffset(imgurYOffset)
    end

    if buttonYOffset then
        self.SideBar:SetButtonOffset(buttonYOffset)
    end

    return self.SideBar
end

function PANEL:AddHeaderButton(elem, size)
    elem.HeaderIconSize = size or .45

    return table.insert(self.ExtraButtons, elem)
end

function PANEL:LayoutContent(w, h)
end

function PANEL:Open()
    PIXEL.PlayButtonSound()
    self:SetVisible(false)
    self:SetAlpha(0)
    self:SetVisible(true)
    self:AlphaTo(255, .1, 0)
end

function PANEL:Close()
    if not self:GetSlideOut() then
        self:AlphaTo(0, .1, 0, function(anim, pnl)
            if not IsValid(pnl) then return end
            pnl:SetVisible(false)
            pnl:OnClose()

            if pnl:GetRemoveOnClose() then
                pnl:Remove()
            end
        end)

        return
    end

    local scrw, scrh, wide, tall, posY = ScrW(), ScrH(), self:GetWide(), self:GetTall(), self:GetY()

    local slideDirections = {
        [1] = {
            x = (scrw / 2) - (wide / 2),
            y = -tall,
            size = function()
                self:SizeTo(wide, 0, (self:GetSlideTime() - 0.2) or .3, 0, -1)
            end
        },
        -- up
        [2] = {
            x = scrw,
            y = posY,
            size = function() end
        },
        -- right
        [3] = {
            x = (scrw / 2) - (wide / 2),
            y = scrh + tall,
            size = function() end
        },
        -- down
        [4] = {
            x = -wide,
            y = posY,
            size = function() end
        },
    }

    -- left
    local direction = self:GetSlideDirection() or 1
    slideDirections[direction].size()

    self:MoveTo(slideDirections[direction].x, slideDirections[direction].y, self:GetSlideTime() or .5, 0, -1, function(anim, pnl)
        if not IsValid(pnl) then return end
        pnl:SetVisible(false)
        pnl:OnClose()

        if pnl:GetRemoveOnClose() then
            pnl:Remove()
        end
    end)
end

function PANEL:OnClose()
end

function PANEL:PerformLayout(w, h)
    self.HeaderH = PIXEL.Scale(30)
    local btnPad = PIXEL.Scale(12)
    local btnSpacing = PIXEL.Scale(12)

    if IsValid(self.CloseButton) then
        local btnSize = self.HeaderH
        self.CloseButton:SetSize(btnSize, btnSize)
        self.CloseButton:SetPos(w - btnSize, (self.HeaderH - btnSize) / 2)
        btnPad = btnPad + btnSize + btnSpacing
    end

    for _, btn in ipairs(self.ExtraButtons) do
        local btnSize = self.HeaderH * btn.HeaderIconSize
        btn:SetSize(btnSize, btnSize)
        btn:SetPos(w - btnSize - btnPad, (self.HeaderH - btnSize) / 2)
        btnPad = btnPad + btnSize + btnSpacing
    end

    if IsValid(self.SideBar) then
        self.SideBar:SetPos(0, self.HeaderH)
        self.SideBar:SetSize(PIXEL.Scale(200), h - self.HeaderH)
    end

    self.ContentPadding = PIXEL.Scale(8)
    self:DockPadding(self.SideBar and PIXEL.Scale(200) or self.ContentPadding, self.HeaderH + self.ContentPadding, self.ContentPadding, self.ContentPadding)
    self:LayoutContent(w, h)
end

function PANEL:PaintHeader(x, y, w, h)
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(8), x, y, w, h, PIXEL.Colors.Header, true, true)
    local imgurID = self:GetImgurID()

    if imgurID then
        local iconSize = h * .6
        PIXEL.DrawImgur(PIXEL.Scale(6), x + (h - iconSize) / 2, y + iconSize, iconSize, imgurID, color_white)
        PIXEL.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + PIXEL.Scale(12) + iconSize, y + h / 2, PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)

        return
    end

    PIXEL.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + PIXEL.Scale(12), y + h / 2, PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function PANEL:PaintMore(w, h)
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(8), 0, 0, w, h, PIXEL.Colors.Header)
    local contentX, contentY = self.SideBar and PIXEL.Scale(200) or self.ContentPadding, self.HeaderH + self.ContentPadding
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(8), contentX, contentY, w - contentX - self.ContentPadding, h - contentY - self.ContentPadding, PIXEL.Colors.Background, true, true, true, true)
    self:PaintHeader(0, 0, w, self.HeaderH)
    self:PaintMore(w, h)
end

vgui.Register("PIXEL.Frame", PANEL, "EditablePanel")