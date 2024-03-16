--- @class PulsarUI.Avatar : Panel
--- @field SetRounded fun(self: PulsarUI.Avatar, value: number)
--- @field GetRounded fun(self: PulsarUI.Avatar): number
--- @field SetMaskSize fun(self: PulsarUI.Avatar, value: number) This function does nothing and will be removed in the future.
--- @field GetMaskSize fun(self: PulsarUI.Avatar): number This function does nothing and will be removed in the future.
--- @field Avatar AvatarImage
local PANEL = {}
AccessorFunc(PANEL, "Rounded", "Rounded", FORCE_NUMBER)
AccessorFunc(PANEL, "MaskSize", "MaskSize", FORCE_NUMBER)

function PANEL:Init()
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)

    self:SetRounded(PulsarUI.Scale(8))
end

function PANEL:PerformLayout(w, h)
    self.Avatar:SetSize(w, h)
end

--- Set the player to draw the avatar from
--- @param ply Player
--- @param size number The resolution of the avatar. Allowed values are 32, 64, 184
function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
end

--- Set the steam id to draw the avatar from
--- @param id string
--- @param size number The resolution of the avatar. Allowed values are 32, 64, 184
function PANEL:SetSteamID(id, size)
    self.Avatar:SetSteamID(id, size)
end

function PANEL:Paint(w, h)
    PulsarUI.Mask(
        function()
            PulsarUI.DrawFullRoundedBox(self:GetRounded(), 0, 0, w, h, color_white)
        end,
        function()
            self.Avatar:PaintManual()
        end
    )
end

vgui.Register("PulsarUI.Avatar", PANEL, "Panel")