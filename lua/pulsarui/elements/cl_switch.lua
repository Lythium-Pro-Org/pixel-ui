--- @class PulsarUI.Switch :EditablePanel
--- @field SetSide fun(self: PulsarUI.Switch, value: "LEFT"|"RIGHT")
--- @field GetSide fun(self: PulsarUI.Switch): "LEFT"|"RIGHT"
local PANEL = {}

AccessorFunc(PANEL, "Side", "Side", FORCE_NUMBER)

function PANEL:Init()
    self.Switch = vgui.Create("PulsarUI.Button", self)
    self.Switch:SetIsToggle(true)

    self.BackgroundCol = PulsarUI.CopyColor(PulsarUI.Colors.Header)

    self.ActiveCol = PulsarUI.Colors.Positive
    self.InactiveCol = PulsarUI.OffsetColor(PulsarUI.Colors.Header, 10)

    self.SwitchCol = PulsarUI.CopyColor(self.InactiveCol)

    self.Switch.Paint = function(s, w, h)
        local backgroundW, backgroundH = w, h * .7
        PulsarUI.DrawRoundedBox(backgroundH / 2, PulsarUI.Scale1440(2), PulsarUI.Scale1440(2), backgroundW, backgroundH, self.BackgroundCol)

        local col = self.InactiveCol
        local targetSwitchX = PulsarUI.Scale1440(12)

        if s:GetToggle() then
            col = self.ActiveCol
            targetSwitchX = w - h
        end

        self.SwitchCol = PulsarUI.LerpColor(FrameTime() * 12, self.SwitchCol, col)

        -- Add a lerp for switchX
        self.switchX = Lerp(FrameTime() * 12, self.switchX or targetSwitchX, targetSwitchX)

        local switchSize = h
        PulsarUI.DrawRoundedBox(switchSize / 2, self.switchX, 0, switchSize, switchSize, self.SwitchCol)
    end
end

function PANEL:PerformLayout(w, h)
    self.Switch:SetSize(h * 2, h)
    self.Switch:AlignLeft(0)
    self.Switch:CenterVertical()
end


vgui.Register("PulsarUI.Switch", PANEL, "EditablePanel")