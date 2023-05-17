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
PIXEL.UI.Version = "1.3.1"

PIXEL.Themes = PIXEL.Themes or {}

PIXEL.Themes["Dark"] = {
    included = true,
    Background = Color(29, 29, 29),
    Header = Color(34, 34, 34),
    SecondaryHeader = Color(47, 47, 47),
    Scroller = Color(63, 63, 63),
    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(219, 219, 219),
    DisabledText = Color(44, 44, 44),
    Primary = Color(86, 86, 255),
    Disabled = Color(178, 178, 178),
    Positive = Color(0, 168, 107),
    Negative = Color(234, 70, 70),
    Diamond = Color(184, 242, 255),
    Gold = Color(255, 214, 0),
    Silver = Color(191, 191, 191),
    Bronze = Color(144, 94, 52),
    Transparent = Color(0, 0, 0, 0)
}

PIXEL.Colors = PIXEL.Themes["Dark"]

function PIXEL.Warn(...)
    MsgC(PIXEL.Colors.Gold, "[PIXEL UI - Warning] ", PIXEL.Colors.Negative, ..., "\n")
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

function PIXEL.LoadDirectoryRecursive(basePath, onLoad)
    local _, folders = PIXEL.LoadDirectory(basePath)

    for _, folderName in ipairs(folders) do
        PIXEL.LoadDirectoryRecursive(basePath .. "/" .. folderName)
    end

    if onLoad and isfunction(onLoad) then
        onLoad()
    end
end

PIXEL.LoadDirectoryRecursive("pixelui")
hook.Run("PIXEL.UI.FullyLoaded")
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