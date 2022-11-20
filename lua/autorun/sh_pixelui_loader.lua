--[[
PIXEL UI
Copyright (C) 2021 Tom O'Sullivan (Tom.bat)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {}
PIXEL.UI.Version = "1.2.3"

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

function PIXEL.Log(...)
    MsgC(PIXEL.Colors.PrimaryText, "[PIXEL UI] ", PIXEL.Colors.SecondaryText, ..., "\n")
end

function PIXEL.LoadDirectory(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        local filePath = path .. "/" .. fileName

        if CLIENT then
            include(filePath)
        else
            if fileName:StartWith("cl_") then
                AddCSLuaFile(filePath)
            elseif fileName:StartWith("sh_") then
                AddCSLuaFile(filePath)
                include(filePath)
            else
                include(filePath)
            end
        end
    end

    return files, folders
end

function PIXEL.LoadDirectoryRecursive(basePath)
    local _, folders = PIXEL.LoadDirectory(basePath)

    for _, folderName in ipairs(folders) do
        PIXEL.LoadDirectoryRecursive(basePath .. "/" .. folderName)
    end
end

PIXEL.LoadDirectoryRecursive("pixelui")
hook.Run("PIXEL.UI.FullyLoaded")

PIXEL.RegisterAddon("Pulsar Store")
    :SetLogo("BpCb55H")
    :AddTab("Test1", "BpCb55H", PIXEL.Colors.Silver)
:Done()
PIXEL.RegisterAddon("Pulsar Tickets")
    :SetLogo("BpCb55H")
    :AddTab("Test1", "zeLeEEw", PIXEL.Colors.Silver)
:Done()

PIXEL.RegisterAddon("PIXELUI")
    :SetVersion(PIXEL.UI.Version)
    :SetAuthor("TomDotBat & Lythium")
    :SetLogo("8bKjn4t")
    :SetURL("https://github.com/Pulsar-Dev/pulsar-lib")
    :SetSupportURL("https://github.com/Pulsar-Dev/pulsar-lib")
    :SetVersionCheckerURL("https://raw.githubusercontent.com/Pulsar-Dev/pixel-ui/master/VERSION")

    :AddTab("Config", "vVoYqwG", PIXEL.Colors.Diamond)
    :AddCheckbox("Config", "Override Derma Menus", "Should we override the default derma popups for the PIXEL UI reskins?", function() end, PIXEL.OverrideDermaMenus and true or false)
    :AddCheckbox("Config", "Disable Notification", "Should we disable the PIXEL UI Reskin of the notification?", function() end, PIXEL.DisableNotification)
    :AddCheckbox("Config", "Disable UI Sounds", "Should we disable The UI Sounds?", function() end, PIXEL.DisableUISounds)
    :AddTextEntry("Config", "Progress Image ID", "The Imgur ID of the progress image you want to appear when Imgur content is loading.", PIXEL.ProgressImageID, false, function(text) PIXEL.ProgressImageID = text end)

    :AddTab("Theme", "zeLeEEw", PIXEL.Colors.Silver)
:Done()


if CLIENT then return end
resource.AddWorkshop("2825396224")

hook.Add("Think", "PIXEL.UI.VersionChecker", function()
    hook.Remove("Think", "PIXEL.UI.VersionChecker")

    http.Fetch("https://raw.githubusercontent.com/Pulsar-Dev/pixel-ui/master/VERSION", function(body)
        if PIXEL.UI.Version ~= string.Trim(body) then
            local red = Color(192, 27, 27)
            MsgC(red, "[PIXEL UI] There is an update available, please download it at: https://github.com/Pulsar-Dev/pixel-ui/releases/latest\n")
            MsgC(red, "\nYour version: " .. PIXEL.UI.Version .. "\n")
            MsgC(red, "New  version: " .. body .. "\n")

            return
        end
    end)
end)
