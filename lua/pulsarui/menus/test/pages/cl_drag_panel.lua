PulsarUI = PulsarUI or {}
local sc = PulsarUI.Scale
local PANEL = {}

function PANEL:Init()
    self.DragPanel = vgui.Create("PulsarUI.DragPanel", self)
    self.DragPanel:Dock(FILL)
    self.DragPanel:DockMargin(0, 0, 0, 0)

    local buttonsCount = 100

    local inner = self.DragPanel:GetInner()

    for i = 0, buttonsCount do
        local size = math.random(50, 200)
        self.ImageButton = vgui.Create("PulsarUI.ImageButton", inner)
        self.ImageButton:SetImageURL("https://pixel-cdn.lythium.dev/i/pixellogo")
        self.ImageButton:SetMouseInputEnabled(false)
        self.ImageButton:SetSize(size, size)
        self.ImageButton:SetPos(x, y)
    end

    inner.LayoutContent = function(s, w, h)
        for k, v in pairs(inner:GetChildren()) do
            local x = math.random(0, w)
            local y = math.random(0, h)

            v:SetPos(x, y)
        end
    end
end

function PANEL:PaintMore(w, h)
end

vgui.Register("PulsarUI.Test.DragPanel", PANEL)