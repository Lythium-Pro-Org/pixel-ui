PIXEL = PIXEL or {}
local sc = PIXEL.Scale
local PANEL = {}

function PANEL:Init()
    self.Navbar = vgui.Create("PIXEL.Navbar", self)
    self.Navbar:Dock(TOP)
    self.Navbar:SetTall(sc(50))

    self.Navbar:AddItem("test1", "Test 1", function()
        notification.AddLegacy("Clicked 1!", NOTIFY_GENERIC, 5)
    end, 1, PIXEL.Colors.Gold)

    self.Navbar:AddItem("test2", "Test 2", function()
        notification.AddLegacy("Clicked 2!", NOTIFY_GENERIC, 5)
    end, 2, PIXEL.Colors.Diamond)

    self.Navbar:AddItem("test3", "Test 3", function()
        notification.AddLegacy("Clicked 3!", NOTIFY_GENERIC, 5)
    end, 3, PIXEL.Colors.Silver)

    self.Navbar:AddItem("test4", "Test 4", function()
        notification.AddLegacy("Clicked 4!", NOTIFY_GENERIC, 5)
    end, 4, PIXEL.Colors.Bronze)

    self.Navbar:AddItem("test5", "Test 5", function()
        notification.AddLegacy("Clicked 5!", NOTIFY_GENERIC, 5)
    end, 5, PIXEL.Colors.Primary)
end

function PANEL:PaintMore(w, h)
end

vgui.Register("PIXEL.Test.Navigation", PANEL)