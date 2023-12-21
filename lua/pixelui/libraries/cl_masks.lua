---
--- Melon's Masks
--- https://github.com/melonstuff/melonsmasks/
--- Licensed under MIT
---

PIXEL.Masks = {}

PIXEL.Masks.Src = {}
PIXEL.Masks.Dest   = {}

PIXEL.Masks.Src.RT = GetRenderTargetEx("PIXEL_Masks_Src", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)
PIXEL.Masks.Dest.RT = GetRenderTargetEx("PIXEL_Masks_Dest", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)

PIXEL.Masks.Src.Mat = CreateMaterial("PIXEL_Masks_Src", "UnlitGeneric", {
    ["$basetexture"] = PIXEL.Masks.Src.RT:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})
PIXEL.Masks.Dest.Mat = CreateMaterial("PIXEL_Masks_Dest", "UnlitGeneric", {
    ["$basetexture"] = PIXEL.Masks.Dest.RT:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})

PIXEL.Masks.KIND_CUT = {BLEND_ZERO, BLEND_SRC_ALPHA, BLENDFUNC_ADD}
PIXEL.Masks.KIND_STAMP = {BLEND_ZERO, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD}

local camStart2D = cam.Start2D
local camEnd2D = cam.End2D
local pushRenderTarget = render.PushRenderTarget
local popRenderTarget = render.PopRenderTarget
local renderClear = render.Clear
local renderOverrideBlend = render.OverrideBlend
local setDrawColor = surface.SetDrawColor
local setMaterial = surface.SetMaterial
local drawTexturedRect = surface.DrawTexturedRect

function PIXEL.Masks.Start()
    render.PushRenderTarget(PIXEL.Masks.Dest.RT)
    render.Clear(0, 0, 0, 0, true, true)

    camStart2D()
end

function PIXEL.Masks.Source()
    camEnd2D()

    popRenderTarget()
    pushRenderTarget(PIXEL.Masks.Src.RT)
    renderClear(0, 0, 0, 0, true, true)

    camStart2D()
end

function PIXEL.Masks.And(kind)
    camEnd2D()

    popRenderTarget()
    pushRenderTarget(PIXEL.Masks.Dest.RT)

    camStart2D()

    renderOverrideBlend(true, kind[1], kind[2], kind[3])

    setDrawColor(255, 255, 255)
    setMaterial(PIXEL.Masks.Src.Mat)
    drawTexturedRect(0, 0, ScrW(), ScrH())

    renderOverrideBlend(false)

    PIXEL.Masks.Source()
end
function PIXEL.Masks.End(kind)
    kind = kind or PIXEL.Masks.KIND_CUT

    camEnd2D()

    popRenderTarget()
    pushRenderTarget(PIXEL.Masks.Dest.RT)

    camStart2D()
        renderOverrideBlend(true, kind[1], kind[2], kind[3])

        setDrawColor(255, 255, 255)
        setMaterial(PIXEL.Masks.Src.Mat)
        drawTexturedRect(0, 0, ScrW(), ScrH())

        renderOverrideBlend(false)
    camEnd2D()

    popRenderTarget()

    setDrawColor(255, 255, 255)
    setMaterial(PIXEL.Masks.Dest.Mat)
    drawTexturedRect(0, 0, ScrW(), ScrH())
end

hook.Add("HUDPaint", "Test", function()
    PIXEL.Masks.Start()
        PIXEL.DrawImage(100, 100, 1000, 1000, "https://i.imgur.com/abcde.jpg", color_white)
    PIXEL.Masks.Source()
        PIXEL.DrawFullRoundedBoxEx(8, 100, 100, 1000, 1000, Color(255, 255, 255), true, true, true, true)

    PIXEL.Masks.End()
end)