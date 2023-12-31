---
--- Modified Melon's Masks
--- https://github.com/melonstuff/melonsmasks/
--- Licensed under MIT (https://github.com/melonstuff/melonsmasks/blob/main/LICENSE)
---

PulsarUI.Masks = {}

PulsarUI.Masks.Src = {}
PulsarUI.Masks.Dest   = {}

PulsarUI.Masks.Src.RT = GetRenderTargetEx("PIXEL_Masks_Src", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)
PulsarUI.Masks.Dest.RT = GetRenderTargetEx("PIXEL_Masks_Dest", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)

PulsarUI.Masks.Src.Mat = CreateMaterial("PIXEL_Masks_Src", "UnlitGeneric", {
    ["$basetexture"] = PulsarUI.Masks.Src.RT:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})
PulsarUI.Masks.Dest.Mat = CreateMaterial("PIXEL_Masks_Dest", "UnlitGeneric", {
    ["$basetexture"] = PulsarUI.Masks.Dest.RT:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})

PulsarUI.Masks.KIND_CUT = {BLEND_ZERO, BLEND_SRC_ALPHA, BLENDFUNC_ADD}
PulsarUI.Masks.KIND_STAMP = {BLEND_ZERO, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD}

local camStart2D = cam.Start2D
local camEnd2D = cam.End2D
local pushRenderTarget = render.PushRenderTarget
local popRenderTarget = render.PopRenderTarget
local renderClear = render.Clear
local renderOverrideBlend = render.OverrideBlend
local setDrawColor = surface.SetDrawColor
local setMaterial = surface.SetMaterial
local drawTexturedRect = surface.DrawTexturedRect

function PulsarUI.Masks.Start()
    render.PushRenderTarget(PulsarUI.Masks.Dest.RT)
    render.Clear(0, 0, 0, 0, true, true)

    camStart2D()
end

function PulsarUI.Masks.Source()
    camEnd2D()

    popRenderTarget()
    pushRenderTarget(PulsarUI.Masks.Src.RT)
    renderClear(0, 0, 0, 0, true, true)

    camStart2D()
end

function PulsarUI.Masks.And(kind)
    camEnd2D()

    popRenderTarget()
    pushRenderTarget(PulsarUI.Masks.Dest.RT)

    camStart2D()

    renderOverrideBlend(true, kind[1], kind[2], kind[3])

    setDrawColor(255, 255, 255)
    setMaterial(PulsarUI.Masks.Src.Mat)
    drawTexturedRect(0, 0, ScrW(), ScrH())

    renderOverrideBlend(false)

    PulsarUI.Masks.Source()
end
function PulsarUI.Masks.End(kind)
    kind = kind or PulsarUI.Masks.KIND_CUT

    camEnd2D()

    popRenderTarget()
    pushRenderTarget(PulsarUI.Masks.Dest.RT)

    camStart2D()
        renderOverrideBlend(true, kind[1], kind[2], kind[3])

        setDrawColor(255, 255, 255)
        setMaterial(PulsarUI.Masks.Src.Mat)
        drawTexturedRect(0, 0, ScrW(), ScrH())

        renderOverrideBlend(false)
    camEnd2D()

    popRenderTarget()

    setDrawColor(255, 255, 255)
    setMaterial(PulsarUI.Masks.Dest.Mat)
    drawTexturedRect(0, 0, ScrW(), ScrH())
end