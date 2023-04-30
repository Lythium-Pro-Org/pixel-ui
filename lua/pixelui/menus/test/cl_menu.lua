PIXEL = PIXEL or {}
local PANEL = {}

function PANEL:Init()
    self:SetSize(PIXEL.Scale(900), PIXEL.Scale(550))
    self:Center()
    self:MakePopup()
    self:SetTitle("PIXEL Test")
    self.Sidebar = self:CreateSidebar("PIXEL.Test.Avatar", "8bKjn4t")

    self.Sidebar:AddItem("PIXEL.Test.Avatar", "Avatar", "8bKjn4t", function()
        self:ChangeTab("PIXEL.Test.Avatar")
    end)

    self.Sidebar:AddItem("PIXEL.Test.Buttons", "Buttons", "8bKjn4t", function()
        self:ChangeTab("PIXEL.Test.Buttons")
    end)

    self.Sidebar:AddItem("PIXEL.Test.Navigation", "Navigation", "8bKjn4t", function()
        self:ChangeTab("PIXEL.Test.Navigation")
    end)

    self.Sidebar:AddItem("PIXEL.Test.ScrollPanel", "ScrollPanel", "8bKjn4t", function()
        self:ChangeTab("PIXEL.Test.ScrollPanel")
    end)

    self.Sidebar:AddItem("PIXEL.Test.Text", "Text", "8bKjn4t", function()
        self:ChangeTab("PIXEL.Test.Text")
    end)

    self.Sidebar:AddItem("PIXEL.Test.Other", "Other", "8bKjn4t", function()
        self:ChangeTab("PIXEL.Test.Other")
    end)
end

function PANEL:ChangeTab(panel)
    if not self.SideBar:IsMouseInputEnabled() then return end

    if not IsValid(self.ContentPanel) then
        self.ContentPanel = vgui.Create(panel, self)
        self.ContentPanel:Dock(FILL)
        self.ContentPanel:InvalidateLayout(true)

        function self.ContentPanel.Think(s)
            if not self.DragThink then return end
            if self:DragThink(self) then return end
            if self:SizeThink(self, s) then return end
            self:SetCursor("arrow")

            if self.y < 0 then
                self:SetPos(self.x, 0)
            end
        end

        function self.ContentPanel.OnMousePressed()
            self:OnMousePressed()
        end

        function self.ContentPanel.OnMouseReleased()
            self:OnMouseReleased()
        end

        return
    end

    self.SideBar:SetMouseInputEnabled(false)

    self.ContentPanel:AlphaTo(0, .15, 0, function(anim, pnl)
        self.ContentPanel:Remove()
        self.ContentPanel = vgui.Create(panel, self)
        self.ContentPanel:Dock(FILL)
        self.ContentPanel:InvalidateLayout(true)

        self.ContentPanel:AlphaTo(255, .15, 0, function(anim2, pnl2)
            self.SideBar:SetMouseInputEnabled(true)
        end)
    end)
end

function PANEL:PaintMore(w, h)
end

vgui.Register("PIXEL.Test.Main", PANEL, "PIXEL.Frame")

concommand.Add("pixel_test", function()
    PIXEL.TestFrame = vgui.Create("PIXEL.Test.Main")
end)
