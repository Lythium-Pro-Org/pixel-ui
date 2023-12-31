do
    util.AddNetworkString("PulsarUI.SpawnConfetti")
    util.PrecacheSound("pixel_confetti.mp3")
    function PulsarUI.SpawnConfetti(ply)
        local effectData = EffectData()
        effectData:SetOrigin(ply:GetPos())
        util.Effect("pixel_confetti", effectData)
        sound.Play("pixelui-sounds/pixel_confetti.mp3", ply:GetPos())
    end
end