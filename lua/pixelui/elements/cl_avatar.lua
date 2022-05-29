local PANEL = {}

AccessorFunc(PANEL, "Rounding", "Rounding", FORCE_NUMBER)

function PANEL:Init()
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)

    self.CirclePoly = {}
    self:SetRounding(10)
end

function PANEL:PerformLayout(w, h)
    self.Avatar:SetSize(w, h)
end

function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
end

function PANEL:SetSteamID(id, size)
    self.Avatar:SetSteamID(id, size)
end

function PANEL:Paint(w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)

    PIXEL.DrawFullRoundedBox(self:GetRounding(), 0, 0, w, h, color_white)

    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)

    self.Avatar:SetPaintedManually(false)
    self.Avatar:PaintManual()
    self.Avatar:SetPaintedManually(true)

    render.SetStencilEnable(false)
    render.ClearStencil()
end

vgui.Register("PIXEL.Avatar", PANEL, "Panel")