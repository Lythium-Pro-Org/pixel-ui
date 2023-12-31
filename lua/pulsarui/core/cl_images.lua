

local materials = {}
local queue = {}

local useProxy = false

file.CreateDir(PulsarUI.DownloadPath)

local function endsWithExtension(str)
    local fileName = str:match(".+/(.-)$")
    if not fileName then
        return false
    end
    local extractedExtension = fileName and fileName:match("^.+(%..+)$")

    return extractedExtension and string.sub(str, -#extractedExtension) == extractedExtension or false
end

local function processQueue()
    if queue[1] then
        local url, filePath, matSettings, callback = unpack(queue[1])

        http.Fetch((useProxy and ("https://proxy.duckduckgo.com/iu/?u=" .. url)) or url,
            function(body, len, headers, code)
                if len > 2097152 or code ~= 200 then
                    materials[filePath] = Material("nil")
                else
                    local writeFilePath = filePath
                    if not endsWithExtension(filePath) then
                        writeFilePath = filePath .. ".png"
                    end

                    file.Write(writeFilePath, body)
                    materials[filePath] = Material("../data/" .. writeFilePath, matSettings or "noclamp smooth mips")
                end

                callback(materials[filePath])
            end,
            function(error)
                if useProxy then
                    materials[filePath] = Material("nil")
                    callback(materials[filePath])
                else
                    useProxy = true
                    processQueue()
                end
            end
        )
    end
end

function PulsarUI.GetImage(url, callback, matSettings)
    local protocol = url:match("^([%a]+://)")
    local urlWithoutProtocol = url
    if not protocol then
        print("[PulsarUI] Trying to run PulsarUI.GetImage without URL protocol.")
    else
        urlWithoutProtocol = string.gsub(url, protocol, "")
    end

    local fileNameStart = url:find("[^/]+$")
    if not fileNameStart then
        return
    end

    local urlWithoutFileName = url:sub(protocol:len() + 1, fileNameStart - 1)

    local dirPath = PulsarUI.DownloadPath .. urlWithoutFileName
    local filePath = PulsarUI.DownloadPath .. urlWithoutProtocol

    file.CreateDir(dirPath)

    local readFilePath = filePath
    if not endsWithExtension(filePath) and file.Exists(filePath .. ".png", "DATA") then
        readFilePath = filePath .. ".png"
    end

    if materials[filePath] then
        callback(materials[filePath])
    elseif file.Exists(readFilePath, "DATA") then
        materials[filePath] = Material("../data/" .. readFilePath, matSettings or "noclamp smooth mips")
        callback(materials[filePath])
    else
        table.insert(queue, {
            url,
            filePath,
            matSettings,
            function(mat)
                callback(mat)
                table.remove(queue, 1)
                processQueue()
            end
        })

        if #queue == 1 then
            processQueue()
        end
    end
end

function PulsarUI.GetImgur(id, callback, _, matSettings)
    local url = "i.imgur.com/" .. id .. ".png"
    PulsarUI.GetImage(url, callback, matSettings)
end