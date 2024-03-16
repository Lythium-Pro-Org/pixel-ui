PulsarUI = PulsarUI or {}
PulsarUI.Version = "2.0.0"

function PulsarUI.LoadDirectory(path)
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

function PulsarUI.LoadDirectoryRecursive(basePath, onLoad)
    local _, folders = PulsarUI.LoadDirectory(basePath)

    for _, folderName in ipairs(folders) do
        PulsarUI.LoadDirectoryRecursive(basePath .. "/" .. folderName)
    end

    if onLoad and isfunction(onLoad) then
        onLoad()
    end
end

PulsarUI.LoadDirectoryRecursive("pulsarui")
hook.Run("PulsarUI.FullyLoaded")

if CLIENT then return end
resource.AddWorkshop("2825396224")

local files, _ = file.Find("resource/fonts/NotoSans_*", "GAME", "nameasc")

for _, fileName in ipairs(files) do
    print("Adding font file: " .. fileName)
    resource.AddFile("resource/fonts/" .. fileName)
end