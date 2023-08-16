local PANEL = {}
AccessorFunc(PANEL, "Material", "Material")
AccessorFunc(PANEL, "ImageColor", "ImageColor")
AccessorFunc(PANEL, "KeepAspect", "KeepAspect")
AccessorFunc(PANEL, "MatName", "MatName")
AccessorFunc(PANEL, "FailsafeMatName", "FailsafeMatName")
local find = string.find

function PANEL:Init()
    self:SetImageColor(color_white)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    self:SetKeepAspect(false)
    self.ImageName = ""
    self.ActualWidth = 10
    self.ActualHeight = 10
end

function PANEL:SetOnViewMaterial(materialName, failsafeMatName)
    self:SetMatName(materialName)
    self:SetFailsafeMatName(failsafeMatName)
    self.ImageName = materialName
end

function PANEL:Unloaded()
    return self.MatName ~= nil
end

function PANEL:LoadMaterial()
    if not self:Unloaded() then return end
    self:DoLoadMaterial()
    self:SetMatName(nil)
end

function PANEL:DoLoadMaterial()
    local mat = Material(self:GetMatName())

    if mat:IsError() then
        if self:GetFailsafeMatName() then
            mat = Material(self:GetFailsafeMatName())
        else
            return
        end
    end

    self:SetMaterial(mat)
    self:FixVertexLitMaterial()
    self:InvalidateParent()
end

function PANEL:SetMaterial(material)
    if isstring(material) then
        self:SetImage(material)

        return
    end

    self.Material = material
    if not self.Material then return end
    local tex = self.Material:GetTexture("$basetexture")

    if tex then
        self.ActualWidth = tex:Width()
        self.ActualHeight = tex:Height()
    else
        self.ActualWidth = self.Material:Width()
        self.ActualHeight = self.Material:Height()
    end
end

function PANEL:SetImage(image, imageBackup)
    if imageBackup and not file.Exists("materials/" .. image .. ".vmt", "GAME") and not file.Exists("materials/" .. image, "GAME") then
        image = imageBackup
    end

    self.ImageName = image
    local mat = Material(image)
    self:SetMaterial(mat)
    self:FixVertexLitMaterial()
end

function PANEL:GetImage()
    return self.ImageName
end

function PANEL:FixVertexLitMaterial()
    local mat = self:GetMaterial()
    local image = mat:GetName()

    if find(mat:GetShader(), "VertexLitGeneric") or find(mat:GetShader(), "Cable") then
        local t = mat:GetString("$basetexture")

        if t then
            local params = {}
            params["$basetexture"] = t
            params["$vertexcolor"] = 1
            params["$vertexalpha"] = 1
            mat = CreateMaterial(image .. "_DImage", "UnlitGeneric", params)
        end
    end

    self:SetMaterial(mat)
end

function PANEL:SizeToContents(image)
    self:SetSize(self.ActualWidth, self.ActualHeight)
end

local drawTexturedRect = surface.DrawTexturedRect
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor

function PANEL:Paint()
    local x, y = 0, 0
    local dw, dh = self:GetWide(), self:GetTall()
    self:LoadMaterial()
    if not self.Material then return true end
    setMaterial(self.Material)
    setDrawColor(self.ImageColor.r, self.ImageColor.g, self.ImageColor.b, self.ImageColor.a)

    if self:GetKeepAspect() then
        local w = self.ActualWidth
        local h = self.ActualHeight

        if w > dw and h > dh then
            if w > dw then
                w = dw
            elseif h > dh then
                h = dh
            end
        elseif w < dw and h < dh then
            if w < dw then
                w = dw
            elseif h < dh then
                h = dh
            end
        end

        local OffX = (dw - w) * 0.5
        local OffY = (dh - h) * 0.5
        drawTexturedRect(OffX + x, OffY + y, w, h)
    end

    drawTexturedRect(x, y, dw, dh)
end

vgui.Register("PIXEL.Image", PANEL, "EditablePanel")