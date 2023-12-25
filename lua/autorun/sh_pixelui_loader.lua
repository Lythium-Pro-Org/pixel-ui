PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {}
PIXEL.UI.Version = "2.0.0"
PIXEL.UI.PulsarFork = true

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
