GMM_C.Void = {}

GMM_C.Func.CameraInVoid = function()
    if not IsValid(GMM_C.Player) then return false end
    return bit.band(util.PointContents(GMM_C.CameraPosition), CONTENTS_SOLID) == CONTENTS_SOLID
end

GMM_C.Func.IsVoidForced = function()
    return GMM.ConVars.GetInt("void") == 3 or GMM.Maps.Goofy
end

GMM_C.Func.IsVoidActive = function()
    if GMM_C.Func.IsVoidForced() then return true end
    if not GMM.Func.DoVoid() then return false end

    return GMM_C.Func.CameraInVoid()
end

local MusicChannel = nil
local MusicLoading = false

local RateDrift     = 1
local RateDriftGoal = 1
local RateNextGoal  = 0
local RateLastTime  = 0

local SpikeActive   = false
local SpikeNext     = 0
local SpikeStart    = 0
local SpikeDuration = 1
local SpikeTarget   = 1

local function GetMusicRate()
    local Now   = CurTime()
    local Delta = math.Clamp(Now - RateLastTime, 0, 0.2)
    RateLastTime = Now

    if Now >= RateNextGoal then
        RateNextGoal  = Now + math.Rand(1.5, 7)
        RateDriftGoal = math.Rand(0.8, 1.25)
    end

    RateDrift = Lerp(math.min(Delta * 0.8, 1), RateDrift, RateDriftGoal)

    local Wobble = math.sin(Now * 0.5) * 0.08 + math.sin(Now * 1.3 + 1.7) * 0.05 + math.sin(Now * 3.1 + 4.2) * 0.025
    local Rate   = RateDrift + Wobble

    if SpikeNext == 0 then SpikeNext = Now + math.Rand(60, 240) end

    if not SpikeActive and Now >= SpikeNext then
        SpikeActive   = true
        SpikeStart    = Now
        SpikeDuration = math.Rand(1.5, 5)

        if math.random() < 0.5 then
            SpikeTarget = math.Rand(0.35, 0.6)
        else
            SpikeTarget = math.Rand(1.8, 2.8)
        end
    end

    if SpikeActive then
        local Progress = (Now - SpikeStart) / SpikeDuration

        if Progress >= 1 then
            SpikeActive = false
            SpikeNext   = Now + math.Rand(60, 240)
        else
            local Envelope = math.sin(Progress * math.pi)
            Rate = Lerp(Envelope, Rate, SpikeTarget)
        end
    end

    return math.Clamp(Rate, 0.25, 3)
end

GMM_C.Void.Think = function()
    if true then
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

        if GMM_C.Func.IsVoidActive() and VoidVolume > 0.001 then
            if not IsValid(MusicChannel) then
                if MusicLoading then return end
                MusicLoading = true

                sound.PlayFile("sound/woowz/music/ManiyaVelichiaGOLUFUNNY.wav", "noplay loop", function(Station, ErrCode, ErrStr)
                    MusicLoading = false

                    if not IsValid(Station) then return end

                    local Length = Station:GetLength()
                    if Length > 1 then Station:SetTime(math.Rand(0, Length - 1)) end

                    MusicChannel = Station
                    MusicChannel:SetVolume(0)
                    MusicChannel:Play()
                end)
            else
                if MusicChannel:GetState() ~= GMOD_CHANNEL_PLAYING then
                    MusicChannel:Play()
                end


                MusicChannel:SetVolume(VoidVolume)
                MusicChannel:SetPlaybackRate(GetMusicRate())
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
    if not GMM_C.Func.IsVoidActive() then return end

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
    if not GMM_C.Func.IsVoidActive() then return end

    local DistanceFromZero = math.sqrt(GMM_C.CameraPosition.x * GMM_C.CameraPosition.x + GMM_C.CameraPosition.y * GMM_C.CameraPosition.y)

    local FromZeroMinDistance = 500
    local FromZeroMaxDistance = 20000
    local FromZeroPower = math.Clamp((DistanceFromZero - FromZeroMinDistance) / (FromZeroMaxDistance - FromZeroMinDistance), 0, 1)

    local Power = FromZeroPower * FromZeroPower

    if GMM.Maps.Goofy then
        Power = Power * 15 + 0.25
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