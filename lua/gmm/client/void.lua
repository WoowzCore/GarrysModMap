GMM_C.Void = {}

GMM_C.Func.CameraInVoid = function()
    if not IsValid(GMM_C.Player) then return false end
    return bit.band(util.PointContents(GMM_C.CameraPosition), CONTENTS_SOLID) == CONTENTS_SOLID
end

local MusicChannel = nil

GMM_C.Void.Think = function()
    if true then
        if not GMM or not GMM.Valid then return end

        local DistanceFromZero = GMM_C.CameraPosition:Length()
        local MinDist = 3000
        local MaxDist = 30000

        local VolumePower = (DistanceFromZero - MinDist) / (MaxDist - MinDist)
        if GMM.Maps.Goofy then
            VolumePower = VolumePower * 5 + 0.5
        else
            VolumePower = math.Clamp(VolumePower, 0, 1)
        end

        local VoidVolume = VolumePower

        if GMM_C.Func.CameraInVoid() and VoidVolume > 0.001 then
            if not IsValid(MusicChannel) then
                sound.PlayFile("sound/woowz/music/ManiyaVelichiaGOLUFUNNY.wav", "noplay loop", function(Station, ErrCode, ErrStr)
                    if IsValid(Station) then
                        MusicChannel = Station
                        MusicChannel:SetVolume(0)
                        MusicChannel:Play()
                    end
                end)
            else
                if MusicChannel:GetState() ~= GMOD_CHANNEL_PLAYING then
                    MusicChannel:Play()
                end


                MusicChannel:SetVolume(VoidVolume)
                MusicChannel:SetPlaybackRate(1 + math.sin(CurTime() * 0.5) * 0.1 * VoidVolume)
            end
        else
            if IsValid(MusicChannel) then
                local CurrentVolume = MusicChannel:GetVolume()
                if CurrentVolume > 0.001 then
                    MusicChannel:SetVolume(math.max(CurrentVolume - 0.05, 0))
                else
                    if MusicChannel:GetState() == GMOD_CHANNEL_PLAYING then
                        MusicChannel:Pause()
                    end
                end
            end
        end
    end
end

local __VoidGlitchMaterial = CreateMaterial("gmm_VoidGlitchMaterial", "UnlitGeneric", {
    ["$basetexture"] = "_rt_FullFrameFB",
    ["$additive"   ] = 1,
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1
})

hook.Add("PreRender", "gmm_GlitchVoid_Clear", function()
    if not GMM or not GMM.Valid then return end
    if not GMM_C.Func.CameraInVoid() then return end

    local T = CurTime()

    local HUE = (T * 0.05) % 1

    local Glitch = 0
    local Seed = math.floor(T * 6)

    if (Seed * 9301 + 49297) % 233280 / 233280 > 0.75 then
        Glitch = math.sin(T * 40) * 0.15
        HUE = HUE + math.sin(Seed * 12.9898) * 0.05
    end

    local Color__ = HSVToColor((HUE % 1) * 360, math.Clamp(0.35 + math.sin(T * 1.3) * 0.15, 0, 1), math.Clamp((0.08 + math.sin(T * 2.1) * 0.03) + Glitch, 0, 0.25))

    render.Clear(Color__.r, Color__.g, Color__.b, 255, true, true)
end)

hook.Add("RenderScreenspaceEffects", "gmm_GlitchVoid", function()
    if not GMM or not GMM.Valid then return end
    if not GMM_C.Func.CameraInVoid() then return end

    local DistanceFromZero = math.sqrt(GMM_C.CameraPosition.x * GMM_C.CameraPosition.x + GMM_C.CameraPosition.y * GMM_C.CameraPosition.y)

    local FromZeroMinDistance = 500
    local FromZeroMaxDistance = 20000
    local FromZeroPower = math.Clamp((DistanceFromZero - FromZeroMinDistance) / (FromZeroMaxDistance - FromZeroMinDistance), 0, 1)

    local Power = FromZeroPower * FromZeroPower

    if GMM.Maps.Goofy then
        Power = Power * 20 + 0.25
    end

    if Power <= 0.0001 then return end

    local FramePower = Power * 0.5

    local W, H = ScrW(), ScrH()
    local CT = CurTime()

    cam.Start2D()
        for i = 1, math.floor(10 + 60 * Power) do
            if math.random() > (1 - 0.3 * Power) then
                surface.SetDrawColor(
                    math.random(0, 255), math.random(0, 255), math.random(0, 255),
                    math.Clamp(math.random(5, 10) * Power, 0, 60)
                )
                surface.DrawRect(0, math.random(0, H), W, math.random(1, math.floor(1 + 50 * Power)))
            end
        end
    
        if FramePower > 0.001 then
            for i = 1, math.floor(1 + 5 * FramePower) do
                local Scale = 1.3 + math.sin(CT * 2) * 0.05 * FramePower
                local Rotation = math.sin(CT * 5) * 2 * i * i * FramePower
                local OffsetX = math.random(-5, 5) * math.sin(CT * 10 * i) * FramePower * 3
                local OffsetY = math.cos(CT * 8 * i) * 10 * FramePower
    
                surface.SetMaterial(__VoidGlitchMaterial)
                surface.SetDrawColor(
                    100 + math.sin(CT * 3) * 155,
                    math.random(0, 50) * FramePower,
                    math.cos(CT * 2) * 255,
                    math.Clamp(200 * FramePower, 0, 200)
                )
    
                surface.DrawTexturedRectRotated(
                    W /2 + OffsetX,
                    H /2 + OffsetY,
                    W * Scale,
                    H * Scale,
                    Rotation
                )
            end
        end
    cam.End2D()

    DrawColorModify({
        ["$pp_colour_addr"      ] = math.sin(CT * 10) * 0.1 * Power,
        ["$pp_colour_addg"      ] = math.sin(CT * 15) * 0.1 * Power,
        ["$pp_colour_addb"      ] = math.cos(CT * 20) * 0.1 * Power,
        ["$pp_colour_brightness"] = -0.5 * Power,
        ["$pp_colour_contrast"  ] = 1 + 3 * Power,
        ["$pp_colour_colour"    ] = 1 + 1 * Power,
        ["$pp_colour_mulr"      ] = 1 - Power,
        ["$pp_colour_mulg"      ] = 1 - Power,
        ["$pp_colour_mulb"      ] = 1 - Power
    })
end)