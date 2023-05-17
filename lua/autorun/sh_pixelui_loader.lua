--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {}
PIXEL.UI.Version = "1.3.1"

PIXEL.Colors = {
    Background = Color(22, 22, 22),
    Header = Color(28, 28, 28),
    SecondaryHeader = Color(15, 15, 15),
    Scroller = Color(61, 61, 61),
    --
    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(220, 220, 220),
    DisabledText = Color(40, 40, 40),
    --
    Primary = Color(43, 157, 203),
    Disabled = Color(180, 180, 180),
    Positive = Color(68, 235, 124),
    Negative = Color(235, 68, 68),
    --
    Diamond = Color(185, 242, 255),
    Gold = Color(255, 215, 0),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),
    --
    Transparent = Color(0, 0, 0, 0)
}

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