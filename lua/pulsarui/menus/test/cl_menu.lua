PulsarUI = PulsarUI or {}
local PANEL = {}

function PANEL:Init()
    self:SetSize(PulsarUI.Scale(900), PulsarUI.Scale(550))
    self:Center()
    self:MakePopup()
    self:SetTitle("PulsarUI Test")
    self.Sidebar = self:CreateSidebar("PulsarUI.Test.Avatar", "8bKjn4t")

    self.Sidebar:AddItem("PulsarUI.Test.Avatar", "Avatar", "8bKjn4t", function()
        self:ChangeTab("PulsarUI.Test.Avatar")
    end)

    self.Sidebar:AddItem("PulsarUI.Test.Buttons", "Buttons", "8bKjn4t", function()
        self:ChangeTab("PulsarUI.Test.Buttons")
    end)

    self.Sidebar:AddItem("PulsarUI.Test.Navigation", "Navigation", "8bKjn4t", function()
        self:ChangeTab("PulsarUI.Test.Navigation")
    end)

    self.Sidebar:AddItem("PulsarUI.Test.ScrollPanel", "ScrollPanel", "8bKjn4t", function()
        self:ChangeTab("PulsarUI.Test.ScrollPanel")
    end)

    self.Sidebar:AddItem("PulsarUI.Test.Text", "Text", "8bKjn4t", function()
        self:ChangeTab("PulsarUI.Test.Text")
    end)

    self.Sidebar:AddItem("PulsarUI.Test.Other", "Other", "8bKjn4t", function()
        self:ChangeTab("PulsarUI.Test.Other")
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

vgui.Register("PulsarUI.Test.Main", PANEL, "PulsarUI.Frame")

concommand.Add("pixel_test", function()
    PulsarUI.TestFrame = vgui.Create("PulsarUI.Test.Main")
end)
