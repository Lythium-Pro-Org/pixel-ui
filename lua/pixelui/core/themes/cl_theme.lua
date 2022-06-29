if not file.Exists("pixel/themes/", "DATA") then
    file.CreateDir("pixel/themes/")
end

function PIXEL.SetTheme(theme, cross)
    if not cross then
        local ip = game.GetIPAddress()
        ip = ip:gsub(":", "-")
        ip = string.Replace(ip, ".", "_")

        file.CreateDir("pixel/themes/" .. ip .. "/")
        file.Write("pixel/themes/" .. ip .. "/theme.txt", theme)
    else
        file.Write("pixel/themes/theme.txt", theme)
    end

    if PIXEL.Themes[theme] then
        PIXEL.Colors = PIXEL.Themes[theme]
        local ply = LocalPlayer()
        ply.PIXELTheme = theme
    else
        PIXEL.Colors = PIXEL.Themes["Dark"]
        return false
    end
end

local function setJoinTheme()
    local ply = LocalPlayer()
    local ip = game.GetIPAddress()
    ip = ip:gsub(":", "-")
    ip = string.Replace(ip, ".", "_")
    if file.Exists("pixel/themes/" .. ip .. "/theme.txt", "DATA") then
        local theme = file.Read("pixel/themes/" .. ip .. "/theme.txt", "DATA")
        if theme == "" then theme = "Dark" end
        if not PIXEL.Themes[theme] then
            ply.PIXELTheme = "Dark"
            PIXEL.Colors = PIXEL.Themes["Dark"]
            return
        end

        PIXEL.Colors = PIXEL.Themes[theme]
        ply.PIXELTheme = theme
        return
    end

    if not file.Exists("pixel/themes/theme.txt", "DATA") then return end

    local theme = file.Read("pixel/theme.txt", "DATA")
    if theme == "" then theme = "Dark" end
    if not PIXEL.Themes[theme] then
        ply.PIXELTheme = "Dark"
        PIXEL.Colors = PIXEL.Themes["Dark"]
        return
    end

    PIXEL.Colors = PIXEL.Themes[theme]
    ply.PIXELTheme = theme
end

hook.Add("InitPostEntity", "PIXELUI.LoadTheme", function()
    setJoinTheme()
end)

concommand.Add("pixel_reset_theme", function(ply, cmd, args)
    PIXEL.Colors = PIXEL.Themes["Dark"]
end)