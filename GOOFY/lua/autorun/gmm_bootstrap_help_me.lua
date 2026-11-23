AddCSLuaFile()

local CorrectMap = game.GetMap() == "gmm_garrymod_map_by_woowz_help_me"

if SERVER then
    local ExitPassFile = "gmm_exit_pass.txt"

    concommand.Add("gmm_maze_reset", function(Ply, Cmd, Args)
        if IsValid(Ply) and not Ply:IsSuperAdmin() then return end

        if not file.Exists(ExitPassFile, "DATA") then
            print("[GMM] MAZE EXIT PASS NOT FOUND!")
            return
        end

        file.Delete(ExitPassFile)

        print("[GMM] MAZE EXIT PASS RESET!")
    end)
end

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

    GMM_BlackHole = nil
end

if SERVER and CorrectMap then
    local HolePos = Vector(-1606, 2551, -419)

    local function SpawnBlackHole()
        if #ents.FindByClass("gmm_blackhole") > 0 then return end

        local Hole = ents.Create("gmm_blackhole")

        if not IsValid(Hole) then
            print("[GMM] BLACKHOLE CREATE FAILED! CLASS: gmm_blackhole, POS: " .. tostring(HolePos))
            return
        end

        Hole:SetPos(HolePos)
		Hole.PhysgunDisabled = true
        Hole:Spawn()

        local Phys = Hole:GetPhysicsObject()
        if IsValid(Phys) then Phys:EnableMotion(false) end
    end

    hook.Add("InitPostEntity", "gmm_BlackHole_Spawn", SpawnBlackHole)
    hook.Add("PostCleanupMap", "gmm_BlackHole_Spawn", SpawnBlackHole)

    timer.Simple(1, SpawnBlackHole)
end

if CorrectMap then
    local OldExit = GMM_MazeExit
    if OldExit ~= nil and OldExit.Cleanup ~= nil then pcall(OldExit.Cleanup) end

    local Exit = {}
    GMM_MazeExit = Exit

    -- ----------------------------------------------------------------------
    -- Общее
    -- ----------------------------------------------------------------------

    local ExitPos          = Vector(6810, -1993, 608)
    local TriggerRadius    = 200
    local FeelRadius       = 1800
    local TriggerRadiusSqr = TriggerRadius * TriggerRadius
    local NextMap          = "gmm_garrymod_0_f5099cd"
    local ChangeDelay      = 8
    local PassFile         = "gmm_exit_pass.txt"

    local function Hash(Value)
        local Result = math.sin(Value * 12.9898) * 43758.5453
        return Result - math.floor(Result)
    end

    -- ----------------------------------------------------------------------
    -- Сервер: вход в зону и смена карты
    -- ----------------------------------------------------------------------

    if SERVER then
        util.AddNetworkString("gmm_Exit_Crash")

        local CheckDelay = 0.1
        local Triggered  = false
        local NextTry    = 0
		
        local AntiFlyEnabled = true
        local AntiFlyDelay   = 0.1
        local AntiFlyMins    = Vector(3527, -2266, -3346)
        local AntiFlyMaxs    = Vector(9756, 2870, 4157)
        local AntiFlyPos     = Vector(-2821.2, 931.6, 608)
        local AntiFlyAngles  = Angle(3.3, -2.1, 0)
		
        local ModBlockEnabled = true
        local ModMissing      = {}

        util.AddNetworkString("gmm_Maze_ModState")

        net.Receive("gmm_Maze_ModState", function(Len, Ply)
            ModMissing[Ply] = net.ReadBool()
        end)

        hook.Add("PlayerDisconnected", "gmm_Maze_ModClean", function(Ply) ModMissing[Ply] = nil end)

        OrderVectors(AntiFlyMins, AntiFlyMaxs)

        local function FindVisitorOrNull()
            for _, Ply in ipairs(player.GetAll()) do
                if Ply:Alive() and Ply:GetMoveType() ~= MOVETYPE_NOCLIP and Ply:GetPos():DistToSqr(ExitPos) < TriggerRadiusSqr then return Ply end
            end

            return NULL
        end

        local function StartCrash(Visitor)
            if not file.Exists("maps/" .. NextMap .. ".bsp", "GAME") then
                print("[GMM] EXIT MAP NOT FOUND! MAP: " .. NextMap)
                NextTry = CurTime() + 5
                return
            end

            Triggered = true
            print("[GMM] " .. Visitor:Nick() .. " REACHED MAZE EXIT, CHANGELEVEL: " .. NextMap)

            local Passed = {}

            for _, Ply in ipairs(player.GetAll()) do
                if not Ply:IsBot() then
                    if Ply:IsListenServerHost() then
                        Passed[#Passed + 1] = "HOST"
                    else
                        Passed[#Passed + 1] = Ply:SteamID64() or Ply:SteamID()
                    end
                end
            end

            file.Write(PassFile, util.TableToJSON({Time = os.time(), Players = Passed}))

            for _, Ply in ipairs(player.GetAll()) do
                Ply:Freeze(true)
            end

            net.Start("gmm_Exit_Crash")
            net.WriteFloat(ChangeDelay)
            net.Broadcast()

            timer.Create("gmm_Exit_Change", ChangeDelay, 1, function()
                RunConsoleCommand("changelevel", NextMap)
            end)
        end
		
        local function ShouldTeleportOut(Ply)
            if not Ply:Alive() then return false end
            if Ply:IsBot() then return false end
            if not Ply:GetPos():WithinAABox(AntiFlyMins, AntiFlyMaxs) then return false end

            if ModBlockEnabled and ModMissing[Ply] == true then return true end
            if AntiFlyEnabled and Ply:GetMoveType() == MOVETYPE_NOCLIP then return true end

            return false
        end

        local function AntiFlyTick()
            for _, Ply in ipairs(player.GetAll()) do
                if ShouldTeleportOut(Ply) then
                    Ply:SetPos(AntiFlyPos)
                    Ply:SetEyeAngles(AntiFlyAngles)
                    Ply:SetLocalVelocity(vector_origin)
                end
            end
        end

        if AntiFlyEnabled or ModBlockEnabled then
            timer.Create("gmm_Exit_AntiFly", AntiFlyDelay, 0, function() AntiFlyTick() end)
        end

        timer.Create("gmm_Exit_Check", CheckDelay, 0, function()
            if Triggered then return end
            if CurTime() < NextTry then return end

            local Visitor = FindVisitorOrNull()
            if not IsValid(Visitor) then return end

            StartCrash(Visitor)
        end)

        Exit.Cleanup = function()
            timer.Remove("gmm_Exit_Check")
            timer.Remove("gmm_Exit_Change")
            timer.Remove("gmm_Exit_AntiFly")
	        hook.Remove("PlayerDisconnected", "gmm_Maze_ModClean")
        end
    end

    -- ----------------------------------------------------------------------
    -- Клиент: глюки при приближении и фейковый краш
    -- ----------------------------------------------------------------------

    if CLIENT then
        surface.CreateFont("gmm_Exit_Text", {font = "Consolas", size = 36, weight = 800, antialias = true, extended = true})

        local HangSeconds = 0.4
        local FadeSeconds = 2.5
        local CrashText   = "CONNECTION... SEND DATA... PLEASE WAIT..."
		
        local SpritePath = "icons16/gmm_category"
        local SpriteSize = 50
        local SpriteLift = 40
        local SpriteView = 5000

        local SpriteMaterial = Material(SpritePath)
        local SpritePos      = Vector()
        local SpriteColor    = Color(255, 255, 255, 255)

        local BuzzSounds = {
			"ambient/energy/zap9.wav",
			"buttons/button10.wav",
			"items/flashlight1.wav",
			"beams/beamstart5.wav",
			"common/warning.wav",
			"common/bugreporter_failed.wav",
			"friends/friend_online.wav",
			"woowz/music/ManiyaVelichiaGOLUFUNNY.wav",
			"woowz/music/greetings.wav",
			"woowz/music/concrete_halls.wav",
			"npc/zombie/zombie_pain1.wav",
			"npc/zombie/zombie_pain2.wav",
			"npc/zombie/zombie_pain3.wav",
			"npc/zombie/zombie_pain4.wav",
			"npc/zombie/zombie_pain5.wav",
			"npc/zombie/zombie_pain6.wav",
			"phx/hmetal3.wav",
			"player/sprayer.wav",
			"player/damage1.wav",
			"player/damage2.wav",
			"player/damage3.wav",
			"resource/warning.wav",
			"vo/npc/male01/no01.wav",
			"vo/npc/male01/no02.wav"
		}

        local ColorTemp = Color(255, 255, 255, 255)

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

        local Dist    = math.huge
        local Near    = 0
        local Flicker = false

        local Crashing       = false
        local Captured       = false
        local CrashStart     = 0
        local CrashDelay     = 0
        local NextBuzz       = 0
        local FrozenTexture  = nil
        local FrozenMaterial = nil

        local function SendModState()
            net.Start("gmm_Maze_ModState")
            net.WriteBool(GMM == nil)
            net.SendToServer()
        end

        hook.Add("InitPostEntity", "gmm_Maze_ModState", function() SendModState() end)

        if IsValid(LocalPlayer()) then timer.Simple(1, function() SendModState() end) end

        local function CreateFrozen()
            local Width  = ScrW()
            local Height = ScrH()
            local Name   = "gmm_Exit_Frozen_" .. Width .. "_" .. Height

            FrozenTexture  = GetRenderTarget(Name, Width, Height)
            FrozenMaterial = CreateMaterial(Name .. "_Mat", "UnlitGeneric", {
                ["$basetexture"] = FrozenTexture:GetName(),
                ["$ignorez"]     = 1,
                ["$nolod"]       = 1,
            })

            FrozenMaterial:SetTexture("$basetexture", FrozenTexture)
        end

        local function PlayBuzz(Ply, Elapsed)
            local Now = RealTime()
            if Now < NextBuzz then return end

            if Elapsed < 1.2 then
                Ply:EmitSound(BuzzSounds[1], 75, 35, 1)
                NextBuzz = Now + 0.09
                return
            end

            Ply:EmitSound(BuzzSounds[math.random(#BuzzSounds)], 300, math.random(20, 200), math.Rand(0.4, 1))
            NextBuzz = Now + math.Rand(0.03, 0.1)
        end

        net.Receive("gmm_Exit_Crash", function()
            CrashDelay = net.ReadFloat()

            local Done, Error = pcall(CreateFrozen)
            if not Done then print("[GMM] EXIT FREEZE FAILED! " .. tostring(Error)) end

            RunConsoleCommand("stopsound")

            local HangUntil = SysTime() + HangSeconds
            while SysTime() < HangUntil do end

            Crashing   = true
            Captured   = false
            CrashStart = RealTime()
            NextBuzz   = CrashStart + 0.15
        end)

        hook.Add("PostRender", "gmm_Exit_Capture", function()
            if not Crashing or Captured then return end

            if FrozenTexture ~= nil then render.CopyRenderTargetToTexture(FrozenTexture) end
            Captured = true
        end)

        hook.Add("DrawOverlay", "gmm_Exit_Overlay", function()
            if not Crashing or not Captured then return end

            local Width   = ScrW()
            local Height  = ScrH()
            local Elapsed = RealTime() - CrashStart

            if FrozenMaterial ~= nil then
                surface.SetMaterial(FrozenMaterial)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(0, 0, Width, Height)
            else
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, Width, Height)
            end

            local Dark = math.Clamp((Elapsed - (CrashDelay - FadeSeconds)) / FadeSeconds, 0, 1)
            if Dark > 0 then
                surface.SetDrawColor(0, 0, 0, 255 * Dark)
                surface.DrawRect(0, 0, Width, Height)
            end

            if Elapsed < 0.3 then return end

            surface.SetFont("gmm_Exit_Text")
            local TextW = surface.GetTextSize(CrashText)

            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(Width / 2 - TextW / 2 - 16, Height / 2 - 28, TextW + 32, 56)

            draw.SimpleText(CrashText, "gmm_Exit_Text", Width / 2, Height / 2, ColorTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)

        hook.Add("Think", "gmm_Exit_Think", function()
            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            if Crashing then
                PlayBuzz(Ply, RealTime() - CrashStart)
                return
            end

            Dist = Ply:EyePos():Distance(ExitPos)
            Near = 1 - math.Clamp((Dist - TriggerRadius) / FeelRadius, 0, 1)

            if Near < 0.02 then
                Flicker = false
                return
            end

            local Tick = math.floor(RealTime() * 20)
            Flicker = Hash(Tick * 1.7) < Near * 0.7

            local Light = DynamicLight(4754)
            if Light == nil then return end

            local Red = Hash(Tick * 2.9) > 0.5

            Light.pos        = ExitPos
            Light.r          = Red and 255 or 0
            Light.g          = Red and 30 or 230
            Light.b          = Red and 60 or 255
            Light.brightness = Flicker and 5 or 0.4
            Light.size       = 300 + 900 * Near
            Light.decay      = 2000
            Light.dietime    = CurTime() + 0.1
        end)

        hook.Add("CalcView", "gmm_Exit_View", function(Ply, Pos, Angles, Fov)
            if Crashing then return end
            if Near <= 0.05 then return end

            local Tick  = math.floor(RealTime() * 30)
            local Shake = Near * Near * 2.5
            local Spike = Hash(Tick * 0.37) > 0.96 and 3 or 1

            ViewData.origin     = Pos
            ViewData.angles     = Angle(Angles.p + (Hash(Tick * 1.1) - 0.5) * 2 * Shake * Spike, Angles.y + (Hash(Tick * 2.3) - 0.5) * 2 * Shake * Spike, Angles.r + (Hash(Tick * 3.7) - 0.5) * 4 * Shake * Spike)
            ViewData.fov        = Fov + (Hash(Tick * 4.9) - 0.5) * 6 * Shake
            ViewData.drawviewer = false

            return ViewData
        end)

        hook.Add("RenderScreenspaceEffects", "gmm_Exit_Screen", function()
            if Crashing then return end
            if Near <= 0.03 then return end

            local Power = Near * Near
            local Tick  = math.floor(RealTime() * 20)

            ColorMod["$pp_colour_colour"]     = 1 - 0.7 * Power
            ColorMod["$pp_colour_brightness"] = Flicker and 0.2 * Power or -0.12 * Power
            ColorMod["$pp_colour_contrast"]   = 1 + 0.6 * Power
            ColorMod["$pp_colour_addr"]       = Flicker and 0.25 * Power or 0
            ColorMod["$pp_colour_addb"]       = Flicker and 0 or 0.1 * Power
            DrawColorModify(ColorMod)

            if Power > 0.15 then DrawMotionBlur(0.4, 0.5 * Power, 0.01) end
            if Flicker and Near > 0.5 then DrawSharpen(1 + 2 * Power, 1 + 3 * Power) end

            if Near > 0.4 and Hash(Tick * 1.3) > 0.93 then
                surface.SetDrawColor(255, 255, 255, 60 * Near)
                surface.DrawRect(0, 0, ScrW(), ScrH())
            end
        end)

        hook.Add("HUDPaint", "gmm_Exit_Hud", function()
            if Crashing then return end
            if Near < 0.1 then return end

            local Width  = ScrW()
            local Height = ScrH()
            local Tick   = math.floor(RealTime() * 24)
            local Count  = math.floor(1 + 7 * Near)

            for i = 1, Count do
                if Hash(Tick * 2.3 + i * 5.9) < Near then
                    local BarY  = Hash(Tick * 3.1 + i * 7.7) * Height
                    local BarH  = 2 + Hash(Tick * 1.7 + i * 3.3) * 26 * Near
                    local Shift = (Hash(Tick * 5.1 + i) - 0.5) * 60 * Near

                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(0, BarY, Width, BarH)

                    surface.SetDrawColor(255, 30, 60, 120)
                    surface.DrawRect(Shift, BarY + BarH, Width, 2)

                    surface.SetDrawColor(0, 230, 255, 120)
                    surface.DrawRect(-Shift, BarY - 2, Width, 2)
                end
            end

            if Near > 0.5 and Hash(Tick * 0.9) > 0.85 then
                ColorTemp.r = 255
                ColorTemp.g = 30
                ColorTemp.b = 60
                ColorTemp.a = 140 * Near

                draw.SimpleText(CrashText, "gmm_Exit_Text", Hash(Tick * 1.9) * Width, Hash(Tick * 2.7) * Height, ColorTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                ColorTemp.r = 255
                ColorTemp.g = 255
                ColorTemp.b = 255
                ColorTemp.a = 255
            end
        end)

        hook.Add("PostDrawTranslucentRenderables", "gmm_Exit_Sprite", function(Depth, Skybox, Sky3D)
            if Skybox or Sky3D then return end
            if Crashing then return end

            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            local DistToSprite = Ply:EyePos():Distance(ExitPos)
            if DistToSprite > SpriteView then return end

            local Tick   = math.floor(RealTime() * 20)
            local Closer = 1 - math.Clamp(DistToSprite / SpriteView, 0, 1)
            local Pulse  = 1 + 0.15 * math.sin(RealTime() * 3)
            local Size   = SpriteSize * Pulse * (1 + Closer)

            local JumpX = 0
            local JumpY = 0
            local JumpZ = 0

            if Hash(Tick * 1.7) < Near * 0.5 then
                JumpX = (Hash(Tick * 2.1) - 0.5) * 40
                JumpY = (Hash(Tick * 3.3) - 0.5) * 40
                JumpZ = (Hash(Tick * 4.7) - 0.5) * 40
                Size  = Size * (0.5 + Hash(Tick * 5.9) * 1.5)
            end

            SpritePos:SetUnpacked(ExitPos.x + JumpX, ExitPos.y + JumpY, ExitPos.z + SpriteLift + JumpZ)

            if Flicker and Hash(Tick * 2.9) > 0.5 then
                SpriteColor.r = 255
                SpriteColor.g = 30
                SpriteColor.b = 60
            else
                SpriteColor.r = 255
                SpriteColor.g = 255
                SpriteColor.b = 255
            end

            SpriteColor.a = 120 + 135 * Closer

            render.SetMaterial(SpriteMaterial)
            render.DrawSprite(SpritePos, Size, Size, SpriteColor)
        end)

        Exit.Cleanup = function()
            hook.Remove("PostRender", "gmm_Exit_Capture")
            hook.Remove("DrawOverlay", "gmm_Exit_Overlay")
            hook.Remove("Think", "gmm_Exit_Think")
            hook.Remove("CalcView", "gmm_Exit_View")
            hook.Remove("RenderScreenspaceEffects", "gmm_Exit_Screen")
            hook.Remove("HUDPaint", "gmm_Exit_Hud")
            hook.Remove("PostDrawTranslucentRenderables", "gmm_Exit_Sprite")
        end
    end
end

do
    local GateMap         = "gmm_garrymod_0_f5099cd"
    local PassFile        = "gmm_exit_pass.txt"
    local PassSeconds     = 600
    local AllowDeveloper  = false
    local DisconnectDelay = 5

    local HintText = "!! ACCESS DENIED !!\n\nTo unlock access, complete the fi1al MAZE..."
	
	local DownloadText  = "!! MOD NOT FOUND !!\n\nDownload GMM"
    local KickOnReady   = false
    local ReadyWait     = 15

    if game.GetMap() ~= GateMap then return end

    -- ----------------------------------------------------------------------
    -- Сервер
    -- ----------------------------------------------------------------------

    if SERVER then
        util.AddNetworkString("gmm_ExitGate_Ready")
        util.AddNetworkString("gmm_ExitGate_Denied")

        local function GetPassId(Ply)
            if Ply:IsListenServerHost() then return "HOST" end

            return Ply:SteamID64() or Ply:SteamID()
        end

        local function HasPass(Ply)
            local Raw = file.Read(PassFile, "DATA")
            if Raw == nil then return false end

            local Data = util.JSONToTable(Raw)
            if type(Data) ~= "table" then return false end

            if os.time() - (Data.Time or 0) > PassSeconds then return false end

            local Players = Data.Players or {}
            local Id      = GetPassId(Ply)

            for i = 1, #Players do
                if Players[i] == Id then return true end
            end

            return false
        end

        local function IsDenied(Ply)
            if Ply:IsBot() then return false end
            if AllowDeveloper and GetConVar("developer"):GetInt() > 0 then return false end
            if HasPass(Ply) then return false end

            return true
        end

        hook.Add("PlayerInitialSpawn", "gmm_ExitGate", function(Ply)
            if not IsDenied(Ply) then return end
            if game.SinglePlayer() or Ply:IsListenServerHost() then return end

            if KickOnReady then
                timer.Simple(ReadyWait, function()
                    if not IsValid(Ply) or Ply.GateAnswered then return end

                    print("[GMM] EXIT GATE READY TIMEOUT! PLAYER: " .. Ply:Nick() .. ", WAIT: " .. ReadyWait)

                    Ply:Kick(HintText)
                end)

                return
            end

            print("[GMM] EXIT GATE CLOSED! PLAYER: " .. Ply:Nick() .. ", MAP: " .. GateMap)

            Ply:Kick(HintText)
        end)

        net.Receive("gmm_ExitGate_Ready", function(Length, Ply)
            if not IsValid(Ply) then return end
            if Ply.GateAnswered then return end

            Ply.GateAnswered = true

            local Missing = net.ReadBool()
            local Text    = nil

            if Missing then
                Text = DownloadText
            elseif IsDenied(Ply) then
                Text = HintText
            else
                return
            end

            print("[GMM] EXIT GATE DENIED! PLAYER: " .. Ply:Nick() .. ", MOD MISSING: " .. tostring(Missing))

            Ply:Freeze(true)

            net.Start("gmm_ExitGate_Denied")
            net.WriteString(Text)
            net.WriteFloat(DisconnectDelay)
            net.Send(Ply)

            if Ply:IsListenServerHost() then return end

            timer.Simple(DisconnectDelay + 1, function()
                if IsValid(Ply) then Ply:Kick(Text) end
            end)
        end)
    end

    -- ----------------------------------------------------------------------
    -- Клиент
    -- ----------------------------------------------------------------------

    if CLIENT then
        surface.CreateFont("gmm_ExitGate_Title", {font = "Consolas", size = 72, weight = 900, antialias = true, extended = true})
        surface.CreateFont("gmm_ExitGate_Text",  {font = "Consolas", size = 30, weight = 800, antialias = true, extended = true})
        surface.CreateFont("gmm_ExitGate_Small", {font = "Consolas", size = 18, weight = 800, antialias = true, extended = true})
        surface.CreateFont("gmm_ExitGate_Icon",  {font = "Consolas", size = 64, weight = 900, antialias = true, extended = true})

        local GradientSteps = 64
        local ScanStep      = 5
        local TypeSpeed     = 45
        local LineGap       = 40
        local BarHeight     = 44
        local VignetteStep  = 24
        local VignetteCount = 8

        local Title       = nil
        local Body        = {}
        local ShownAt     = 0
        local DeniedDelay = 0

        local Triangle      = {{x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}}
        local TriangleInner = {{x = 0, y = 0}, {x = 0, y = 0}, {x = 0, y = 0}}

        local function Hash(Value)
            local Result = math.sin(Value * 12.9898) * 43758.5453

            return Result - math.floor(Result)
        end

        local function DrawText(Text, Font, X, Y, R, G, B, A)
            surface.SetFont(Font)

            local Width, Height = surface.GetTextSize(Text)

            surface.SetTextColor(R, G, B, A)
            surface.SetTextPos(X - Width / 2, Y - Height / 2)
            surface.DrawText(Text)
        end

        local function SetTriangle(Poly, Cx, Cy, Size)
            Poly[1].x = Cx
            Poly[1].y = Cy - Size

            Poly[2].x = Cx + Size * 0.95
            Poly[2].y = Cy + Size * 0.7

            Poly[3].x = Cx - Size * 0.95
            Poly[3].y = Cy + Size * 0.7
        end

        local function DrawGradient(Width, Height, Pulse, Appear)
            for i = 0, GradientSteps - 1 do
                local K = 1 - i / GradientSteps
                K = K * K

                local Y1 = math.floor(Height * i / GradientSteps)
                local Y2 = math.floor(Height * (i + 1) / GradientSteps)

                surface.SetDrawColor(190 * K * Pulse, 6 * K, 14 * K, 255 * Appear)
                surface.DrawRect(0, Y1, Width, Y2 - Y1 + 1)
            end
        end

        local function DrawVignette(Width, Height)
            for i = 0, VignetteCount - 1 do
                local Inset = i * VignetteStep

                surface.SetDrawColor(0, 0, 0, 170 - i * 20)
                surface.DrawOutlinedRect(Inset, Inset, Width - Inset * 2, Height - Inset * 2, VignetteStep)
            end
        end

        local function DrawScan(Width, Height, Now)
            surface.SetDrawColor(0, 0, 0, 55)

            for Y = 0, Height, ScanStep do
                surface.DrawRect(0, Y, Width, 1)
            end

            local BarY = (Now * 170) % (Height + 240) - 120

            surface.SetDrawColor(255, 30, 30, 22)
            surface.DrawRect(0, BarY, Width, 90)

            surface.SetDrawColor(255, 60, 60, 40)
            surface.DrawRect(0, BarY + 88, Width, 2)
        end

        local function DrawNoise(Width, Height, Tick)
            for i = 1, 40 do
                local X = Hash(Tick * 3 + i) * Width
                local Y = Hash(Tick * 5 + i * 7) * Height

                surface.SetDrawColor(255, 40, 40, 70 * Hash(Tick + i * 11))
                surface.DrawRect(X, Y, 2 + Hash(i + Tick) * 20, 2)
            end
        end

        local function DrawGlitchBlocks(Width, Height, Tick)
            if Hash(Tick + 7) < 0.7 then return end

            for i = 1, 4 do
                local Y      = Hash(Tick * 13 + i) * Height
                local Block  = 6 + Hash(Tick * 17 + i) * 40
                local Offset = (Hash(Tick * 19 + i) - 0.5) * 200

                if Hash(Tick + i * 3) > 0.5 then
                    surface.SetDrawColor(255, 0, 20, 110)
                else
                    surface.SetDrawColor(0, 0, 0, 200)
                end

                surface.DrawRect(Offset, Y, Width, Block)
            end
        end

        local function DrawCorners(Left, Top, Right, Bottom, Appear)
            local Len   = 46
            local Thick = 3

            surface.SetDrawColor(255, 30, 40, 255 * Appear)

            surface.DrawRect(Left, Top, Len, Thick)
            surface.DrawRect(Left, Top, Thick, Len)

            surface.DrawRect(Right - Len, Top, Len, Thick)
            surface.DrawRect(Right - Thick, Top, Thick, Len)

            surface.DrawRect(Left, Bottom - Thick, Len, Thick)
            surface.DrawRect(Left, Bottom - Len, Thick, Len)

            surface.DrawRect(Right - Len, Bottom - Thick, Len, Thick)
            surface.DrawRect(Right - Thick, Bottom - Len, Thick, Len)
        end

        local function DrawIcon(Cx, Cy, Now, Tick, Glitch, Appear)
            local Size = 74 + math.sin(Now * 5) * 5
            local Lost = Hash(Tick + 21) > 0.93

            if Lost then return end

            local OffsetX = Glitch and (Hash(Tick + 5) - 0.5) * 24 or 0

            draw.NoTexture()

            SetTriangle(Triangle, Cx + OffsetX, Cy, Size)
            surface.SetDrawColor(235, 20, 30, 255 * Appear)
            surface.DrawPoly(Triangle)

            SetTriangle(TriangleInner, Cx + OffsetX, Cy + 6, Size * 0.72)
            surface.SetDrawColor(10, 0, 2, 255 * Appear)
            surface.DrawPoly(TriangleInner)

            DrawText("!", "gmm_ExitGate_Icon", Cx + OffsetX, Cy + Size * 0.22, 235, 20, 30, 255 * Appear)
        end

        local function DrawTitle(Cx, Cy, Tick, Glitch, Appear)
            local Jitter = Glitch and (Hash(Tick + 3) - 0.5) * 30 or 0
            local Split  = Glitch and 6 + Hash(Tick + 9) * 14 or 2

            DrawText(Title, "gmm_ExitGate_Title", Cx + Jitter - Split, Cy, 0, 255, 255, 150 * Appear)
            DrawText(Title, "gmm_ExitGate_Title", Cx + Jitter + Split, Cy, 255, 0, 0, 200 * Appear)
            DrawText(Title, "gmm_ExitGate_Title", Cx + Jitter,         Cy, 242, 228, 218, 255 * Appear)
        end

        local function DrawBody(Cx, StartY, Now, Tick, Appear)
            local Left  = math.floor((Now - ShownAt) * TypeSpeed)
            local Blink = Hash(Tick + 31) > 0.9 and 90 or 255

            for i = 1, #Body do
                if Left <= 0 then return end

                local Line  = Body[i]
                local Count = utf8.len(Line) or #Line
                local Part  = Line

                if Left < Count then
                    local Cut = utf8.offset(Line, Left + 1)

                    Part = Cut and string.sub(Line, 1, Cut - 1) or Line
                end

                Left = Left - Count

                DrawText(Part, "gmm_ExitGate_Text", Cx, StartY + (i - 1) * LineGap, 235, 40, 48, Blink * Appear)
            end
        end

        local function DrawBars(Width, Height, Now, Tick, Appear)
            local Left   = math.max(0, ShownAt + DeniedDelay - Now)
            local Top    = Hash(Tick + 41) > 0.88 and "SYSTEM FAILURE // GMM" or "SYSTEM FAILURE"
            local Bottom = "ERROR 0x474F4C55  |  CONNECTION REFUSED  |  DISCONNECT IN " .. string.format("%.1f", Left)

            surface.SetDrawColor(200, 0, 16, 255 * Appear)
            surface.DrawRect(0, 0, Width, BarHeight)

            DrawText(Top, "gmm_ExitGate_Small", Width / 2, BarHeight / 2, 0, 0, 0, 255 * Appear)

            surface.SetDrawColor(0, 0, 0, 255 * Appear)
            surface.DrawRect(0, Height - BarHeight, Width, BarHeight)

            surface.SetDrawColor(200, 0, 16, 255 * Appear)
            surface.DrawRect(0, Height - BarHeight, Width, 2)

            DrawText(Bottom, "gmm_ExitGate_Small", Width / 2, Height - BarHeight / 2 + 1, 235, 40, 48, 255 * Appear)
        end

        local function IsModMissing()
            if GMM ~= nil then return false end

            print("[GMM] EXIT GATE MOD MISSING! GLOBAL GMM IS NIL")

            return true
        end

        hook.Add("InitPostEntity", "gmm_ExitGate_Ready", function()
            net.Start("gmm_ExitGate_Ready")
            net.WriteBool(IsModMissing())
            net.SendToServer()
        end)

        net.Receive("gmm_ExitGate_Denied", function()
            local Text  = net.ReadString()
            local Delay = net.ReadFloat()
            local Short = string.gsub(Text, "\n", " ")
            local Lines = string.Explode("\n", Text)

            Title = Lines[1] or ""
            Body  = {}

            for i = 2, #Lines do
                if Lines[i] ~= "" then table.insert(Body, Lines[i]) end
            end

            ShownAt     = RealTime()
            DeniedDelay = Delay

            timer.Simple(Delay, function()
                RunConsoleCommand("disconnect", Short)
            end)
        end)

        hook.Add("DrawOverlay", "gmm_ExitGate_Overlay", function()
            if Title == nil then return end

            local Width  = ScrW()
            local Height = ScrH()
            local Now    = RealTime()
            local Tick   = math.floor(Now * 12)
            local Glitch = Hash(Tick) > 0.85
            local Appear = math.Clamp((Now - ShownAt) / 0.25, 0, 1)
            local Pulse  = 0.8 + math.sin(Now * 2.2) * 0.2

            if Hash(Tick + 2) > 0.93 then Pulse = Pulse * 0.5 end

            local Cx = Width / 2
            local Cy = Height / 2

            local BoxW = math.min(Width * 0.8, 1000)
            local BoxH = 520

            DrawGradient(Width, Height, Pulse, Appear)
            DrawVignette(Width, Height)
            DrawNoise(Width, Height, Tick)

            DrawCorners(Cx - BoxW / 2, Cy - BoxH / 2, Cx + BoxW / 2, Cy + BoxH / 2, Appear)

            DrawIcon(Cx, Cy - 190, Now, Tick, Glitch, Appear)
            DrawTitle(Cx, Cy - 60, Tick, Glitch, Appear)

            surface.SetDrawColor(235, 20, 30, 255 * Appear)
            surface.DrawRect(Cx - BoxW * 0.3, Cy - 10, BoxW * 0.6, 3)

            DrawBody(Cx, Cy + 40, Now, Tick, Appear)

            DrawGlitchBlocks(Width, Height, Tick)
            DrawScan(Width, Height, Now)
            DrawBars(Width, Height, Now, Tick, Appear)
        end)
    end
end