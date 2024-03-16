

PulsarUI.RegisterFontUnscaled("UI.Overhead", "Rubik", 100, 700)

local localPly
local function checkDistance(ent)
    if not IsValid(localPly) then localPly = LocalPlayer() end
    if localPly:GetPos():DistToSqr(ent:GetPos()) > 200000 then return true end
end

local disableClipping = DisableClipping
local start3d2d, end3d2d = cam.Start3D2D, cam.End3D2D
local Icon

local function drawOverhead(ent, pos, text, ang, scale, col)
    if ang then
        ang = ent:LocalToWorldAngles(ang)
    else
        ang = (pos - localPly:GetPos()):Angle()
        ang:SetUnpacked(0, ang[2] - 90, 90)
    end

    PulsarUI.SetFont("UI.Overhead")
    local w, h = PulsarUI.GetTextSize(text)
    w = w + 40
    h = h + 6

    local x, y = -(w * .5), -h

    local oldClipping = disableClipping(true)

    start3d2d(pos, ang, scale or 0.05)
    if not Icon then
        PulsarUI.DrawRoundedBox(12, x, y, w, h, col or PulsarUI.Colors.Primary)
        PulsarUI.DrawText(text, "UI.Overhead", 0, y + 1, PulsarUI.Colors.PrimaryText, TEXT_ALIGN_CENTER)
    else
        x = x - 40
        PulsarUI.DrawRoundedBox(12, x, y, h, h, PulsarUI.Colors.Primary)
        PulsarUI.DrawRoundedBoxEx(12, x + (h - 12), y + h - 20, w + 15, 20, col or PulsarUI.Colors.Primary, false, false, false, true)
        PulsarUI.DrawText(text, "UI.Overhead", x + h + 15, y + 8, PulsarUI.Colors.PrimaryText)
        PulsarUI.DrawImage(x + 10, y + 10, h - 20, h - 20, Icon, color_white)
    end
    end3d2d()

    disableClipping(oldClipping)
end

local function drawImageOverhead(ent, pos, imageURL, size, ang, scale, col)
    if ang then
        ang = ent:LocalToWorldAngles(ang)
    else
        ang = (pos - localPly:GetPos()):Angle()
        ang:SetUnpacked(0, ang[2] - 90, 90)
    end


    PulsarUI.SetFont("UI.Overhead")
    local w, h = PulsarUI.GetTextSize("FUCKFUCKFUCKFUCK")
    w = w + 40
    h = h + 6

    local x, y = -(w * .5), -h


    start3d2d(pos, ang, scale or 0.05)
        PulsarUI.DrawImage(x + 10, y + 10, h - 20, h - 20, imageURL, color_white)
    end3d2d()
end

local entOffset = 2
function PulsarUI.DrawEntOverhead(ent, text, angleOverride, posOverride, scaleOverride, colOverride)
    if checkDistance(ent) then return end

    if posOverride then
        drawOverhead(ent, ent:LocalToWorld(posOverride), text, angleOverride, scaleOverride)
        return
    end

    local pos = ent:OBBMaxs()
    pos:SetUnpacked(0, 0, pos[3] + entOffset)

    drawOverhead(ent, ent:LocalToWorld(pos), text, angleOverride, scaleOverride, colOverride)
end

local eyeOffset = Vector(0, 0, 7)
local fallbackOffset = Vector(0, 0, 73)
function PulsarUI.DrawNPCOverhead(ent, text, angleOverride, offsetOverride, scaleOverride, colOverride)
    if checkDistance(ent) then return end

    local eyeId = ent:LookupAttachment("eyes")
    if eyeId then
        local eyes = ent:GetAttachment(eyeId)
        if eyes then
            eyes.Pos:Add(offsetOverride or eyeOffset)
            drawOverhead(ent, eyes.Pos, text, angleOverride, scaleOverride)
            return
        end
    end

    drawOverhead(ent, ent:GetPos() + fallbackOffset, text, angleOverride, scaleOverride, colOverride)
end

function PulsarUI.EnableIconOverheads(new)
    local oldIcon = Icon
    local imgurMatch = (new or ""):match("^[a-zA-Z0-9]+$")
    if imgurMatch then
        new = "https://i.imgur.com/" .. new .. ".png"
    end
    Icon = new
    return oldIcon
end

-- Image Overheads
function PulsarUI.DrawEntImageOverhead(ent, imageURL, size, angleOverride, posOverride, scaleOverride, colOverride)
    if checkDistance(ent) then return end

    if posOverride then
        drawImageOverhead(ent, ent:LocalToWorld(posOverride), imageURL, size, angleOverride, scaleOverride, colOverride)
        return
    end

    local pos = ent:OBBMaxs()
    pos:SetUnpacked(0, 0, pos[3] + entOffset)

    drawImageOverhead(ent, ent:LocalToWorld(pos), imageURL, size, angleOverride, scaleOverride, colOverride)
end

function PulsarUI.DrawEntImageOverhead(ent, imgurId, size, angleOverride, posOverride, scaleOverride, colOverride)
    PulsarUI.DrawEntImageOverhead(ent, "https://i.imgur.com/" .. imgurId .. ".png", size, angleOverride, posOverride, scaleOverride, colOverride)
end

function PulsarUI.DrawNPCImageOverhead(ent, imageURL, size, angleOverride, offsetOverride, scaleOverride, colOverride)
    if checkDistance(ent) then return end

    local eyeId = ent:LookupAttachment("eyes")
    if eyeId then
        local eyes = ent:GetAttachment(eyeId)
        if eyes then
            eyes.Pos:Add(offsetOverride or eyeOffset)
            drawImageOverhead(ent, eyes.Pos, imageURL, size, angleOverride, scaleOverride)
            return
        end
    end

    drawImageOverhead(ent, ent:GetPos() + fallbackOffset, imageURL, size, angleOverride, scaleOverride, colOverride)
end

function PulsarUI.DrawNPCImageOverhead(ent, imgurId, size, angleOverride, offsetOverride, scaleOverride, colOverride)
    PulsarUI.DrawNPCImageOverhead(ent, "https://i.imgur.com/" .. imgurId .. ".png", size, angleOverride, offsetOverride, scaleOverride, colOverride)
end