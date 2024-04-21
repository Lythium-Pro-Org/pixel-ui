local setDrawColor = surface.SetDrawColor
local drawOutlinedRect = surface.DrawOutlinedRect
local mathFloor = math.floor

function PulsarUI.DrawOutlinedBox(x, y, w, h, thickness, col)
    setDrawColor(col.r, col.g, col.b, col.a)
    for i = 0, thickness - 1 do
        drawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

function PulsarUI.DrawOutlinedRoundedBoxEx(borderSize, x, y, w, h, col, thickness, topLeft, topRight, bottomLeft,
                                           bottomRight)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilEnable(true)
    render.ClearStencil()

    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)

    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)

    render.SetStencilReferenceValue(1)

    render.PerformFullScreenStencilOperation()

    render.SetStencilReferenceValue(0)

    thickness = mathFloor(thickness)
    local halfThickness = mathFloor(thickness * 0.5)

    PulsarUI.DrawRoundedBoxEx(borderSize, x + halfThickness, y + halfThickness, w - thickness, h - thickness, color_white, topLeft, topRight, bottomLeft,
        bottomRight)

    render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilPassOperation(STENCIL_KEEP)

    PulsarUI.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)

    render.SetStencilEnable(false)
end

function PulsarUI.DrawOutlinedRoundedBox(borderSize, x, y, w, h, col, thickness)
    PulsarUI.DrawOutlinedRoundedBoxEx(borderSize, x, y, w, h, col, thickness, true, true, true, true)
end