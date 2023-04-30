local PANEL = {}

PIXEL.RegisterFont("StepCounterStep", "Rubik", 19, 700)

AccessorFunc(PANEL, "Step", "Step", FORCE_NUMBER)
AccessorFunc(PANEL, "Enabled", "Enabled", FORCE_BOOL)

function PANEL:Init()
    self.BackgroundCol = PIXEL.Colors.Header
    self.EnabledCol = PIXEL.Colors.Primary
    self.TextCol = PIXEL.Colors.SecondaryText
end

function PANEL:Paint(w, h)
    local backgroundCol = self.BackgroundCol
    if self:GetEnabled() then
        backgroundCol = self.EnabledCol
    end
    PIXEL.DrawRoundedBox(8, 0, 0, w, h, backgroundCol)
    PIXEL.DrawSimpleText(self:GetStep(), "StepCounterStep", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.StepCounterStep", PANEL, "EditablePanel")

--

PANEL = {}

PIXEL.RegisterFont("StepCounterTitle", "Rubik", 24, 700)


AccessorFunc(PANEL, "StepCount", "StepCount", FORCE_NUMBER)
AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)

function PANEL:SetStepCount(count)
    self.StepCount = count
    for i = 1, self:GetStepCount() do
        self.Steps[i] = vgui.Create("PIXEL.StepCounterStep", self)
        self.Steps[i]:SetStep(i)
        if i <= 3 then
            self.Steps[i]:SetEnabled(true)
        end
    end

    self:InvalidateLayout(true)
end

function PANEL:Init()
    self:SetTitle("PIXEL Step Counter")

    self.Steps = {}
end

function PANEL:Paint(w, h)
    for k, v in ipairs(self.Steps) do
        local nextStep = self.Steps[k + 1]
        if not nextStep then continue end
        local startX = v:GetX() + v:GetWide()
        local endX = nextStep:GetX()
        local width = endX - startX
        local tall = PIXEL.Scale(4)
        local yPos = v:GetY() + (v:GetTall() / 2) - (tall / 2)
        local backgroundCol = PIXEL.Colors.Header
        if nextStep:GetEnabled() then
            backgroundCol = PIXEL.Colors.Primary
        end
        PIXEL.DrawRoundedBox(0, startX, yPos, width, tall, backgroundCol)
    end

    if self:GetTitle() then
        PIXEL.DrawSimpleText(self:GetTitle(), "StepCounterTitle", w / 2, 0, PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end

function PANEL:PerformLayout(w, h)
    local steps = self:GetStepCount()
    local stepSize = PIXEL.Scale(38)
    local allStepWidth = stepSize * steps
    local space = (w - allStepWidth) / (steps - 1)
    for k, v in ipairs(self.Steps) do
        v:SetSize(stepSize, stepSize)
        v:SetX((k - 1) * (stepSize + space))
        if self:GetTitle() then
            v:SetY(PIXEL.Scale(35))
        end
    end
end

vgui.Register("PIXEL.StepCounter", PANEL, "EditablePanel")