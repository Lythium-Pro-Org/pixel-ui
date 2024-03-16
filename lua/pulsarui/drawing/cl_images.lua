

local progressMat

local drawProgressWheel
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor

do
    local min = math.min
    local curTime = CurTime
    local drawTexturedRectRotated = surface.DrawTexturedRectRotated

    function PulsarUI.DrawProgressWheel(x, y, w, h, col)
        local progSize = min(w, h)
        setMaterial(progressMat)
        setDrawColor(col.r, col.g, col.b, col.a)
        drawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, -curTime() * 100)
    end
    drawProgressWheel = PulsarUI.DrawProgressWheel
end

local materials = {}
local grabbingMaterials = {}

local getImage = PulsarUI.GetImage
getImage(PulsarUI.ProgressImageURL, function(mat)
    progressMat = mat
end)

local drawTexturedRect = surface.DrawTexturedRect
function PulsarUI.DrawImage(x, y, w, h, url, col)
    if not materials[url] then
        drawProgressWheel(x, y, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRect(x, y, w, h)
end

local drawTexturedRectRotated = surface.DrawTexturedRectRotated
function PulsarUI.DrawImageRotated(x, y, w, h, rot, url, col)
    if not materials[url] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRectRotated(x, y, w, h, rot)
end

function PulsarUI.DrawImgur(x, y, w, h, imgurId, col)
    local url = "https://i.imgur.com/" .. imgurId .. ".png"
    PulsarUI.DrawImage(x, y, w, h, url, col)
end

function PulsarUI.DrawImgurRotated(x, y, w, h, rot, imgurId, col)
    local url = "https://i.imgur.com/" .. imgurId .. ".png"
    PulsarUI.DrawImageRotated(x, y, w, h, rot, url, col)
end