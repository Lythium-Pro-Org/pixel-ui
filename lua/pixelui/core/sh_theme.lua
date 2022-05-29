PIXEL.Colors = {
    Background = Color(22, 22, 22),
    Header = Color(28, 28, 28),
    SecondaryHeader = Color(15, 15, 15),
    Scroller = Color(61, 61, 61),

    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(220, 220, 220),
    DisabledText = Color(40, 40, 40),

    Primary = Color(77, 79, 199),
    Disabled = Color(180, 180, 180),
    Positive = Color(68, 235, 124),
    Negative = Color(235, 68, 68),

    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Themes = PIXEL.Themes or {}

function PIXEL.SetTheme(theme)
    file.Write("pixel/theme.txt", theme)

    if PIXEL.Themes[theme] then
        PIXEL.Colors = PIXEL.Themes[theme]
        if CLIENT then
            local ply = LocalPlayer()
            ply.PIXELTheme = theme
        end
    else
        return false
    end
end

hook.Add("InitPostEntity", "PIXELUI.LoadTheme", function()
    if !file.Exists("pixel/theme.txt", "DATA") then
        PIXEL.Colors = PIXEL.Themes[PIXEL.DefaultTheme]
        return
    end
    local theme = file.Read("pixel/theme.txt", "DATA")
    PIXEL.Colors = PIXEL.Themes[theme]
end)

concommand.Add("pixel_reset_theme", function(ply, cmd, args)
    PIXEL.Colors = PIXEL.Themes[PIXEL.DefaultTheme]
end)