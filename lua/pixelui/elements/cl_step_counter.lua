local PANEL = {}
PIXEL.RegisterFont("StepCounterStep", "Rubik", 19, 700)
AccessorFunc(PANEL, "Step", "Step", FORCE_NUMBER)
AccessorFunc(PANEL, "Enabled", "Enabled", FORCE_BOOL)

function PANEL:Init()
    self:SetTall(PIXEL.Scale(90))
    self.BackgroundCol = PIXEL.Colors.Header
    self.EnabledCol = PIXEL.Colors.Positive
    self.ActiveCol = PIXEL.Colors.Primary
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
AccessorFunc(PANEL, "CurrentStep", "CurrentStep", FORCE_NUMBER)
AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)

function PANEL:ReloadSteps()
    for k, v in ipairs(self.Steps) do
        v:Remove()
    end

    self.Steps = {}
    self:SetStepCount(self:GetStepCount())
end

function PANEL:SetCurrentStep(num)
    self.CurrentStep = num
    self:ReloadSteps()
end

function PANEL:SetStepCount(count)
    self.StepCount = count

    for i = 1, count do
        self.Steps[i] = vgui.Create("PIXEL.StepCounterStep", self)
        self.Steps[i]:SetStep(i)

        if self:GetCurrentStep() and i < self:GetCurrentStep() then
            self.Steps[i]:SetEnabled(true)
        end
    end

    self:InvalidateLayout(true)
end

function PANEL:Init()
    self:SetTitle("PIXEL Step Counter")
    self:SetFont("StepCounterTitle")
    self.Steps = {}
end

function PANEL:Paint(w, h)
    if self:GetTitle() then
        PIXEL.DrawSimpleText(self:GetTitle(), self:GetFont(), w / 2, 0, PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    for k, v in ipairs(self.Steps) do
        local nextStep = self.Steps[k + 1]
        if not nextStep then continue end
        local startX = v:GetX() + v:GetWide()
        local endX = nextStep:GetX()
        local width = endX - startX
        local tall = PIXEL.Scale(4)
        local yPos = v:GetY() + (v:GetTall() / 2) - (tall / 2)
        local backgroundCol = PIXEL.Colors.Header

        if self.Steps[k]:GetEnabled() and not nextStep:GetEnabled() then
            startX, yPos = self:LocalToScreen(startX, yPos)
            PIXEL.DrawSimpleLinearGradient(startX, yPos, width, tall, PIXEL.Colors.Positive, backgroundCol, true)
            continue
        elseif nextStep:GetEnabled() then
            backgroundCol = PIXEL.Colors.Positive
        end

        PIXEL.DrawRoundedBox(0, startX, yPos, width, tall, backgroundCol)
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
            local _, textH = PIXEL.GetTextSize(self:GetTitle(), self:GetFont())
            v:SetY(PIXEL.Scale(35) + (textH / 3))
        end
    end
end

vgui.Register("PIXEL.StepCounter", PANEL, "EditablePanel")