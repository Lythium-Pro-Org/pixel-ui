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

    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    You should have received a copy of the GNU General Public License
]]

PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {}
PIXEL.UI.Version = "2.0.0"

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