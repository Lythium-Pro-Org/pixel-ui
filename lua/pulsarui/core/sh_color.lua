do
    local format = string.format

    function PulsarUI.DecToHex(dec, zeros)
        return format("%0" .. (zeros or 2) .. "x", dec)
    end

    local max = math.max
    local min = math.min

    function PulsarUI.ColorToHex(color)
        return format("#%02X%02X%02X", max(min(color.r, 255), 0), max(min(color.g, 255), 0), max(min(color.b, 255), 0))
    end
end

function PulsarUI.ColorToHSL(col)
    local r = col.r / 255
    local g = col.g / 255
    local b = col.b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    b = max + min
    local h = b / 2
    if max == min then return 0, 0, h end
    local s, l = h, h
    local d = max - min
    s = l > .5 and d / (2 - b) or d / b

    if max == r then
        h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
        h = (b - r) / d + 2
    elseif max == b then
        h = (r - g) / d + 4
    end

    return h * .16667, s, l
end

local createColor = Color

do
    local function hueToRgb(p, q, t)
        if t < 0 then
            t = t + 1
        end

        if t > 1 then
            t = t - 1
        end

        if t < 1 / 6 then return p + (q - p) * 6 * t end
        if t < 1 / 2 then return q end
        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end

        return p
    end

    function PulsarUI.HSLToColor(h, s, l, a)
        local r, g, b
        local t = h / (2 * math.pi)

        if s == 0 then
            r, g, b = l, l, l
        else
            local q
            if l < 0.5 then
                q = l * (1 + s)
            else
                q = l + s - l * s
            end

            local p = 2 * l - q
            r = hueToRgb(p, q, t + 1 / 3)
            g = hueToRgb(p, q, t)
            b = hueToRgb(p, q, t - 1 / 3)
        end

        return createColor(r * 255, g * 255, b * 255, (a or 1) * 255)
    end
end

function PulsarUI.CopyColor(col)
    return createColor(col.r, col.g, col.b, col.a)
end

function PulsarUI.OffsetColor(col, offset)
    return createColor(col.r + offset, col.g + offset, col.b + offset)
end

do
    local match = string.match
    local tonumber = tonumber

    function PulsarUI.HexToColor(hex)
        local r, g, b = match(hex, "#(..)(..)(..)")

        return createColor(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
    end
end

do
    local curTime = CurTime
    local hsvToColor = HSVToColor
    local lastUpdate = 0
    local lastCol = createColor(0, 0, 0)

    function PulsarUI.GetRainbowColor()
        local time = curTime()
        if lastUpdate == time then return lastCol end
        lastUpdate = time
        lastCol = hsvToColor((time * 50) % 360, 1, 1)

        return lastCol
    end
end

do
    local colorToHSL = ColorToHSL

    function PulsarUI.IsColorLight(col)
        local _, _, lightness = colorToHSL(col)

        return lightness >= .5
    end
end

do
    local max = math.max
    local min = math.min
    local abs = math.abs

    function PulsarUI.ColorToHCT(col)
        local r, g, b = col.r / 255, col.g / 255, col.b / 255
        local maxCol, minCol = max(r, g, b), min(r, g, b)
        local chroma = maxCol - minCol
        local hue = 0

        if chroma ~= 0 then
            if maxCol == r then
                hue = ((g - b) / chroma) % 6
            elseif maxCol == g then
                hue = ((b - r) / chroma) + 2
            elseif maxCol == b then
                hue = ((r - g) / chroma) + 4
            end
        end

        local lightness = (maxCol + minCol) / 2
        local saturation = 0

        if chroma ~= 0 then
            saturation = chroma / (1 - abs(2 * lightness - 1))
        end

        return hue * 60, saturation, lightness
    end

    function PulsarUI.HCTToColor(h, c, t)
        local chroma = c * (1 - abs(2 * t - 1))
        local hue = h / 60
        local x = chroma * (1 - abs(hue % 2 - 1))
        local r, g, b = 0, 0, 0

        if hue >= 0 and hue <= 1 then
            r, g, b = chroma, x, 0
        elseif hue >= 1 and hue <= 2 then
            r, g, b = x, chroma, 0
        elseif hue >= 2 and hue <= 3 then
            r, g, b = 0, chroma, x
        elseif hue >= 3 and hue <= 4 then
            r, g, b = 0, x, chroma
        elseif hue >= 4 and hue <= 5 then
            r, g, b = x, 0, chroma
        elseif hue >= 5 and hue <= 6 then
            r, g, b = chroma, 0, x
        end

        local m = t - chroma / 2

        return createColor((r + m) * 255, (g + m) * 255, (b + m) * 255)
    end
end

function PulsarUI.LerpColor(t, from, to)
    return createColor(from.r, from.g, from.b, from.a):Lerp(t, to)
end

function PulsarUI.IsColorEqualTo(from, to)
    return from.r == to.r and from.g == to.g and from.b == to.b and from.a == to.a
end

function PulsarUI.SetColorTransparency(color, transparency)
    return Color(color.r, color.g, color.b, transparency)
end

---@class Color
local colorMeta = FindMetaTable("Color")
colorMeta.Copy = PulsarUI.CopyColor
colorMeta.IsLight = PulsarUI.IsColorLight
colorMeta.EqualTo = PulsarUI.IsColorEqualTo

--- Offset the color by a certain amount.
---@param offset number
function colorMeta:Offset(offset)
    self.r = self.r + offset
    self.g = self.g + offset
    self.b = self.b + offset

    return self
end

local lerp = Lerp

--- Linearly interpolate the color to another color.
---@param t number the interpolation value
---@param to Color the color to interpolate to
function colorMeta:Lerp(t, to)
    self.r = lerp(t, self.r, to.r)
    self.g = lerp(t, self.g, to.g)
    self.b = lerp(t, self.b, to.b)
    self.a = lerp(t, self.a, to.a)

    return self
end

--- Mix the color with another color.
---@param to Color the color to mix with
---@param percentage number the percentage of the color to mix
function colorMeta:Mix(to, percentage)
    percentage = percentage or 0.5

    self.r = self.r * (1 - percentage) + to.r * percentage
    self.g = self.g * (1 - percentage) + to.g * percentage
    self.b = self.b * (1 - percentage) + to.b * percentage

    return self
end