

local scrH = ScrH
local max = math.max
function PulsarUI.Scale(value)
    return max(value * (scrH() / 1080), 1)
end

function PulsarUI.Scale1440(value)
    return max(value * (scrH() / 1440), 1)
end

local constants = {}
local scaledConstants = {}
function PulsarUI.RegisterScaledConstant(varName, size)
    constants[varName] = size
    scaledConstants[varName] = PulsarUI.Scale(size)
end

function PulsarUI.GetScaledConstant(varName)
    return scaledConstants[varName]
end

hook.Add("OnScreenSizeChanged", "PulsarUI.UpdateScaledConstants", function()
    for varName, size in pairs(constants) do
        scaledConstants[varName] = PulsarUI.Scale(size)
    end
    scrH = ScrH()
end)
