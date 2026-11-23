do
    if CLIENT then
        local MaterialPath = "woowz_map/gm_garrymod_map_by_woowz_map_garry_game/water_silent_glitch"

        local Mat = Material(MaterialPath)
        if not Mat or Mat:IsError() then
            print("[GMM] Water glitch material not found: " .. MaterialPath)
            return
        end

        local Rand = math.Rand
        local Sin = math.sin

        local function R01()
            return Rand(0, 1)
        end

        local function RandomColor()
            return Vector(R01(), R01(), R01())
        end

        local function ScrambleColor(Col)
            return Vector(
                    1 - Col.x,
                    (Col.y + R01()) % 1,
                    (Col.z * Rand(2, 5)) % 1
            )
        end

        local NextUpdate = 0
        local NextJump = 0
        local NextInvert = 0
        local NextScrollSpike = 0
        local NextFreeze = 0
        local FrozenUntil = 0
        local FrozenColor = Vector(0, 0, 0)
        local CurrentColor = RandomColor()
        local TargetColor = RandomColor()
        local ScrollMul = 1
        local BaseScroll1 = Vector(0.03, 0.06, 0)
        local BaseScroll2 = Vector(-0.05, 0.01, 0)

        hook.Add("Think", "GMM_WaterGlitch", function()
            local Now = CurTime()

            if Now < FrozenUntil then
                Mat:SetVector("$fogcolor", FrozenColor)
                Mat:SetVector("$color", FrozenColor)
                Mat:SetVector("$color2", ScrambleColor(FrozenColor))
                Mat:SetVector("$selfillumtint", FrozenColor)
                return
            end

            if Now >= NextFreeze then
                FrozenUntil = Now + Rand(0.05, 0.4)
                FrozenColor = RandomColor()
                NextFreeze = Now + Rand(1, 4)
            end

            if Now >= NextUpdate then
                NextUpdate = Now + Rand(0.02, 0.15)
                CurrentColor = TargetColor
                TargetColor = RandomColor()
            end

            if Now >= NextJump then
                NextJump = Now + Rand(0.3, 1.5)
                CurrentColor = RandomColor()
                TargetColor = RandomColor()
            end

            if Now >= NextInvert then
                NextInvert = Now + Rand(0.5, 2)
                CurrentColor = ScrambleColor(CurrentColor)
            end

            if Now >= NextScrollSpike then
                NextScrollSpike = Now + Rand(0.2, 1.2)
                ScrollMul = Rand(0.5, 15)
            end

            local T = (Now * Rand(5, 20)) % 1
            local Col = Vector(
                    (CurrentColor.x + (TargetColor.x - CurrentColor.x) * T + Rand(-0.3, 0.3)) % 1,
                    (CurrentColor.y + (TargetColor.y - CurrentColor.y) * T + Rand(-0.3, 0.3)) % 1,
                    (CurrentColor.z + (TargetColor.z - CurrentColor.z) * T + Rand(-0.3, 0.3)) % 1
            )

            if Sin(Now * 27.3) > 0.7 then
                Col = Vector(Col.z, Col.x, Col.y)
            end

            if Sin(Now * 41.7) > 0.85 then
                Col = Vector(1 - Col.x, 1 - Col.y, 1 - Col.z)
            end

            if Sin(Now * 13.1) > 0.95 then
                Col = Vector(0, 0, 0)
            end

            Mat:SetVector("$fogcolor", Col)
            Mat:SetVector("$color", Col)
            Mat:SetVector("$color2", ScrambleColor(Col))

            Mat:SetVector("$scroll1", BaseScroll1 * ScrollMul + Vector(Rand(-0.2, 0.2), Rand(-0.2, 0.2), 0))
            Mat:SetVector("$scroll2", BaseScroll2 * ScrollMul + Vector(Rand(-0.2, 0.2), Rand(-0.2, 0.2), 0))

            local Glow = Rand(0, 3)
            Mat:SetVector("$selfillumtint", Vector(Col.x * Glow, Col.y * Glow, Col.z * Glow))

            local ScaleX = Rand(0.1, 2.5)
            local ScaleY = Rand(0.1, 2.5)
            local Rotate = Rand(-360, 360)

            Mat:SetUndefined(
                    "$bumptransform",
                    string.format("center 0 0 scale %.4f %.4f rotate %.2f translate %.2f %.2f",
                            ScaleX, ScaleY, Rotate, Rand(-1, 1), Rand(-1, 1))
            )

            if Sin(Now * 7.7) > 0.98 then
                Mat:SetFloat("$alpha", Rand(0.05, 1))
            end
        end)
    end
end

do
    local Active = GMM.Maps.Default or GMM.Maps.Old or GMM.Maps.Dark

    local OldTrip = GMM_PisechnikTrip
    if OldTrip ~= nil and OldTrip.Cleanup ~= nil then pcall(OldTrip.Cleanup) end

    local Trip = {}
    GMM_PisechnikTrip = Trip

    -- ----------------------------------------------------------------------
    -- Общее
    -- ----------------------------------------------------------------------

    local TrancePos     = Vector(-2421, 574, 588)
    local ZoneRadius    = 120
    local ZoneHeight    = 120
    local ZoneRadiusSqr = ZoneRadius * ZoneRadius

    local FillSeconds  = 120
    local DrainSeconds = 40
    local SlowStart    = 0.4
    local SlowMin      = 0.05
    local JumpBlock    = 0.5

    local NetName = "gmm_Pisech_Sick"

    if Active then
        hook.Add("SetupMove", "gmm_Pisech_Move", function(Ply, Mv, Cmd)
            local Level = Ply:GetNWFloat(NetName, 0)
            if Level <= SlowStart then return end
            if Ply:GetMoveType() == MOVETYPE_NOCLIP then return end

            local K     = (Level - SlowStart) / (1 - SlowStart)
            local Scale = Lerp(K, 1, SlowMin)

            Mv:SetMaxSpeed(Mv:GetMaxSpeed() * Scale)
            Mv:SetMaxClientSpeed(Mv:GetMaxClientSpeed() * Scale)

            if Level > JumpBlock then
                Mv:SetButtons(bit.band(Mv:GetButtons(), bit.bnot(IN_JUMP)))
            end
        end)
    end

    -- ----------------------------------------------------------------------
    -- Сервер: накопление, смерть
    -- ----------------------------------------------------------------------

    if Active and SERVER then
        local TickDelay  = 0.1
        local DeathDelay = 5

        local function IsInside(Ply)
            if not Ply:Alive() then return false end
            if Ply:GetMoveType() == MOVETYPE_NOCLIP then return false end

            local Delta = Ply:GetPos() - TrancePos
            if math.abs(Delta.z) > ZoneHeight then return false end

            return Delta:Length2DSqr() < ZoneRadiusSqr
        end

        local function KillPlayer(Ply)
            print("[GMM] PISECHNIK TRANCE KILL! PLAYER: " .. Ply:Nick())

            Ply.GMMPisechEnd = nil

            Ply:SetNWFloat(NetName, 0)
            Ply:Kill()
        end

        local function Tick()
            local Now = CurTime()

            for _, Ply in ipairs(player.GetAll()) do
                local Level = Ply:GetNWFloat(NetName, 0)
                local Next  = Level

                if not Ply:Alive() then
                    Ply.GMMPisechEnd = nil
                    Next = 0
                elseif Ply.GMMPisechEnd ~= nil then
                    if Now >= Ply.GMMPisechEnd then
                        KillPlayer(Ply)
                        Next = 0
                    else
                        Next = 1
                    end
                elseif IsInside(Ply) then
                    Next = Level + TickDelay / FillSeconds
                else
                    Next = Level - TickDelay / DrainSeconds
                end

                Next = math.Clamp(Next, 0, 1)

                if Next ~= Level then Ply:SetNWFloat(NetName, Next) end
                if Next >= 1 and Ply.GMMPisechEnd == nil then Ply.GMMPisechEnd = Now + DeathDelay end
            end
        end

        timer.Create("gmm_Pisech_Tick", TickDelay, 0, function() Tick() end)

        Trip.Cleanup = function()
            timer.Remove("gmm_Pisech_Tick")
            hook.Remove("SetupMove", "gmm_Pisech_Move")
        end
    end

    -- ----------------------------------------------------------------------
    -- Клиент: музыка, эффекты, модельки
    -- ----------------------------------------------------------------------

    if Active and CLIENT then
        local MusicPath        = GMM.Maps.Dark and "sound/music/radio1.mp3" or "sound/music/hl1_song25_remix3.mp3"
        local MusicRadius      = 200
        local MusicVolume      = 50
        local MusicFadeSeconds = 5

        local MusicRateSlow   = 0.5
        local MusicRateCenter = 0.85
        local MusicRateSwing  = 0.7
        local MusicRateMin    = 0.15
        local MusicSineStart  = 0.5
        local MusicSineSpeed  = 0.6

        local ModelPath     = "models/woowz11/player/pisechnik_stilllife.mdl"
        local ModelColor    = Vector(1, 0, 0)
        local ModelMax      = 5
        local ModelStart    = 0.3
        local ModelFade     = 0.1
        local ModelScale    = 0.6
        local ModelDistFar  = 170
        local ModelDistNear = 100
        local ModelOrbit    = 80
        local ModelSpeed    = 1.2
        local ModelGlitch   = 0.03
        local AnimList = {
            "pose_ducking_01",
            "pose_ducking_02",
            "menu_zombie_01",
            "cidle_camera",
            "cwalk_knife",
            "idle_all_cower",
            "idle_all_scared",
            "idle_fist",
            "run_all_01",
            "swim_idle_all",
            "taunt_dance",
            "taunt_laugh",
            "taunt_muscle",
            "taunt_persistence",
            "taunt_zombie_original",
            "walk_all",
            "zombie_leap_mid",
            "zombie_walk_06",
        }

        local AnimWarned = false

        local RiseSpeed     = 1.2
        local EffectCurve   = 1.8
        local SwayPitch     = 9
        local SwayYaw       = 12
        local SwayRoll      = 10
        local SwayMove      = 3
        local SwayFov       = 12
        local DarkStart     = 0.55
        local BlackLevel    = 0.985
        local VignetteRings    = 24
        local VignetteSegments = 48
        local VignetteReach    = 1.5
        local VignetteWidth    = 0.8
        local VignettePulse    = 0.08
        local VignetteSpeed    = 2.5

        local ColorMod = {
            ["$pp_colour_addr"]       = 0,
            ["$pp_colour_addg"]       = 0,
            ["$pp_colour_addb"]       = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"]   = 1,
            ["$pp_colour_colour"]     = 1,
            ["$pp_colour_mulr"]       = 0,
            ["$pp_colour_mulg"]       = 0,
            ["$pp_colour_mulb"]       = 0,
        }

        local VignetteMaterial = CreateMaterial("gmm_Pisech_Vignette", "UnlitGeneric", {
            ["$basetexture"]  = "color/white",
            ["$vertexcolor"]  = 1,
            ["$vertexalpha"]  = 1,
            ["$translucent"]  = 1,
            ["$nocull"]       = 1,
            ["$ignorez"]      = 1,
        })

        local VignetteCos    = {}
        local VignetteSin    = {}
        local VignetteAlpha  = {}
        local VignetteVector = Vector()

        for i = 0, VignetteSegments do
            local Angle = i / VignetteSegments * math.pi * 2

            VignetteCos[i] = math.cos(Angle)
            VignetteSin[i] = math.sin(Angle)
        end

        for i = 0, VignetteRings do
            VignetteAlpha[i] = 0
        end

        local function VignetteVertex(X, Y, Alpha)
            VignetteVector:SetUnpacked(X, Y, 0)

            mesh.Position(VignetteVector)
            mesh.Color(0, 0, 0, Alpha)
            mesh.AdvanceVertex()
        end

        local function DrawVignette(Dark)
            local CenterX = ScrW() * 0.5
            local CenterY = ScrH() * 0.5
            local Start   = Lerp(Dark, 1.5, -VignetteWidth - VignettePulse) + math.sin(RealTime() * VignetteSpeed) * VignettePulse
            local First   = nil

            for i = 0, VignetteRings do
                local T = i / VignetteRings * VignetteReach
                local K = math.Clamp((T - Start) / VignetteWidth, 0, 1)

                VignetteAlpha[i] = K * K * (3 - 2 * K) * 255

                if First == nil and VignetteAlpha[i] > 0 then First = i end
            end

            if First == nil then return end

            First = math.max(First, 1)

            render.SetMaterial(VignetteMaterial)
            mesh.Begin(MATERIAL_QUADS, (VignetteRings - First + 1) * VignetteSegments)

            for Ring = First, VignetteRings do
                local InnerR = (Ring - 1) / VignetteRings * VignetteReach
                local OuterR = Ring / VignetteRings * VignetteReach
                local InnerA = VignetteAlpha[Ring - 1]
                local OuterA = VignetteAlpha[Ring]

                local InnerX = CenterX * InnerR
                local InnerY = CenterY * InnerR
                local OuterX = CenterX * OuterR
                local OuterY = CenterY * OuterR

                for i = 1, VignetteSegments do
                    local Cos0 = VignetteCos[i - 1]
                    local Sin0 = VignetteSin[i - 1]
                    local Cos1 = VignetteCos[i]
                    local Sin1 = VignetteSin[i]

                    VignetteVertex(CenterX + Cos0 * InnerX, CenterY + Sin0 * InnerY, InnerA)
                    VignetteVertex(CenterX + Cos0 * OuterX, CenterY + Sin0 * OuterY, OuterA)
                    VignetteVertex(CenterX + Cos1 * OuterX, CenterY + Sin1 * OuterY, OuterA)
                    VignetteVertex(CenterX + Cos1 * InnerX, CenterY + Sin1 * InnerY, InnerA)
                end
            end

            mesh.End()
        end

        local ViewData   = {}
        local ViewAngles = Angle()
        local ViewOrigin = Vector()

        local Level     = 0
        local Target    = 0
        local Effect    = 0
        local SwayPhase = 0
        local BlackAt   = nil
        local Session   = 0

        local Music        = nil
        local MusicLoading = false
        local MusicFailed  = false

        local Models      = {}
        local ModelCount  = 0
        local HasModels   = false
        local ModelFailed = false

        local function GetDark()
            return math.Clamp((Level - DarkStart) / (BlackLevel - DarkStart), 0, 1)
        end

        local function GetMusicRate()
            local Rate = Lerp(math.Clamp(Level / MusicSineStart, 0, 1), 1, MusicRateSlow)

            if Level <= MusicSineStart then return Rate end

            local SineK  = (Level - MusicSineStart) / (1 - MusicSineStart)
            local Center = Lerp(SineK, MusicRateSlow, MusicRateCenter)
            local Swing  = MusicRateSwing * SineK

            return math.max(MusicRateMin, Center + math.sin(RealTime() * MusicSineSpeed) * Swing)
        end

        local function LoadMusic()
            if not file.Exists(MusicPath, "GAME") then
                print("[GMM] PISECHNIK MUSIC NOT FOUND! FILE: " .. MusicPath)
                MusicFailed = true
                return
            end

            MusicLoading = true

            local MySession = Session

            sound.PlayFile(MusicPath, "noplay", function(Channel, Code, Name)
                MusicLoading = false

                if MySession ~= Session then
                    if IsValid(Channel) then Channel:Stop() end
                    return
                end

                if not IsValid(Channel) then
                    print("[GMM] PISECHNIK MUSIC LOAD FAILED! FILE: " .. MusicPath .. ", CODE: " .. tostring(Code) .. ", NAME: " .. tostring(Name))
                    MusicFailed = true
                    return
                end

                Channel:EnableLooping(true)
                Channel:SetVolume(0)

                Music = Channel
            end)
        end

        local function UpdateMusic(Ply)
            if MusicFailed or MusicLoading then return end

            if not Ply:Alive() then
                if IsValid(Music) and Music:GetState() == GMOD_CHANNEL_PLAYING then Music:Pause() end
                return
            end

            local Dist = Ply:EyePos():Distance(TrancePos)
            local Fall = 1 - math.Clamp(Dist / MusicRadius, 0, 1)

            if Music == nil then
                if Fall > 0 then LoadMusic() end
                return
            end

            if not IsValid(Music) then
                Music = nil
                return
            end

            if Fall <= 0 then
                if Music:GetState() == GMOD_CHANNEL_PLAYING then Music:Pause() end
                return
            end

            if Music:GetState() ~= GMOD_CHANNEL_PLAYING then Music:Play() end

            local Volume = MusicVolume * Fall

            if BlackAt ~= nil then
                Volume = Volume * (1 - math.Clamp((RealTime() - BlackAt) / MusicFadeSeconds, 0, 1))
            end

            Music:SetPlaybackRate(GetMusicRate())
            Music:SetVolume(Volume)
        end

        local function PickSequence(Ent)
            local List = {}

            for _, Name in ipairs(AnimList) do
                local Sequence = Ent:LookupSequence(Name)

                if Sequence >= 0 then
                    List[#List + 1] = Sequence
                elseif not AnimWarned then
                    print("[GMM] PISECHNIK ANIMATION NOT FOUND! NAME: " .. Name)
                end
            end

            AnimWarned = true

            if #List == 0 then return 0 end

            return List[math.random(#List)]
        end

        local function CreateModel(Index)
            if ModelFailed then return end

            if not util.IsValidModel(ModelPath) then
                print("[GMM] PISECHNIK STILLLIFE MODEL NOT FOUND! MODEL: " .. ModelPath)
                ModelFailed = true
                return
            end

            local Ent = ClientsideModel(ModelPath, RENDERGROUP_OTHER)
            if not IsValid(Ent) then
                print("[GMM] PISECHNIK STILLLIFE CREATE FAILED! MODEL: " .. ModelPath)
                ModelFailed = true
                return
            end

            Ent:SetNoDraw(true)
            Ent:SetModelScale(ModelScale, 0)
            Ent.GetPlayerColor = function() return ModelColor end
            Ent.GMMPhase = Index * (math.pi * 2 / ModelMax)
            Ent.GMMCycle = math.Rand(0, 1)
            Ent:SetSequence(PickSequence(Ent))

            Models[Index] = Ent
            HasModels     = true
        end

        local function RemoveModels()
            for i = 1, ModelMax do
                if IsValid(Models[i]) then Models[i]:Remove() end
                Models[i] = nil
            end

            HasModels  = false
            ModelCount = 0
        end

        local function GetModelWant()
            if Level <= ModelStart then return 0 end

            local K = (Level - ModelStart) / (1 - ModelStart)

            return math.min(ModelMax, 1 + math.floor(K * ModelMax))
        end

        local function UpdateModels(Dt)
            local Want = GetModelWant()

            if Want == 0 then
                if HasModels then RemoveModels() end
                return
            end

            ModelCount = Want

            for i = 1, Want do
                if not IsValid(Models[i]) then CreateModel(i) end

                local Ent = Models[i]

                if IsValid(Ent) then
                    Ent.GMMCycle = Ent.GMMCycle + Dt * (0.5 + Level * 1.5)

                    if math.random() < ModelGlitch * Level then Ent.GMMCycle = math.Rand(0, 1) end
                    if math.random() < 0.01 * Level then Ent:SetSkin(math.random(0, math.max(0, Ent:SkinCount() - 1))) end

                    Ent:SetCycle(Ent.GMMCycle % 1)
                end
            end
        end

        hook.Add("Think", "gmm_Pisech_Think", function()
            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            local Dt = FrameTime()

            if Ply:Alive() then
                Target = Ply:GetNWFloat(NetName, 0)
            else
                Target = 0
                Level  = 0
            end

            Level = Level + (Target - Level) * math.min(1, Dt * RiseSpeed)
            if Level < 0.001 then Level = 0 end

            Effect    = Level ^ EffectCurve
            SwayPhase = SwayPhase + Dt * (0.8 + 1.4 * Effect)

            if Level >= BlackLevel then
                if BlackAt == nil then BlackAt = RealTime() end
            else
                BlackAt = nil
            end

            UpdateMusic(Ply)
            UpdateModels(Dt)
        end)

        hook.Add("CalcView", "gmm_Pisech_View", function(Ply, Pos, Angles, Fov)
            if Effect <= 0.005 then return end

            local Power = Effect
            local Phase = SwayPhase
            local Cos   = math.cos(Phase)
            local Sin   = math.sin(Phase)

            ViewAngles.p = Angles.p + Sin * SwayPitch * Power
            ViewAngles.y = Angles.y + Cos * SwayYaw * Power
            ViewAngles.r = Angles.r + math.sin(Phase * 0.7 + 1) * SwayRoll * Power

            ViewOrigin:Set(Pos)
            ViewOrigin:Add(Angles:Right() * (Cos * SwayMove * Power))
            ViewOrigin:Add(Angles:Up() * (Sin * SwayMove * Power))

            ViewData.origin = ViewOrigin
            ViewData.angles = ViewAngles
            ViewData.fov    = Fov + math.sin(Phase * 0.5) * SwayFov * Power

            return ViewData
        end)

        hook.Add("RenderScreenspaceEffects", "gmm_Pisech_Screen", function()
            if Effect <= 0.005 then return end

            local Now   = RealTime()
            local Power = Effect
            local Dark  = GetDark()

            local WaveR = 0.5 + 0.5 * math.sin(Now * 1.3)
            local WaveG = 0.5 + 0.5 * math.sin(Now * 1.9 + 2.1)
            local WaveB = 0.5 + 0.5 * math.sin(Now * 2.4 + 4.2)

            ColorMod["$pp_colour_addr"]       = Power * 0.12 * WaveR
            ColorMod["$pp_colour_addg"]       = Power * 0.12 * WaveG
            ColorMod["$pp_colour_addb"]       = Power * 0.12 * WaveB
            ColorMod["$pp_colour_brightness"] = 0.12 * Power * (1 - Dark) - 0.2 * Dark
            ColorMod["$pp_colour_contrast"]   = 1 + 0.4 * Power
            ColorMod["$pp_colour_colour"]     = 1 + 3 * Power
            DrawColorModify(ColorMod)

            DrawMotionBlur(math.max(0.1, 1 - 0.9 * Power), 0.8, 0.02)
            DrawBloom(0.4, 3 * Power, 3 + 8 * Power, 3 + 8 * Power, 2, 1, 0.6 + 0.4 * WaveR, 0.6 + 0.4 * WaveG, 0.6 + 0.4 * WaveB)

            if Power > 0.5 then
                local K = (Power - 0.5) / 0.5

                DrawToyTown(1 + math.floor(K * 2), ScrH() * 0.4 * K)
            end
        end)

        hook.Add("PostDrawTranslucentRenderables", "gmm_Pisech_Models", function(Depth, Skybox, Sky3D)
            if Depth or Skybox or Sky3D then return end
            if ModelCount == 0 then return end

            local Eye     = EyePos()
            local EyeAng  = EyeAngles()
            local Forward = EyeAng:Forward()
            local Right   = EyeAng:Right()
            local Up      = EyeAng:Up()
            local Now     = RealTime()
            local Span    = 1 - ModelStart
            local Close   = math.Clamp((Level - ModelStart) / Span, 0, 1)
            local Dist    = Lerp(Close, ModelDistFar, ModelDistNear)
            local Radius  = ModelOrbit * (1.2 - 0.2 * Close)
            local Middle  = Eye + Forward * Dist

            cam.IgnoreZ(true)

            for i = 1, ModelCount do
                local Ent = Models[i]

                if IsValid(Ent) then
                    local Threshold = ModelStart + (i - 1) / ModelMax * Span
                    local Alpha     = math.Clamp((Level - Threshold) / ModelFade, 0, 1)
                    local Angle     = Now * ModelSpeed + Ent.GMMPhase
                    local Pos       = Middle + Right * (math.cos(Angle) * Radius) + Up * (math.sin(Angle) * Radius * 0.7)

                    Pos.z = Pos.z - ModelScale * 36

                    local Look = (Eye - Pos):Angle()
                    Look.p = 0
                    Look.r = math.sin(Now * 3 + Ent.GMMPhase) * 15 * Level

                    Ent:SetPos(Pos)
                    Ent:SetAngles(Look)

                    render.SetBlend(Alpha)
                    Ent:DrawModel()
                end
            end

            render.SetBlend(1)
            cam.IgnoreZ(false)
        end)

        hook.Add("HUDPaint", "gmm_Pisech_Dark", function()
            local Dark = GetDark()
            if Dark <= 0 then return end

            if Dark >= 1 then
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, ScrW(), ScrH())
                return
            end

            DrawVignette(Dark)
        end)

        Trip.Cleanup = function()
            Session = Session + 1

            RemoveModels()

            if IsValid(Music) then Music:Stop() end

            hook.Remove("Think", "gmm_Pisech_Think")
            hook.Remove("CalcView", "gmm_Pisech_View")
            hook.Remove("RenderScreenspaceEffects", "gmm_Pisech_Screen")
            hook.Remove("PostDrawTranslucentRenderables", "gmm_Pisech_Models")
            hook.Remove("HUDPaint", "gmm_Pisech_Dark")
            hook.Remove("SetupMove", "gmm_Pisech_Move")
        end
    end
end