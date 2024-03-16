--- @class PulsarUI.StepCounterStep : EditablePanel
--- @field SetStep fun(self: PulsarUI.StepCounterStep, step: number)
--- @field GetStep fun(self: PulsarUI.StepCounterStep): number
--- @field SetActiveStep fun(self: PulsarUI.StepCounterStep, active: boolean)
--- @field GetActiveStep fun(self: PulsarUI.StepCounterStep): boolean
--- @field SetEnabled fun(self: PulsarUI.StepCounterStep, enabled: boolean)
--- @field GetEnabled fun(self: PulsarUI.StepCounterStep): boolean
--- @field BackgroundCol Color
--- @field EnabledCol Color
--- @field ActiveCol Color
--- @field TextCol Color
local PANEL = {}
PulsarUI.RegisterFont("StepCounterStep", "Rubik", 19, 700)
AccessorFunc(PANEL, "Step", "Step", FORCE_NUMBER)
AccessorFunc(PANEL, "ActiveStep", "ActiveStep", FORCE_BOOL)
AccessorFunc(PANEL, "Enabled", "Enabled", FORCE_BOOL)

function PANEL:Init()
    self:SetTall(PulsarUI.Scale(90))
    self.BackgroundCol = PulsarUI.Colors.Header
    self.EnabledCol = PulsarUI.Colors.Positive
    self.ActiveCol = PulsarUI.Colors.Primary
    self.TextCol = PulsarUI.Colors.SecondaryText
end

function PANEL:Paint(w, h)
    local backgroundCol = PulsarUI.Colors.Transparent

    if self:GetEnabled() then
        backgroundCol = self.EnabledCol
    end


    if self:GetActiveStep() then
        backgroundCol = PulsarUI.Colors.Primary
    end

    PulsarUI.DrawRoundedBox(h / 2, 0, 0, w, h, self.BackgroundCol)
    local xOffset = PulsarUI.Scale1440(4)
    local activeBoxH = h - PulsarUI.Scale1440(8)

    PulsarUI.DrawRoundedBox(activeBoxH / 2, xOffset, xOffset, activeBoxH, activeBoxH, backgroundCol)
    PulsarUI.DrawSimpleText(self:GetStep(), "StepCounterStep", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PulsarUI.StepCounterStep", PANEL, "EditablePanel")

--

--- @class PulsarUI.StepCounter : EditablePanel
--- @field SetStepCount fun(self: PulsarUI.StepCounter, count: number)
--- @field GetStepCount fun(self: PulsarUI.StepCounter): number
--- @field SetCurrentStep fun(self: PulsarUI.StepCounter, num: number)
--- @field GetCurrentStep fun(self: PulsarUI.StepCounter): number
--- @field SetTitle fun(self: PulsarUI.StepCounter, title: string)
--- @field GetTitle fun(self: PulsarUI.StepCounter): string
--- @field SetFont fun(self: PulsarUI.StepCounter, font: string)
--- @field GetFont fun(self: PulsarUI.StepCounter): string
PANEL = {}
PulsarUI.RegisterFont("StepCounterTitle", "Rubik", 24, 700)
AccessorFunc(PANEL, "StepCount", "StepCount", FORCE_NUMBER)
AccessorFunc(PANEL, "CurrentStep", "CurrentStep", FORCE_NUMBER)
AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)

--- Reloads all of the steps elements
function PANEL:ReloadSteps()
    for k, v in ipairs(self.Steps) do
        v:Remove()
    end

    self.Steps = {}
    self:SetStepCount(self:GetStepCount())
end

--- Sets the current step
function PANEL:SetCurrentStep(num)
    self.CurrentStep = num
    if IsValid(self.Steps[num]) then
        self.Steps[num]:SetActiveStep(true)
    end

    self:ReloadSteps()
end

--- Sets the amount of steps in the step counter
function PANEL:SetStepCount(count)
    self.StepCount = count

    for i = 1, count do
        self.Steps[i] = vgui.Create("PulsarUI.StepCounterStep", self)
        self.Steps[i]:SetStep(i)

        if self:GetCurrentStep() and i < self:GetCurrentStep() then
            self.Steps[i]:SetEnabled(true)
        end

        if i == self:GetCurrentStep() then
            self.Steps[i]:SetActiveStep(true)
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
        local startX = (v:GetX() + v:GetWide()) + PulsarUI.Scale1440(4)
        local endX = nextStep:GetX() - PulsarUI.Scale1440(8)
        local width = endX - startX
        local tall = PulsarUI.Scale(4)
        local yPos = v:GetY() + (v:GetTall() / 2) - (tall / 2)
        local backgroundCol = PulsarUI.Colors.Header

        if self.Steps[k]:GetEnabled() then
            backgroundCol = PulsarUI.Colors.Positive
        end

        PulsarUI.DrawRoundedBox(tall / 2, startX, yPos, width, tall, backgroundCol)
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
            v:SetY(PulsarUI.Scale(25) + (textH / 3))
        end
    end
end

vgui.Register("PulsarUI.StepCounter", PANEL, "EditablePanel")