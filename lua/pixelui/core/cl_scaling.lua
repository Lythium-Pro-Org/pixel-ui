

local scrH = ScrH
local max = math.max
function PIXEL.Scale(value)
    return max(value * (scrH() / 1080), 1)
end

function PIXEL.Scale1440(value)
    return max(value * (scrH() / 1440), 1)
end

local constants = {}
local scaledConstants = {}
function PIXEL.RegisterScaledConstant(varName, size)
    constants[varName] = size
    scaledConstants[varName] = PIXEL.Scale(size)
end

function PIXEL.GetScaledConstant(varName)
    return scaledConstants[varName]
end

hook.Add("OnScreenSizeChanged", "PIXEL.UI.UpdateScaledConstants", function()
    for varName, size in pairs(constants) do
        scaledConstants[varName] = PIXEL.Scale(size)
    end
    scrH = ScrH()
end)
