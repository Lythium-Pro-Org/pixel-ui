
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

local materials = {}

file.CreateDir("pixel")
file.CreateDir("pixel/icons")

local function processQueue()
    if queue[1] then
        local id, matSettings, callback = unpack(queue[1])

    if file.Exists("pixel/icons/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/pixel/icons/" .. id .. ".png", matSettings or "noclamp smooth mips")
        return callback(materials[id])
    end

    http.Fetch(useproxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com" or "https://i.imgur.com/" .. id .. ".png",
        function(body, len, headers, code)
            if len > 2097152 then
                materials[id] = Material("nil")
                return callback(materials[id])
            end

            file.Write("pixel/icons/" .. id .. ".png", body)
            materials[id] = Material("../data/pixel/icons/" .. id .. ".png", matSettings or "noclamp smooth mips")

            file.Write("pixel/icons/" .. id .. ".png", body)
            materials[id] = Material("../data/pixel/icons/" .. id .. ".png", matSettings or "noclamp smooth mips")

            return callback(materials[id])
        end,
        function(error)
            if useproxy then
                materials[id] = Material("nil")
                return callback(materials[id])
            end
            return PIXEL.GetImgur(id, callback, true)
        end
    )
end
