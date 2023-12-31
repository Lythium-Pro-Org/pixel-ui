local PANEL = {}
PulsarUI.RegisterFont("StepCounterStep", "Rubik", 19, 700)
AccessorFunc(PANEL, "Step", "Step", FORCE_NUMBER)
AccessorFunc(PANEL, "Enabled", "Enabled", FORCE_BOOL)

function PANEL:Init()
    self:SetTall(PulsarUI.Scale(90))
    self.BackgroundCol = PulsarUI.Colors.Header
    self.EnabledCol = PulsarUI.Colors.Positive
    self.ActiveCol = PulsarUI.Colors.Primary
    self.TextCol = PulsarUI.Colors.SecondaryText
end

function PANEL:Paint(w, h)
    local backgroundCol = self.BackgroundCol

    if self:GetEnabled() then
        backgroundCol = self.EnabledCol
    end

    PulsarUI.DrawRoundedBox(8, 0, 0, w, h, backgroundCol)
    PulsarUI.DrawSimpleText(self:GetStep(), "StepCounterStep", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PulsarUI.StepCounterStep", PANEL, "EditablePanel")
--
PANEL = {}
PulsarUI.RegisterFont("StepCounterTitle", "Rubik", 24, 700)
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
        self.Steps[i] = vgui.Create("PulsarUI.StepCounterStep", self)
        self.Steps[i]:SetStep(i)

        if self:GetCurrentStep() and i < self:GetCurrentStep() then
            self.Steps[i]:SetEnabled(true)
        end
    end

    self:InvalidateLayout(true)
end

function PANEL:Init()
    self:SetTitle("PulsarUI Step Counter")
    self:SetFont("StepCounterTitle")
    self.Steps = {}
end

function PANEL:Paint(w, h)
    if self:GetTitle() then
        PulsarUI.DrawSimpleText(self:GetTitle(), self:GetFont(), w / 2, 0, PulsarUI.Colors.PrimaryText, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    for k, v in ipairs(self.Steps) do
        local nextStep = self.Steps[k + 1]
        if not nextStep then continue end
        local startX = v:GetX() + v:GetWide()
        local endX = nextStep:GetX()
        local width = endX - startX
        local tall = PulsarUI.Scale(4)
        local yPos = v:GetY() + (v:GetTall() / 2) - (tall / 2)
        local backgroundCol = PulsarUI.Colors.Header

        if self.Steps[k]:GetEnabled() and not nextStep:GetEnabled() then
            startX, yPos = self:LocalToScreen(startX, yPos)
            PulsarUI.DrawSimpleLinearGradient(startX, yPos, width, tall, PulsarUI.Colors.Positive, backgroundCol, true)
            continue
        elseif nextStep:GetEnabled() then
            backgroundCol = PulsarUI.Colors.Positive
        end

        PulsarUI.DrawRoundedBox(0, startX, yPos, width, tall, backgroundCol)
    end
end

function PANEL:PerformLayout(w, h)
    local steps = self:GetStepCount()
    local stepSize = PulsarUI.Scale(38)
    local allStepWidth = stepSize * steps
    local space = (w - allStepWidth) / (steps - 1)

    for k, v in ipairs(self.Steps) do
        v:SetSize(stepSize, stepSize)
        v:SetX((k - 1) * (stepSize + space))

        if self:GetTitle() then
            local _, textH = PulsarUI.GetTextSize(self:GetTitle(), self:GetFont())
            v:SetY(PulsarUI.Scale(35) + (textH / 3))
        end
    end
end

vgui.Register("PulsarUI.StepCounter", PANEL, "EditablePanel")