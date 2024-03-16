
PulsarUI.RegisteredFonts = PulsarUI.RegisteredFonts or {}
local registeredFonts = PulsarUI.RegisteredFonts

do
    PulsarUI.SharedFonts = PulsarUI.SharedFonts or {}
    local sharedFonts = PulsarUI.SharedFonts

    function PulsarUI.RegisterFontUnscaled(name, font, size, weight)
        weight = weight or 500

        local identifier = font .. size .. ":" .. weight

        local fontName = "PulsarUI:" .. identifier
        registeredFonts[name] = fontName

        if sharedFonts[identifier] then return end
        sharedFonts[identifier] = true

        surface.CreateFont(fontName, {
            font = font,
            size = size,
            weight = weight,
            extended = true,
            antialias = true
        })
    end
end

do
    PulsarUI.ScaledFonts = PulsarUI.ScaledFonts or {}
    local scaledFonts = PulsarUI.ScaledFonts

    local fontSizeCvar = CreateClientConVar("pulsar_ui_font_resize", "1", true, false, "How many times bigger should we make all fonts registed with PulsarUI. Please rejoin the server after running this.", 1, 2)

    function PulsarUI.RegisterFont(name, font, size, weight)
        local resizeAmount = fontSizeCvar:GetFloat()
        size = size * resizeAmount

        scaledFonts[name] = {
            font = font,
            size = size,
            resize = resizeAmount,
            weight = weight
        }

        PulsarUI.RegisterFontUnscaled(name, font, PulsarUI.Scale(size), weight)
    end

    function PulsarUI.GenerateFont(size, weight, font, name)
        weight = weight or 700
        PulsarUI.Fonts = PulsarUI.Fonts or {}
        local fontName = name or ("PulsarUI.Font.Size" .. size)
        font = font or "Rubik"

        if !PulsarUI.Fonts[fontName] or PulsarUI.Fonts[fontName].size ~= size or PulsarUI.Fonts[fontName].weight ~= weight then
            PulsarUI.Fonts[fontName] = {
                name = fontName,
                size = size,
                weight = weight
            }
            PulsarUI.RegisterFont(fontName, font, size, weight)
            return fontName
        end

        return fontName
    end

    hook.Add("OnScreenSizeChanged", "PulsarUI.ReRegisterFonts", function()
        for k,v in pairs(scaledFonts) do
            PulsarUI.RegisterFont(k, v.font, v.size, v.weight)
        end
    end)
end

do
    local setFont = surface.SetFont
    local function setPixelFont(font)
        local pixelFont = registeredFonts[font]
        if pixelFont then
            setFont(pixelFont)
            return
        end

        setFont(font)
    end

    PulsarUI.SetFont = setPixelFont

    local getTextSize = surface.GetTextSize
    function PulsarUI.GetTextSize(text, font)
        if font then setPixelFont(font) end
        return getTextSize(text)
    end

    function PulsarUI.GetRealFont(font)
        return registeredFonts[font]
    end
end