---@class PulsarUI.ColorCube.Slider : Panel
---@field SetSlideX fun(self: PulsarUI.ColorCube.Slider, i: number)
---@field GetSlideX fun(self: PulsarUI.ColorCube.Slider): number
---@field SetSlideY fun(self: PulsarUI.ColorCube.Slider, i: number)
---@field GetSlideY fun(self: PulsarUI.ColorCube.Slider): number
---@field SetLockX fun(self: PulsarUI.ColorCube.Slider, i: number)
---@field GetLockX fun(self: PulsarUI.ColorCube.Slider): number
---@field SetLockY fun(self: PulsarUI.ColorCube.Slider, i: number)
---@field GetLockY fun(self: PulsarUI.ColorCube.Slider): number
---@field GetDragging fun(self: PulsarUI.ColorCube.Slider): boolean
---@field SetDragging fun(self: PulsarUI.ColorCube.Slider, b: boolean)
---@field Dragging boolean
---@field SetTrapInside fun(self: PulsarUI.ColorCube.Slider, b: boolean)
---@field GetTrapInside fun(self: PulsarUI.ColorCube.Slider): boolean
local PANEL = {}

AccessorFunc(PANEL, "m_fSlideX", "SlideX")
AccessorFunc(PANEL, "m_fSlideY", "SlideY")
AccessorFunc(PANEL, "m_iLockX", "LockX")
AccessorFunc(PANEL, "m_iLockY", "LockY")
AccessorFunc(PANEL, "Dragging", "Dragging")
AccessorFunc(PANEL, "m_bTrappedInside", "TrapInside")

function PANEL:Init()
    self:SetMouseInputEnabled(true)

    self:SetSlideX(0.5)
    self:SetSlideY(0.5)

    ---@class PulsarUI.Button
    self.Knob = vgui.Create("PulsarUI.Button", self)
    self.Knob:SetText("")
    self.Knob:SetSize(PulsarUI.Scale(15), PulsarUI.Scale(15))
    self.Knob:NoClipping(false)


    self.KnobColor = color_white

    self.Knob.Paint = function(panel, w, h)
        PulsarUI.DrawOutlinedRoundedBox(h / 2, 0, 0, h, h, self.KnobColor, 8)
    end

    self.Knob.OnCursorMoved = function(panel, x, y)
        x, y = panel:LocalToScreen(x, y)
        x, y = self:ScreenToLocal(x, y)
        self:OnCursorMoved(x, y)
    end

    self.Knob.OnMousePressed = function(panel, mcode)
        if (mcode == MOUSE_MIDDLE) then
            self:SetSlideX(0.5)
            self:SetSlideY(0.5)
            return
        end

        --DButton.OnMousePressed(panel, mcode)
    end

    self:SetLockY(0.5)
end

--
-- We we currently editing?
--
function PANEL:IsEditing()
    return self:GetDragging() || self.Knob.Depressed
end

function PANEL:SetBackground(img)
    if (! self.BGImage) then
        self.BGImage = vgui.Create("DImage", self)
    end

    self.BGImage:SetImage(img)
    self:InvalidateLayout()
end

function PANEL:SetEnabled(b)
    self.Knob:SetEnabled(b)
    FindMetaTable("Panel").SetEnabled(self, b) -- There has to be a better way!
end

function PANEL:OnCursorMoved(x, y)
    if (!self:GetDragging() && !self.Knob.Depressed) then return end

    local w, h = self:GetSize()
    local iw, ih = self.Knob:GetSize()

    if (self:GetTrapInside()) then
        w = w - iw
        h = h - ih

        x = x - iw * 0.5
        y = y - ih * 0.5
    end

    x = math.Clamp(x, 0, w) / w
    y = math.Clamp(y, 0, h) / h

    if (self:GetLockX()) then x = self:GetLockX() end
    if (self:GetLockY()) then y = self:GetLockY() end

    x, y = self:TranslateValues(x, y)

    self:SetSlideX(x)
    self:SetSlideY(y)

    self:InvalidateLayout()
end

function PANEL:OnMousePressed(mcode)
    if (!self:IsEnabled()) then return true end

    self.Knob.Hovered = true

    self:SetDragging(true)
    self:MouseCapture(true)

    local x, y = self:CursorPos()
    self:OnCursorMoved(x, y)
end

function PANEL:OnMouseReleased(mcode)
    -- This is a hack. Panel.Hovered is not updated when dragging a panel (Source's dragging, not Lua Drag'n'drop)
    self.Knob.Hovered = vgui.GetHoveredPanel() == self.Knob

    self:SetDragging(false)
    self:MouseCapture(false)
end

function PANEL:PerformLayout()
    local w, h = self:GetSize()
    local iw, ih = self.Knob:GetSize()

    if (self:GetTrapInside()) then
        w = w - iw
        h = h - ih
        self.Knob:SetPos((self.m_fSlideX || 0) * w, (self.m_fSlideY || 0) * h)
    else
        self.Knob:SetPos((self.m_fSlideX || 0) * w - iw * 0.5, (self.m_fSlideY || 0) * h - ih * 0.5)
    end

    if (self.BGImage) then
        self.BGImage:StretchToParent(0, 0, 0, 0)
        self.BGImage:SetZPos(-10)
    end

    -- In case m_fSlideX/m_fSlideY changed multiple times a frame, we do this here
    self:ConVarChanged(self.m_fSlideX, self.m_strConVarX)
    self:ConVarChanged(self.m_fSlideY, self.m_strConVarY)

    self:LayoutExtra()
end

function PANEL:LayoutExtra() end

function PANEL:Think()
    self:ConVarXNumberThink()
    self:ConVarYNumberThink()
end

function PANEL:SetSlideX(i)
    self.m_fSlideX = i
    self:OnValuesChangedInternal()
end

function PANEL:SetSlideY(i)
    self.m_fSlideY = i
    self:OnValuesChangedInternal()
end

function PANEL:GetDragging()
    return self.Dragging || self.Knob.Depressed
end

function PANEL:OnValueChanged(x, y)
end

function PANEL:OnValuesChangedInternal()
    self:OnValueChanged(self.m_fSlideX, self.m_fSlideY)
    self:InvalidateLayout()
end

function PANEL:TranslateValues(x, y)
    return x, y
end

-- ConVars
function PANEL:SetConVarX(strConVar)
    self.m_strConVarX = strConVar
end

function PANEL:SetConVarY(strConVar)
    self.m_strConVarY = strConVar
end

function PANEL:ConVarChanged(newValue, cvar)
    if (! cvar || cvar:len() < 2) then return end

    GetConVar(cvar):SetFloat(newValue)

    -- Prevent extra convar loops
    if (cvar == self.m_strConVarX) then self.m_strConVarXValue = GetConVar(self.m_strConVarX):GetInt() end
    if (cvar == self.m_strConVarY) then self.m_strConVarYValue = GetConVar(self.m_strConVarY):GetInt() end
end

function PANEL:ConVarXNumberThink()
    if (! self.m_strConVarX || #self.m_strConVarX < 2) then return end

    local numValue = GetConVar(self.m_strConVarX):GetInt()

    -- In case the convar is a "nan"
    if (numValue != numValue) then return end
    if (self.m_strConVarXValue == numValue) then return end

    self.m_strConVarXValue = numValue
    self:SetSlideX(self.m_strConVarXValue)
end

function PANEL:ConVarYNumberThink()
    if (! self.m_strConVarY || #self.m_strConVarY < 2) then return end

    local numValue = GetConVar(self.m_strConVarY):GetInt()

    -- In case the convar is a "nan"
    if (numValue != numValue) then return end
    if (self.m_strConVarYValue == numValue) then return end

    self.m_strConVarYValue = numValue
    self:SetSlideY(self.m_strConVarYValue)
end

vgui.Register("PulsarUI.ColorCube.Slider", PANEL, "Panel")
