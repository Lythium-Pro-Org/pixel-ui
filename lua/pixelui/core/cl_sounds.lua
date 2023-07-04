PIXEL = PIXEL or {}
do
    function PIXEL.PlaySound(type, sound)
        if PIXEL.DisableUISounds then return end
        local soundPath = "pixelui-sounds/" .. type .. "/" .. sound .. ".mp3"

        if not file.Exists("sound/" .. soundPath, "GAME") then return end

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

    function PIXEL.PlayKeyType()
        PIXEL.PlayButtonSound()
    end

    function PIXEL.PlayExpand(type)
        if type == "open" then
            PIXEL.PlaySound("buttons-navigation", "Expand")
        else
            PIXEL.PlaySound("buttons-navigation", "Collapse")
        end
    end

    function PIXEL.PlayNotify()
        PIXEL.PlaySound("notifications-alerts", "Alert_2")
    end

    local tabSounds = {
        [1] = "Tab_1",
        [2] = "Tab_2",
        [3] = "Tab_3"
    }

    function PIXEL.PlayChangeTab()
        local randSound = math.random(1, 3)
        PIXEL.PlaySound("buttons-navigation", tabSounds[randSound])
    end

    function PIXEL.PlayCancel()
        PIXEL.PlaySound("errors-cancel", "Cancel_2")
    end

    function PIXEL.PlayError(num)
        if not num then num = 1 end
        PIXEL.PlaySound("errors-cancel", "Error_" .. num)
    end

    function PIXEL.PlayComplete(num)
        if not num then num = 1 end
        PIXEL.PlaySound("complete-success", "Complete_" .. num)
    end

    function PIXEL.PlaySuccess(num)
        if not num then num = 1 end
        PIXEL.PlaySound("complete-success", "Success_" .. num)
    end
end