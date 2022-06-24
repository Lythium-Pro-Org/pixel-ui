do
    function PIXEL.PlaySound(type, sound)
        local soundPath = "pixelui-sounds/" .. type .. "/" .. sound .. ".mp3"

        if not file.Exists("sound/" .. soundPath, "GAME") then print(soundPath, "bad") return end

        surface.PlaySound(soundPath)
    end

    local buttonSounds = {
        [1] = "Button_4",
        [2] = "Button_5",
    }

    function PIXEL.PlayButtonSound()
        local randSound = math.random(1, 2)
        PIXEL.PlaySound("buttons-navigation", buttonSounds[randSound])
    end


    function PIXEL.PlayExpand(type)
        if type == "open" then
            PIXEL.PlaySound("buttons-navigation", "Expand")
        else
            PIXEL.PlaySound("buttons-navigation", "Collapse")
        end
    end
end