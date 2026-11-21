local CorrectMap = game.GetMap() == "gmm_garrymod_map_by_woowz_help_me"

if SERVER and CorrectMap then
    local function SpawnRandomGMMError()
		if #ents.FindByClass("gmm_download_map") >= 150 then return end
	
        if math.random() > 0.05 then return end

        local SpawnPos = Vector(math.random(-10000, 10000), math.random(-3000, 3000), math.random(-10000, 10000))

        local Ent = ents.Create("gmm_download_map")
        if IsValid(Ent) then
            Ent:SetPos(SpawnPos)
            Ent:Spawn()
        end
    end

    timer.Create("GMM_RandomSpawnTimer", not GMM and 0.1 or 0.5, 0, function()
        SpawnRandomGMMError()
    end)
end

if not GMM and CLIENT and CorrectMap then

    local CONFIG = {
        Height      = 30,
        Speed       = 200,
        Text        = "★ DOWNLOAD => https://steamcommunity.com/sharedfiles/filedetails/?id=3813588732 ★   ",
        TextColor   = Color(255, 0, 0),
        TextSize    = 24,
        Font        = "MarqueeFont",
        TopColor    = Color(40, 0, 0, 220),
        BottomColor = Color(40, 0, 0, 220),
        TopDir      = 1,
        BottomDir   = -1,
        Gap         = 200,
    }

    surface.CreateFont("MarqueeFont", {
        font      = "Consolas",
        size      = CONFIG.TextSize,
        weight    = 700,
        antialias = true,
        extended  = true,
    })

    local function MeasureText(text)
        surface.SetFont(CONFIG.Font)
        local Anchor = "|"
        local WithAnchor = surface.GetTextSize(text .. Anchor)
        local AnchorW = surface.GetTextSize(Anchor)
        return WithAnchor - AnchorW
    end

    local TopOffset = 0
    local BottomOffset = 0

	local function DrawMarquee(y, offset, dir, bgColor)
		local SW = ScrW()

		surface.SetDrawColor(bgColor)
		surface.DrawRect(0, y, SW, CONFIG.Height)

		surface.SetFont(CONFIG.Font)
		surface.SetTextColor(CONFIG.TextColor)

		local TextW = MeasureText(CONFIG.Text)
		local Step = TextW + CONFIG.Gap

		local Count = math.ceil(SW / Step) + 3

		local StartX = offset - Step

		local TextY = y + (CONFIG.Height - CONFIG.TextSize) / 2

		for i = 0, Count do
			local x = StartX + i * Step
			surface.SetTextPos(x, TextY)
			surface.DrawText(CONFIG.Text)
		end
	end

    hook.Add("HUDPaint", "MarqueeHUD", function()
        local FT = FrameTime()

        local TextW = MeasureText(CONFIG.Text)
        local Step = TextW + CONFIG.Gap

        TopOffset = (TopOffset + CONFIG.Speed * FT * CONFIG.TopDir)    % Step
        BottomOffset = (BottomOffset + CONFIG.Speed * FT * CONFIG.BottomDir) % Step

        if TopOffset < 0 then TopOffset = TopOffset + Step
        end
        if BottomOffset < 0 then BottomOffset = BottomOffset + Step
        end

        DrawMarquee(0, TopOffset, CONFIG.TopDir, CONFIG.TopColor)
        DrawMarquee(ScrH() - CONFIG.Height, BottomOffset, CONFIG.BottomDir, CONFIG.BottomColor)
    end)

end

if CorrectMap then
	local OldHole = GMM_BlackHole
    if OldHole ~= nil and OldHole.Cleanup ~= nil then pcall(OldHole.Cleanup) end

    local Hole = {}
    GMM_BlackHole = Hole

    -- ----------------------------------------------------------------------
    -- Общее
    -- ----------------------------------------------------------------------

    local Center     = Vector(-1606, 2551, -419)
    local HoleRadius = 150
    local CoreRadius = 180
    local PullRadius = 1100

    local CoreRadiusSqr = CoreRadius * CoreRadius
    local PullRadiusSqr = PullRadius * PullRadius

    local function Hash(Value)
        local Result = math.sin(Value * 12.9898) * 43758.5453
        return Result - math.floor(Result)
    end

    -- ----------------------------------------------------------------------
    -- Сервер: физика
    -- ----------------------------------------------------------------------

    if SERVER then
        util.AddNetworkString("gmm_BlackHole_Eat")

        local PhysicsDelay    = 0.05
        local ActiveRadiusSqr = (PullRadius + 1500) * (PullRadius + 1500)

        local PullPlayer = 1500
        local PullProp   = 1800
        local PullNpc    = 1200
        local KillPlayers = true

        local EatSound = "ambient/energy/zap9.wav"
        local NextEat  = 0

        local function HasPlayerNearby()
            for _, Ply in ipairs(player.GetAll()) do
                if Ply:GetPos():DistToSqr(Center) < ActiveRadiusSqr then return true end
            end

            return false
        end

        local function IsPullable(Ent)
            if not IsValid(Ent) then return false end

            if Ent:IsPlayer() then
                if not Ent:Alive() then return false end
                if Ent:InVehicle() then return false end
                if Ent:GetMoveType() == MOVETYPE_NOCLIP then return false end
                return true
            end

            if Ent:IsNPC() or Ent:IsNextBot() then return true end
            if Ent:IsWeapon() then return false end
            if IsValid(Ent:GetParent()) then return false end
            if Ent:GetMoveType() ~= MOVETYPE_VPHYSICS then return false end

            return true
        end

        local function PullPhysics(Ent, Power, Dir)
            local Add = Dir * PullProp * Power * PhysicsDelay

            for i = 0, Ent:GetPhysicsObjectCount() - 1 do
                local Phys = Ent:GetPhysicsObjectNum(i)

                if IsValid(Phys) and Phys:IsMotionEnabled() then
                    Phys:Wake()
                    Phys:AddVelocity(Add)

                    if Power > 0.15 then
                        Phys:AddAngleVelocity(VectorRand() * 25 * Power)
                    end
                end
            end
        end

        local function PullEntity(Ent, Power, Dir)
            if Ent:IsPlayer() then
                Ent:SetVelocity(Dir * PullPlayer * Power * PhysicsDelay)
                return
            end

            if Ent:IsNextBot() then
                local Loco = Ent.loco
                if Loco == nil then return end

                Loco:SetVelocity(Loco:GetVelocity() + Dir * PullNpc * Power * PhysicsDelay)
                return
            end

            if Ent:IsNPC() then
                Ent:SetVelocity(Dir * PullNpc * Power * PhysicsDelay)
                return
            end

            if Ent:IsPlayerHolding() then return end

            PullPhysics(Ent, Power, Dir)
        end

        local function Eat(Ent)
            if Ent:IsPlayer() then
                if not KillPlayers then return false end

                Ent:Kill()
                return true
            end

            Ent:Remove()
            return true
        end

        local function OnEat()
            local Now = CurTime()
            if Now < NextEat then return end
            NextEat = Now + 0.2

            sound.Play(EatSound, Center, 90, math.random(35, 60))

            net.Start("gmm_BlackHole_Eat")
            net.Broadcast()
        end

        local function ProcessEntity(Ent)
            if not IsPullable(Ent) then return false end

            local Pos     = Ent:WorldSpaceCenter()
            local DistSqr = Pos:DistToSqr(Center)
            if DistSqr >= PullRadiusSqr then return false end

            if DistSqr < CoreRadiusSqr then
                return Eat(Ent)
            end

            local Fraction = 1 - math.sqrt(DistSqr) / PullRadius
            local Dir      = (Center - Pos):GetNormalized()

            PullEntity(Ent, Fraction * Fraction, Dir)

            return false
        end

        local function PhysicsTick()
            if not HasPlayerNearby() then return end

            local Found = ents.FindInSphere(Center, PullRadius)
            local Ate   = false

            for i = 1, #Found do
                if ProcessEntity(Found[i]) then Ate = true end
            end

            if Ate then OnEat() end
        end

        timer.Create("gmm_BlackHole_Physics", PhysicsDelay, 0, function() PhysicsTick() end)

        Hole.Cleanup = function()
            timer.Remove("gmm_BlackHole_Physics")
        end
    end

    -- ----------------------------------------------------------------------
    -- Клиент: эффекты
    -- ----------------------------------------------------------------------

    if CLIENT then
        local FeelRadius     = 2800
        local ViewRadius     = 6000
        local ParticleRadius = 6000
        local ShardCount     = 10

        local HumPath = "ambient/atmosphere/undercity_loop1.wav"

        local ColorBlack      = Color(0, 0, 0, 255)
        local ColorRed        = Color(0, 128, 255, 255)
        local ColorCyan       = Color(218, 255, 0, 255)
        local ColorGhostRed   = Color(0, 128, 255, 150)
        local ColorGhostCyan  = Color(128, 255, 0, 150)

        local SmokeMaterial = Material("particle/particle_smokegrenade")
        local SparkMaterial = Material("effects/spark")

        local ZeroVector = Vector(0, 0, 0)
        local UpVector   = Vector(0, 0, 1)
        local TempPos    = Vector()
        local ShardPos   = Vector()
        local ShardMins  = Vector()
        local ShardMaxs  = Vector()
        local ShardAng   = Angle()

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

        local ViewData = {}

        local Emitter      = nil
        local HumSound     = nil
        local NextParticle = 0
        local NextBurst    = RealTime() + math.Rand(3, 8)
        local BurstUntil   = 0

        local Dist    = math.huge
        local Near    = 0
        local IsBurst = false

        local function ParticleThink(Part)
            local Pos  = Part:GetPos()
            local Dir  = Center - Pos
            local Away = Dir:Length()

            if Away < CoreRadius * 0.6 then
                Part:SetDieTime(0)
                return
            end

            Dir:Normalize()

            local Tangent = Dir:Cross(UpVector)
            local Speed   = 120 + 900 * math.Clamp(1 - Away / 500, 0, 1)
            local Target  = Dir * Speed + Tangent * 140
            local Vel     = Part:GetVelocity()

            Part:SetVelocity(Vel + (Target - Vel) * 0.25)
            Part:SetNextThink(CurTime() + 0.03)
        end

        local function SpawnParticle(Smoke)
            local Dir = VectorRand():GetNormalized()
            local Pos = Center + Dir * math.Rand(300, 1000)

            local Part = Emitter:Add(Smoke and SmokeMaterial or SparkMaterial, Pos)
            if Part == nil then return end

            Part:SetGravity(ZeroVector)
            Part:SetDieTime(math.Rand(3, 5))
            Part:SetThinkFunction(ParticleThink)
            Part:SetNextThink(CurTime())

            if Smoke then
                Part:SetColor(0, 0, 0)
                Part:SetStartAlpha(0)
                Part:SetEndAlpha(230)
                Part:SetStartSize(math.Rand(10, 25))
                Part:SetEndSize(2)
                Part:SetRoll(math.Rand(0, 360))
                Part:SetRollDelta(math.Rand(-2, 2))
                return
            end

            local Glitch = math.random() < 0.5 and ColorRed or ColorCyan

            Part:SetColor(Glitch.r, Glitch.g, Glitch.b)
            Part:SetStartAlpha(255)
            Part:SetEndAlpha(255)
            Part:SetStartSize(3)
            Part:SetEndSize(1)
            Part:SetStartLength(100)
            Part:SetEndLength(6)
        end

        local function SpawnParticles(Now)
            if Now < NextParticle then return end
            NextParticle = Now

            if Emitter == nil then Emitter = ParticleEmitter(Center, false) end

            SpawnParticle(true)
            SpawnParticle(math.random() < 0.6)

            if IsBurst then
                SpawnParticle(false)
                SpawnParticle(false)
                SpawnParticle(false)
            end
        end

        local function UpdateHum(Ply)
            if Near < 0.01 then
                if HumSound ~= nil then
                    HumSound:Stop()
                    HumSound = nil
                end
                return
            end

            if HumSound == nil then
                HumSound = CreateSound(Ply, HumPath)
                HumSound:PlayEx(0, 60)
            end

            local Pitch = 55 + 15 * Near
            if IsBurst then Pitch = math.random(30, 140) end

            HumSound:ChangeVolume(math.min(Near * 1.5, 1), 0.1)
            HumSound:ChangePitch(Pitch, 0.05)
        end

        net.Receive("gmm_BlackHole_Eat", function()
            BurstUntil = RealTime() + 0.35
        end)

        hook.Add("Think", "gmm_BlackHole_Think", function()
            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            local Now = RealTime()

            Dist = Ply:EyePos():Distance(Center)
            Near = 1 - math.Clamp((Dist - CoreRadius) / FeelRadius, 0, 1)

            if Now >= NextBurst then
                BurstUntil = Now + math.Rand(0.12, 0.4)
                NextBurst  = Now + math.Rand(2.5, 7)
            end

            IsBurst = Now < BurstUntil

            UpdateHum(Ply)

            if Dist < ParticleRadius then SpawnParticles(Now) end
        end)

        hook.Add("PostDrawTranslucentRenderables", "gmm_BlackHole_Draw", function(Depth, Skybox, Sky3D)
            if Skybox or Sky3D then return end
            if Dist > ViewRadius then return end

            local Now   = RealTime()
            local Tick  = math.floor(Now * 14)
            local Power = IsBurst and 1 or 0.3

            render.SetColorMaterial()

            local ShardChance = IsBurst and 0.9 or 0.55

            for i = 1, ShardCount do
                local Seed = Tick * 13.7 + i * 5.3

                if Hash(Seed) < ShardChance then
                    local DirX = Hash(Seed + 1) - 0.5
                    local DirY = Hash(Seed + 2) - 0.5
                    local DirZ = Hash(Seed + 3) - 0.5
                    local Len  = (10 + Hash(Seed + 4) * 60) * (1 + Power)

                    ShardPos:SetUnpacked(DirX, DirY, DirZ)
                    ShardPos:Normalize()
                    ShardPos:Mul(HoleRadius * (0.6 + Hash(Seed + 5) * 1.8))
                    ShardPos:Add(Center)

                    ShardAng.p = Hash(Seed + 6) * 360
                    ShardAng.y = Hash(Seed + 7) * 360
                    ShardAng.r = 0

                    ShardMins:SetUnpacked(-Len / 2, -1, -1)
                    ShardMaxs:SetUnpacked( Len / 2,  1,  1)

                    local Pick  = Hash(Seed + 8)
                    local Color = ColorBlack
                    if Pick > 0.7 then
                        Color = ColorCyan
                    elseif Pick > 0.4 then
                        Color = ColorRed
                    end

                    render.DrawBox(ShardPos, ShardAng, ShardMins, ShardMaxs, Color)
                end
            end
        end)

        hook.Add("CalcView", "gmm_BlackHole_View", function(Ply, Pos, Angles, Fov)
            if Near <= 0.05 then return end

            local Tick  = math.floor(RealTime() * 30)
            local Shake = Near * Near * (IsBurst and 3 or 0.6)

            ViewData.origin     = Pos
            ViewData.angles     = Angle(Angles.p + (Hash(Tick * 1.1) - 0.5) * 2 * Shake, Angles.y + (Hash(Tick * 2.3) - 0.5) * 2 * Shake, Angles.r + (Hash(Tick * 3.7) - 0.5) * 4 * Shake)
            ViewData.fov        = Fov
            ViewData.drawviewer = false

            return ViewData
        end)

        hook.Add("RenderScreenspaceEffects", "gmm_BlackHole_Screen", function()
            if Near <= 0.01 then return end

            local Power = Near * Near
            local Tick  = math.floor(RealTime() * 20)

            ColorMod["$pp_colour_colour"]     = 1 - 0.85 * Power
            ColorMod["$pp_colour_brightness"] = -0.25 * Power
            ColorMod["$pp_colour_contrast"]   = 1 + 0.5 * Power
            ColorMod["$pp_colour_addr"]       = IsBurst and 0.15 * Near or 0

            DrawColorModify(ColorMod)

            if Power > 0.2 then DrawMotionBlur(0.4, 0.5 * Power, 0.01) end
            if IsBurst then DrawSharpen(1 + 2 * Power, 1 + 3 * Power) end

            if IsBurst and Near > 0.3 and Hash(Tick) > 0.8 then
                surface.SetDrawColor(255, 255, 255, 40 * Near)
                surface.DrawRect(0, 0, ScrW(), ScrH())
            end
        end)

        hook.Add("HUDPaint", "gmm_BlackHole_Hud", function()
            if not IsBurst then return end
            if Near < 0.15 then return end

            local Width  = ScrW()
            local Height = ScrH()
            local Tick   = math.floor(RealTime() * 30)

            for i = 1, 6 do
                local BarY  = Hash(Tick * 3.1 + i * 7.7) * Height
                local BarH  = 2 + Hash(Tick * 1.7 + i * 3.3) * 28 * Near
                local Shift = (Hash(Tick * 5.1 + i) - 0.5) * 60 * Near

                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, BarY, Width, BarH)

                surface.SetDrawColor(255, 30, 60, 120)
                surface.DrawRect(Shift, BarY + BarH, Width, 2)

                surface.SetDrawColor(0, 230, 255, 120)
                surface.DrawRect(-Shift, BarY - 2, Width, 2)
            end

            if Near > 0.5 then
                draw.SimpleText("DOWNLOADING MAP...", "DermaLarge", Width / 2 + (Hash(Tick) - 0.5) * 40, Height / 2, Color(255, 30, 60, 180 * Near), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end)

        Hole.Cleanup = function()
            if Emitter ~= nil then Emitter:Finish() end
            if HumSound ~= nil then HumSound:Stop() end

            hook.Remove("Think", "gmm_BlackHole_Think")
            hook.Remove("PostDrawTranslucentRenderables", "gmm_BlackHole_Draw")
            hook.Remove("CalcView", "gmm_BlackHole_View")
            hook.Remove("RenderScreenspaceEffects", "gmm_BlackHole_Screen")
            hook.Remove("HUDPaint", "gmm_BlackHole_Hud")
        end
    end
end