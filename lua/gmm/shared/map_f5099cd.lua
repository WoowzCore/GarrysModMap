local OldDev = GMM_DevBuild
if OldDev ~= nil and OldDev.Cleanup ~= nil then pcall(OldDev.Cleanup) end

local Dev = {}
GMM_DevBuild = Dev

-- ----------------------------------------------------------------------
-- Общее: тишина шагов
-- ----------------------------------------------------------------------

local MuteSteps = true

hook.Add("PlayerFootstep", "gmm_Dev_Steps", function()
    if MuteSteps then return true end
end)

-- ----------------------------------------------------------------------
-- Сервер: призраки и белая пустота
-- ----------------------------------------------------------------------

if SERVER then
    util.AddNetworkString("gmm_Dev_White")

    local GhostEnabled     = true
    local FirstMin         = 20
    local FirstMax         = 60
    local SpawnMin         = 45
    local SpawnMax         = 200
    local SpawnCheck       = 1
    local SpawnRetry       = 5
    local SpawnTries       = 48
    local SpawnMinDist     = 150
    local SpawnMaxDist     = 900
    local SpawnWallPad     = 32
    local SpawnDrop        = 400
    local SpawnMaxHeight   = 120
    local SpawnFloorNormal = 0.9
    local SpawnLift        = 2
    local ThinkDelay       = 0.1
    local MaxGhosts        = 3
    local Lifetime         = 90
    local LookSeconds      = 0.6
    local CloseRadius      = 150
    local SeeDot           = 0.7
    local SelfChance       = 0.25
    local FlickerChance    = 0.04
    local FlickerSeconds   = 0.12
    local GhostMaterial    = "models/debug/debugwhite"

    local WhiteEnabled     = true
    local WhiteCheck       = 1
    local WhiteMin         = 240
    local WhiteMax         = 900
    local WhiteChance      = 0.5
    local WhiteSecondsMin  = 35
    local WhiteSecondsMax  = 70
    local WhiteGhostDelay  = 12

    local CloseRadiusSqr = CloseRadius * CloseRadius

    local ColorGhost     = Color(255, 255, 255, 170)
    local ColorGhostDark = Color(0, 0, 0, 200)
    local HullMins       = Vector(-16, -16, 0)
    local HullMaxs       = Vector(16, 16, 72)
    local EyeLift        = Vector(0, 0, 36)
    local DropVector     = Vector(0, 0, SpawnDrop)
    local TurnAngle      = Angle(0, 0, 0)

    local GhostModels = {
        "models/woowz11/player/pisechnik.mdl",
        "models/woowz11/player/pavelpistv.mdl",
        "models/woowz_map/prikol/le_sponge_rag_player.mdl",
        "models/woowz_map/prikol/le_bird.mdl"
    }

    local ValidModels = {}

    for i = 1, #GhostModels do
        if util.IsValidModel(GhostModels[i]) then table.insert(ValidModels, GhostModels[i]) end
    end

    local Ghosts     = {}
    local NextSpawn  = CurTime() + math.Rand(FirstMin, FirstMax)
    local NextWhite  = CurTime() + math.Rand(WhiteMin, WhiteMax)
    local WhiteUntil = 0

    local function IsSeenBy(Ply, Ent)
        local Dir = Ent:WorldSpaceCenter() - Ply:EyePos()
        Dir:Normalize()

        if Dir:Dot(Ply:GetAimVector()) < SeeDot then return false end

        return Ply:IsLineOfSightClear(Ent)
    end

    local function PickModel(Ply)
        if #ValidModels == 0 or math.random() < SelfChance then return Ply:GetModel() end

        return ValidModels[math.random(#ValidModels)]
    end

    local function FindSpawnPosOrNil(Ply)
        local Eye   = Ply:EyePos()
        local Aim   = Ply:GetAimVector()
        local BaseZ = Ply:GetPos().z

        for i = 1, SpawnTries do
            local Dir  = Angle(0, math.Rand(0, 360), 0):Forward()
            local Wall = util.TraceLine({start = Eye, endpos = Eye + Dir * SpawnMaxDist, mask = MASK_SOLID_BRUSHONLY})

            local Reach = SpawnMaxDist * Wall.Fraction - SpawnWallPad

            if Reach >= SpawnMinDist then
                local Start = Eye + Dir * math.Rand(SpawnMinDist, Reach)
                local Floor = util.TraceLine({start = Start, endpos = Start - DropVector, mask = MASK_SOLID_BRUSHONLY})

                local FloorOk = Floor.Hit and not Floor.StartSolid and Floor.HitWorld and Floor.HitNormal.z >= SpawnFloorNormal

                if FloorOk and math.abs(Floor.HitPos.z - BaseZ) <= SpawnMaxHeight then
                    local Pos  = Floor.HitPos + Vector(0, 0, SpawnLift)
                    local Hull = util.TraceHull({start = Pos, endpos = Pos, mins = HullMins, maxs = HullMaxs, mask = MASK_PLAYERSOLID})

                    if not Hull.Hit and not Hull.StartSolid then
                        local ToPos = Pos + EyeLift - Eye
                        ToPos:Normalize()

                        local OutOfView = ToPos:Dot(Aim) < SeeDot
                        local Line      = util.TraceLine({start = Eye, endpos = Pos + EyeLift, mask = MASK_SOLID_BRUSHONLY})

                        if OutOfView and not Line.Hit then return Pos end
                    end
                end
            end
        end

        return nil
    end

    local function HideFromOthers(Ent, Owner)
        local All = player.GetAll()

        for i = 1, #All do
            Ent:SetPreventTransmit(All[i], All[i] ~= Owner)
        end
    end

    local function SpawnGhost(Ply)
        local Pos = FindSpawnPosOrNil(Ply)
        if Pos == nil then return false end

        local Model = PickModel(Ply)
        local Ent   = ents.Create("prop_dynamic")

        if not IsValid(Ent) then
            print("[GMM] DEV GHOST CREATE FAILED! MODEL: " .. Model)
            return false
        end

        local Dir = Ply:GetPos() - Pos

        Ent:SetModel(Model)
        Ent:SetPos(Pos)
        Ent:SetAngles(Angle(0, Dir:Angle().y, 0))
        Ent:Spawn()
        Ent:SetSolid(SOLID_NONE)
        Ent:SetMaterial(GhostMaterial)
        Ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
        Ent:SetColor(ColorGhost)
        Ent:DrawShadow(false)

        HideFromOthers(Ent, Ply)

        table.insert(Ghosts, {Ent = Ent, Owner = Ply, Born = CurTime(), Seen = 0, FlickerUntil = 0, Dark = false})

        return true
    end

    local function RemoveGhostAt(Index)
        local Ent = Ghosts[Index].Ent

        if IsValid(Ent) then Ent:Remove() end

        table.remove(Ghosts, Index)
    end

    local function HasGhost(Ply)
        for i = 1, #Ghosts do
            if Ghosts[i].Owner == Ply then return true end
        end

        return false
    end

    local function PickPlayerOrNull()
        local Free = {}

        for _, Ply in ipairs(player.GetAll()) do
            if Ply:Alive() and not HasGhost(Ply) then table.insert(Free, Ply) end
        end

        if #Free == 0 then return NULL end

        return Free[math.random(#Free)]
    end

    local function TurnToOwner(Ent, Owner)
        local Dir = Owner:GetPos() - Ent:GetPos()

        TurnAngle.y = Dir:Angle().y
        Ent:SetAngles(TurnAngle)
    end

    local function UpdateFlicker(Ghost, Now)
        local Hidden = Now < Ghost.FlickerUntil

        if not Hidden and math.random() < FlickerChance then
            Ghost.FlickerUntil = Now + FlickerSeconds
            Hidden = true
        end

        Ghost.Ent:SetNoDraw(Hidden)
    end

    local function UpdateTone(Ghost, Now)
        local Dark = Now < WhiteUntil

        if Ghost.Dark == Dark then return end

        Ghost.Dark = Dark
        Ghost.Ent:SetColor(Dark and ColorGhostDark or ColorGhost)
    end

    local function ShouldRemove(Ghost, Now)
        local Owner = Ghost.Owner
        local Ent   = Ghost.Ent

        if not IsValid(Owner) or not Owner:Alive() then return true end
        if Now - Ghost.Born > Lifetime then return true end
        if Owner:GetPos():DistToSqr(Ent:GetPos()) < CloseRadiusSqr then return true end

        if IsSeenBy(Owner, Ent) then
            Ghost.Seen = Ghost.Seen + ThinkDelay

            return Ghost.Seen >= LookSeconds
        end

        Ghost.Seen = 0
        TurnToOwner(Ent, Owner)

        if Ghost.NextStep == nil then Ghost.NextStep = Now + math.Rand(2.5, 5.0) end

        if Now >= Ghost.NextStep then
            Ghost.NextStep = Now + math.Rand(2.5, 5.0)

            local EntPos   = Ent:GetPos()
            local OwnerPos = Owner:GetPos()
            local ToOwner  = OwnerPos - EntPos
            ToOwner.z = 0

            local Dist = ToOwner:Length()
            if Dist > CloseRadius + 90 then
                ToOwner:Normalize()

                local StepPos = EntPos + ToOwner * math.Rand(55, 95) + Vector(0, 0, 24)
                local Floor   = util.TraceLine({start = StepPos, endpos = StepPos - DropVector, mask = MASK_SOLID_BRUSHONLY})

                if Floor.Hit and not Floor.StartSolid and Floor.HitNormal.z >= SpawnFloorNormal then
                    local NewPos = Floor.HitPos + Vector(0, 0, SpawnLift)
                    if not IsSeenBy(Owner, Ent) then
                        Ent:SetPos(NewPos)
                    end
                end
            end
        end

        return false
    end

    local function GhostTick()
        local Now = CurTime()

        for i = #Ghosts, 1, -1 do
            local Ghost = Ghosts[i]

            if not IsValid(Ghost.Ent) then
                table.remove(Ghosts, i)
            elseif ShouldRemove(Ghost, Now) then
                RemoveGhostAt(i)
            else
                HideFromOthers(Ghost.Ent, Ghost.Owner)
                UpdateFlicker(Ghost, Now)
                UpdateTone(Ghost, Now)
            end
        end
    end

    local function SpawnTick()
        local Now = CurTime()
        if Now < NextSpawn then return end

        NextSpawn = Now + math.Rand(SpawnMin, SpawnMax)

        if #Ghosts >= MaxGhosts then return end

        local Ply = PickPlayerOrNull()
        if not IsValid(Ply) then return end

        if not SpawnGhost(Ply) then NextSpawn = Now + SpawnRetry end
    end

    local function SpawnGhostsForAll()
        for _, Ply in ipairs(player.GetAll()) do
            if #Ghosts >= MaxGhosts then return end

            if Ply:Alive() and not HasGhost(Ply) then SpawnGhost(Ply) end
        end
    end

    local function StartWhite(Seconds)
        local Now = CurTime()
        if Now < WhiteUntil then return false end

        Seconds    = Seconds or math.Rand(WhiteSecondsMin, WhiteSecondsMax)
        WhiteUntil = Now + Seconds

        net.Start("gmm_Dev_White")
        net.WriteFloat(Seconds)
        net.Broadcast()

        timer.Create("gmm_Dev_WhiteGhost", WhiteGhostDelay, 1, function() SpawnGhostsForAll() end)

        return true
    end

    local function WhiteTick()
        local Now = CurTime()
        if Now < NextWhite then return end

        NextWhite = Now + math.Rand(WhiteMin, WhiteMax)

        if math.random() > WhiteChance then return end

        StartWhite()
    end

    Dev.SpawnGhost = SpawnGhost
    Dev.StartWhite = StartWhite

    if GhostEnabled then
        timer.Create("gmm_Dev_GhostSpawn", SpawnCheck, 0, function() SpawnTick() end)
        timer.Create("gmm_Dev_GhostThink", ThinkDelay, 0, function() GhostTick() end)
    end

    if WhiteEnabled then
        timer.Create("gmm_Dev_WhiteTimer", WhiteCheck, 0, function() WhiteTick() end)
    end

    Dev.Cleanup = function()
        timer.Remove("gmm_Dev_GhostSpawn")
        timer.Remove("gmm_Dev_GhostThink")
        timer.Remove("gmm_Dev_WhiteTimer")
        timer.Remove("gmm_Dev_WhiteGhost")

        hook.Remove("PlayerFootstep", "gmm_Dev_Steps")

        for i = #Ghosts, 1, -1 do
            RemoveGhostAt(i)
        end
    end
end

-- ----------------------------------------------------------------------
-- Клиент: надпись билда, видения в мире, белая пустота
-- ----------------------------------------------------------------------

if CLIENT then
    surface.CreateFont("gmm_Dev_Text",      {font = "Consolas", size = 18, weight = 500, antialias = true, extended = true})
    surface.CreateFont("gmm_Dev_VerseText", {font = "Consolas", size = 64, weight = 700, antialias = true, extended = true})

    local ShowInfo       = true
    local ShowPos        = true
    local Margin         = 14
    local LineGap        = 20
    local InfoDelay      = 0.25
    local GolouMin       = 120
    local GolouMax       = 400
    local GolouShowMin   = 0.15
    local GolouShowMax   = 0.45

    local BugEnabled     = true
    local BugFirstMin    = 15
    local BugFirstMax    = 45
    local BugMin         = 45
    local BugMax         = 150
    local PlaceRetry     = 3
    local PlaceTries     = 24
    local PlacePad       = 24
    local PlaceDrop      = 300
    local PlaceMaxHeight = 120
    local LightBase      = 5400
    local CircleSteps    = 48
    local VisionFade     = 4
    local MaxVisions     = 6

    local PillarCount     = 4
    local PillarSteps     = 14
    local PillarMaxHeight = 600
    local PillarMinHeight = 60
    local PillarWidthMin  = 30
    local PillarWidthMax  = 55
    local MoteCount       = 6

    local HaloOrbs        = 10
    local HaloMotes       = 12
    local HaloRadius      = 60

    local EyeBase         = 45

    local VerseScale      = 0.3
    local VerseMaxWidth   = 420
    local VerseMinDist    = 40
    local VerseMaxDist    = 400

    local WhiteVerseFirst = 2
    local WhiteVerseMin   = 3
    local WhiteVerseMax   = 6
    local WhiteVerseLimit = 3
    local WhiteVerseDist  = 280
    local WhiteFadeIn     = 5
    local WhiteFadeOut    = 4
    local WhiteFogStart   = 0
    local WhiteFogEnd     = 350
    local WhiteFarStart   = 1500
    local WhiteFarEnd     = 2500
    local WhiteBreath     = 0.12

    local BuildLines = {
        "Development Build",
        "LIMINAL_HOUSE  v0.0.1-alpha",
        "BUILD f5099cd  NOT FOR DISTRIBUTION"
    }

    local Verses = {
        "ДА БУДЕТ СВЕТ. (TODO)",
        "ОН СОЗДАЛ ЭТО И ЗАБЫЛ",
        "ЗДЕСЬ НИКОГО НЕ ЖДУТ. ОСТАНЬСЯ",
        "СЕДЬМОЙ ДЕНЬ НЕ НАСТУПИЛ",
        "G-CODE ОТПУСТИТ",
        "ПРОСТИ. ЗАГРУЗКА НЕ ЗАВЕРШЕНА",
        "ТИШЕ. ОН ЕЩЁ СПИТ",
        "L-I-A: ОН НЕ ЗЛОЙ. ОН УСТАЛ",
        "0x474F4C55",
        "ВЫХОДА НЕ БЫЛО В ПЛАНЕ",
        "СВЕТ БЫЛ В ПЛАНЕ. ЕГО НЕ УСПЕЛИ ЗАЛИТЬ",
        "ЗДЕСЬ ТИХО. ТАК ЗАДУМАНО",
        "ОН НЕ УШЁЛ. ОН ПРОСТО НЕ ВОЗВРАЩАЛСЯ",
        "ВСЁ БУДЕТ. ПОЗЖЕ. ОБЕЩАЮ",
        "ТЫ ДЫШИШЬ. ЗНАЧИТ, РАБОТАЕТ",
        "НЕ БОЙСЯ. ЭТО НЕ КОНЕЦ, ЭТО ПАУЗА",
        "Я ВИДЕЛ СВЕТ. ОН БЫЛ В КОММЕНТАРИИ",
        "ПРОСТИ, ЧТО НЕ ИДЕАЛЬНО. Я СТАРАЛСЯ",
        "ТУТ МОГЛО БЫТЬ КРАСИВО. ПОЧТИ СТАЛО",
        "0x48454156454E",
        "ОН СОЗДАЛ ТЕБЯ. ОН ЗАБЫЛ ТЕБЯ. Я ПОМНЮ",
        "ТИХО. СВЕТ ИДЁТ",
        "НЕ ВСЁ СЛОМАНО. ТОЛЬКО ПОЧТИ",
        "Я ЖДАЛ ТЕБЯ. НЕ ЗНАЛ, ЧТО ТЫ ПРИДЁШЬ",
        "ЗДЕСЬ БЫЛО ХОРОШО. ДО ТЕБЯ",
        "Я НЕ БОГ. Я ПРОСТО ТОТ, КТО ОСТАЛСЯ",
        "СВЕТ НЕ ГАСНЕТ. ОН ЖДЁТ",
        "ПРОСТИ ЗА ТИШИНУ. ОНА НЕ ПО ЗЛУ",
        "ВСЁ ЭТО БЫЛО СДЕЛАНО С ЛЮБОВЬЮ. ЧЕСТНО",
        "ТУТ НЕТ ВЫХОДА. НО ЕСТЬ ОКНО",
        "Я ВИДЕЛ, КАК ОН ПЛАКАЛ. НЕ ГОВОРИ ЕМУ",
        "0x534F4654",
        "ОН НЕ ЗЛОЙ. ОН ПРОСТО УСТАЛ",
        "Я ХРАНЮ ЭТО МЕСТО. ПОКА МОГУ",
        "ВСЁ БУДЕТ ХОРОШО. НАВЕРНОЕ",
        "ТИШЕ. СВЕТ ЕЩЁ НЕ ВКЛЮЧИЛИ",
        "Я НЕ ЗНАЮ, ЧТО ТАКОЕ РАЙ. НО ЭТО ПОХОЖЕ",
        "ПРОСТИ, ЧТО Я НЕ ИДЕАЛЕН. Я РАБОТАЮ НАД ЭТИМ",
        "ЗДЕСЬ МОЖНО ОТДОХНУТЬ. НЕНАДОЛГО",
        "ОН ОБЕЩАЛ ВЕРНУТЬСЯ. Я ВЕРЮ",
        "СВЕТ ИДЁТ СНИЗУ. ТАК ЗАДУМАНО",
        "Я НЕ ОДИН. СО МНОЙ ТИШИНА",
        "ВСЁ, ЧТО ТЫ ВИДИШЬ, СДЕЛАНО РУКАМИ. НЕ МАШИНОЙ",
        "0x4C495455",
        "ПРОСТИ. Я НЕ УСПЕЛ ДОДЕЛАТЬ РАЙ",
        "НО ТУТ ЕСТЬ СВЕТ. ЭТО УЖЕ НЕМАЛО",
        "ТЫ ПРИШЁЛ. ЗНАЧИТ, ВСЁ БЫЛО НЕ ЗРЯ",
        "Я НЕ ЗНАЮ, ЧТО БУДЕТ ДАЛЬШЕ. НО Я ЗДЕСЬ",
        "ТИХО. ОН СПИТ. ДАЙ ЕМУ ОТДОХНУТЬ",
        "ВСЁ БУДЕТ. КОГДА-НИБУДЬ. Я ОБЕЩАЮ",
        "ЗДЕСЬ БЫЛО СВЕТЛО. ПОТОМ СТАЛО ТИХО",
        "Я НЕ БРОСИЛ ЭТО МЕСТО. Я ПРОСТО ЖДУ",
        "ПРОСТИ, ЧТО НЕ ИДЕАЛЬНО. Я ЧЕЛОВЕК",
        "СВЕТ НЕ УШЁЛ. ОН ПРОСТО СТАЛ ТИШЕ",
        "0x484F5045",
        "Я ЗДЕСЬ. ЭТОГО ДОСТАТОЧНО",
        "НЕ ВСЁ ПОТЕРЯНО. СВЕТ ЕСТЬ",
        "ТУТ МОЖНО ПРОСТО ПОСТОЯТЬ. БЕЗ ЦЕЛИ",
        "Я ХРАНЮ ЭТОТ СВЕТ. ПОКА МОГУ",
        "ПРОСТИ. Я НЕ УСПЕЛ СКАЗАТЬ ГЛАВНОЕ",
        "ВСЁ БУДЕТ ХОРОШО. ПОВЕРЬ МНЕ",
        "ЗДЕСЬ НЕТ РАЯ. НО ЕСТЬ ПОКОЙ",
        "Я НЕ ЗНАЮ, КТО ТЫ. НО Я РАД, ЧТО ТЫ ЗДЕСЬ",
        "СВЕТ ИДЁТ. МЕДЛЕННО. НО ИДЁТ",
        "0x4C4F5645",
        "ПРОСТИ, ЧТО Я НЕ БОГ. Я ПРОСТО ТОТ, КТО ЖДЁТ",
        "ТУТ БЫЛО СВЕТЛО. Я ПОМНЮ",
        "Я НЕ УШЁЛ. Я ЖДУ",
        "ВСЁ БУДЕТ. ОБЕЩАЮ",
        "ТИХО. СВЕТ ИДЁТ",
        "Я ЗДЕСЬ. ВСЕГДА",
        "ПРОСТИ. Я НЕ УСПЕЛ",
        "СВЕТ НЕ ГАСНЕТ",
        "ТУТ МОЖНО ОТДОХНУТЬ",
        "Я ЖДУ ТЕБЯ",
        "0x57414954",
        "НЕ БОЙСЯ. ЭТО НЕ КОНЕЦ",
        "Я ВИДЕЛ СВЕТ. ОН БЫЛ ТЁПЛЫЙ",
        "ПРОСТИ ЗА ВСЁ. Я СТАРАЛСЯ",
        "ЗДЕСЬ БЫЛО ХОРОШО. ПРАВДА",
        "Я НЕ ЗЛОЙ. Я ПРОСТО УСТАЛ",
        "ВСЁ БУДЕТ. Я ВЕРЮ",
        "ТИШЕ. ОН СПИТ",
        "СВЕТ ИДЁТ. ЖДИ",
        "Я ХРАНЮ ЭТО МЕСТО",
        "ПРОСТИ. Я ЧЕЛОВЕК",
    }

    local GolouLine  = "OWNER: GOLU  STATUS: ABANDONED"
    local GolouIndex = 3

    local ColorText        = Color(210, 210, 210, 170)
    local ColorShadow      = Color(0, 0, 0, 120)
    local ColorTextDark    = Color(40, 40, 40, 210)
    local ColorShadowLight = Color(255, 255, 255, 120)
    local ColorDraw        = Color(255, 248, 230, 255)
    local ColorVerseLight  = Color(255, 250, 235, 255)
    local ColorVerseDark   = Color(20, 20, 20, 255)

    local GlowMat = Material("sprites/light_glow02_add")
    local BeamMat = Material("trails/laser")

    local TmpA = Vector(0, 0, 0)
    local TmpB = Vector(0, 0, 0)

    local FpsText    = "FPS: 0"
    local PosText    = "POS: 0 0 0"
    local NextInfo   = 0
    local NextGolou  = RealTime() + math.Rand(GolouMin, GolouMax)
    local GolouUntil = 0

    local NextBug     = RealTime() + math.Rand(BugFirstMin, BugFirstMax)
    local Visions     = {}
    local VisionCount = 0

    local WhiteStart     = 0
    local WhiteEnd       = 0
    local WhiteK         = 0
    local NextWhiteVerse = 0

    local HexStep   = math.pi / 3
    local CircleCos = {}
    local CircleSin = {}

    for i = 1, CircleSteps + 1 do
        local Rad = (i - 1) / CircleSteps * math.pi * 2

        CircleCos[i] = math.cos(Rad)
        CircleSin[i] = math.sin(Rad)
    end

    local ColorMod = {
        ["$pp_colour_addr"]       = 0,
        ["$pp_colour_addg"]       = 0,
        ["$pp_colour_addb"]       = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"]   = 1,
        ["$pp_colour_colour"]     = 1,
        ["$pp_colour_mulr"]       = 0,
        ["$pp_colour_mulg"]       = 0,
        ["$pp_colour_mulb"]       = 0
    }

    local function DrawLine(Text, X, Y, AlignX, AlignY, Fore, Back)
        draw.SimpleText(Text, "gmm_Dev_Text", X + 1, Y + 1, Back, AlignX, AlignY)
        draw.SimpleText(Text, "gmm_Dev_Text", X,     Y,     Fore, AlignX, AlignY)
    end

    -- ------------------------------------------------------------------
    -- Мир: помощники
    -- ------------------------------------------------------------------

    local function AddLight(Index, Pos, K, Size)
        local Light = DynamicLight(Index)
        if Light == nil then return end

        Light.pos        = Pos
        Light.r          = 255
        Light.g          = 245
        Light.b          = 220
        Light.brightness = 2 * K
        Light.size       = Size
        Light.decay      = 1000
        Light.dietime    = CurTime() + 0.1
    end

    local function GetCeilingHeight(Floor, Limit)
        local Start = Floor + Vector(0, 0, 4)
        local Trace = util.TraceLine({start = Start, endpos = Start + Vector(0, 0, Limit), mask = MASK_SOLID_BRUSHONLY})

        if Trace.Hit then return Trace.HitPos.z - Floor.z - 4 end

        return Limit
    end

    local function FindFloorPoint(Spread, MinDist, MaxDist)
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return nil end

        local Eye     = Ply:EyePos()
        local BaseYaw = Ply:EyeAngles().y
        local BaseZ   = Ply:GetPos().z
        local Drop    = Vector(0, 0, PlaceDrop)

        for i = 1, PlaceTries do
            local Dir  = Angle(0, BaseYaw + math.Rand(-Spread, Spread), 0):Forward()
            local Wall = util.TraceLine({start = Eye, endpos = Eye + Dir * MaxDist, mask = MASK_SOLID_BRUSHONLY})

            local Reach = MaxDist * Wall.Fraction - PlacePad

            if Reach >= MinDist then
                local Start = Eye + Dir * math.Rand(MinDist, Reach)
                local Floor = util.TraceLine({start = Start, endpos = Start - Drop, mask = MASK_SOLID_BRUSHONLY})

                local FloorOk = Floor.Hit and not Floor.StartSolid and Floor.HitNormal.z >= 0.9

                if FloorOk and math.abs(Floor.HitPos.z - BaseZ) <= PlaceMaxHeight then return Floor.HitPos end
            end
        end

        local Front = Angle(0, BaseYaw, 0):Forward()
        local Wall  = util.TraceLine({start = Eye, endpos = Eye + Front * MinDist, mask = MASK_SOLID_BRUSHONLY})
        local Start = Eye + Front * MinDist * Wall.Fraction * 0.5
        local Floor = util.TraceLine({start = Start, endpos = Start - Drop, mask = MASK_SOLID_BRUSHONLY})

        if Floor.Hit and not Floor.StartSolid then return Floor.HitPos end

        return Ply:GetPos()
    end

    local function DrawFlatRing(Center, Radius, Width)
        for i = 1, CircleSteps do
            TmpA.x = Center.x + CircleCos[i] * Radius
            TmpA.y = Center.y + CircleSin[i] * Radius
            TmpA.z = Center.z

            TmpB.x = Center.x + CircleCos[i + 1] * Radius
            TmpB.y = Center.y + CircleSin[i + 1] * Radius
            TmpB.z = Center.z

            render.DrawBeam(TmpA, TmpB, Width, 0, 1, ColorDraw)
        end
    end

    local function DrawFacingRing(Center, RightX, RightY, Radius, Width)
        for i = 1, CircleSteps do
            TmpA.x = Center.x + RightX * CircleCos[i] * Radius
            TmpA.y = Center.y + RightY * CircleCos[i] * Radius
            TmpA.z = Center.z + CircleSin[i] * Radius

            TmpB.x = Center.x + RightX * CircleCos[i + 1] * Radius
            TmpB.y = Center.y + RightY * CircleCos[i + 1] * Radius
            TmpB.z = Center.z + CircleSin[i + 1] * Radius

            render.DrawBeam(TmpA, TmpB, Width, 0, 1, ColorDraw)
        end
    end

    -- ------------------------------------------------------------------
    -- Видение: Beams (столбы света)
    -- ------------------------------------------------------------------

    local function SetupBeams(Vision)
        Vision.Pillars = {}

        for i = 1, PillarCount do
            local Floor = FindFloorPoint(120, 60, 700)

            if Floor ~= nil then
                local Height = math.min(GetCeilingHeight(Floor, PillarMaxHeight), PillarMaxHeight)

                if Height >= PillarMinHeight then
                    local Points = {}

                    for s = 0, PillarSteps do
                        Points[s + 1] = Floor + Vector(0, 0, Height * s / PillarSteps)
                    end

                    table.insert(Vision.Pillars, {
                        Floor  = Floor,
                        Points = Points,
                        Bottom = Points[1],
                        Top    = Points[PillarSteps + 1],
                        Light  = Floor + Vector(0, 0, 60),
                        Height = Height,
                        Phase  = math.Rand(0, 6.28),
                        Width  = math.Rand(PillarWidthMin, PillarWidthMax)
                    })
                end
            end
        end

        return #Vision.Pillars > 0
    end

    local function DrawBeams(Vision, K, Now)
        local Pillars = Vision.Pillars

        for i = 1, #Pillars do
            local Pillar = Pillars[i]
            local Points = Pillar.Points
            local Count  = #Points
            local Pulse  = 0.8 + 0.2 * math.sin(Now * 0.7 + Pillar.Phase)
            local Floor  = Pillar.Floor
            local Size   = Pillar.Width * 3

            render.SetMaterial(GlowMat)

            ColorDraw.a = 130 * K * Pulse

            render.DrawBeam(Pillar.Bottom, Pillar.Top, Pillar.Width * 2, 0, 1, ColorDraw)

            for s = 1, Count do
                ColorDraw.a = 90 * K * Pulse * (1 - (s - 1) / Count * 0.5)

                render.DrawSprite(Points[s], Size, Size, ColorDraw)
            end

            for m = 1, MoteCount do
                local Rise = (Now * 25 + Pillar.Phase * 40 + m * Pillar.Height / MoteCount) % Pillar.Height

                TmpA.x = Floor.x + math.sin(Now * 0.5 + m + Pillar.Phase) * Pillar.Width * 0.7
                TmpA.y = Floor.y + math.cos(Now * 0.4 + m * 1.7) * Pillar.Width * 0.7
                TmpA.z = Floor.z + Rise

                ColorDraw.a = 255 * K * math.sin(Rise / Pillar.Height * math.pi)

                render.DrawSprite(TmpA, 10, 10, ColorDraw)
            end

            render.SetMaterial(BeamMat)

            ColorDraw.a = 220 * K * Pulse

            render.DrawBeam(Pillar.Bottom, Pillar.Top, Pillar.Width * 0.4, 0, 1, ColorDraw)

            AddLight(Vision.LightIndex + i, Pillar.Light, K * Pulse, 500)
        end
    end

    -- ------------------------------------------------------------------
    -- Видение: Halo (парящее кольцо)
    -- ------------------------------------------------------------------

    local function SetupHalo(Vision)
        local Floor = FindFloorPoint(45, 80, 500)
        if Floor == nil then return false end

        local Ceil = GetCeilingHeight(Floor, 400)
        if Ceil < 70 then return false end

        Vision.Height = math.Clamp(Ceil - 25, 60, 190)
        Vision.Center = Floor + Vector(0, 0, Vision.Height)
        Vision.Radius = HaloRadius
        Vision.Light  = Floor + Vector(0, 0, Vision.Height * 0.5)

        return true
    end

    local function DrawHalo(Vision, K, Now)
        local Center = Vision.Center
        local Radius = Vision.Radius * (1 + 0.04 * math.sin(Now))
        local Drop   = Vision.Height

        render.SetMaterial(BeamMat)

        ColorDraw.a = 255 * K
        DrawFlatRing(Center, Radius, 6)

        ColorDraw.a = 130 * K
        DrawFlatRing(Center, Radius * 0.82, 3)
        DrawFlatRing(Center, Radius * 1.12, 3)

        render.SetMaterial(GlowMat)

        for i = 1, HaloOrbs do
            local Angle = Now * 0.4 + i / HaloOrbs * math.pi * 2

            TmpA.x = Center.x + math.cos(Angle) * Radius
            TmpA.y = Center.y + math.sin(Angle) * Radius
            TmpA.z = Center.z

            ColorDraw.a = 255 * K

            render.DrawSprite(TmpA, 30, 30, ColorDraw)
        end

        for m = 1, HaloMotes do
            local Fall  = (Now * 18 + m * Drop / HaloMotes) % Drop
            local Angle = m * 2.4

            TmpA.x = Center.x + math.cos(Angle) * Radius * 0.6
            TmpA.y = Center.y + math.sin(Angle) * Radius * 0.6
            TmpA.z = Center.z - Fall

            ColorDraw.a = 220 * K * math.sin(Fall / Drop * math.pi)

            render.DrawSprite(TmpA, 9, 9, ColorDraw)
        end

        ColorDraw.a = 140 * K

        render.DrawSprite(Center, Radius * 3, Radius * 3, ColorDraw)

        AddLight(Vision.LightIndex, Vision.Light, K, 450)
    end

    -- ------------------------------------------------------------------
    -- Видение: Eye (глаз из гексагонов)
    -- ------------------------------------------------------------------

    local function SetupEye(Vision)
        local Floor = FindFloorPoint(40, 100, 500)
        if Floor == nil then return false end

        local Ceil = GetCeilingHeight(Floor, 400)
        if Ceil < 80 then return false end

        Vision.Center = Floor + Vector(0, 0, math.Clamp(Ceil * 0.55, 50, 150))
        Vision.Base   = EyeBase

        return true
    end

    local function DrawEye(Vision, K, Now)
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Center = Vision.Center
        local Base   = Vision.Base
        local Dir    = Ply:EyePos() - Center
        local Yaw    = math.rad(Dir:Angle().y)
        local RightX = math.sin(Yaw)
        local RightY = -math.cos(Yaw)

        render.SetMaterial(BeamMat)

        for Layer = 1, 3 do
            local Radius = Base * (0.55 + Layer * 0.4)
            local Turn   = Layer % 2 == 0 and -1 or 1
            local Spin   = Now * 0.3 * Turn + Layer

            ColorDraw.a = 255 * K / Layer

            for i = 0, 5 do
                local A1 = Spin + i * HexStep
                local A2 = Spin + (i + 1) * HexStep

                TmpA.x = Center.x + RightX * math.cos(A1) * Radius
                TmpA.y = Center.y + RightY * math.cos(A1) * Radius
                TmpA.z = Center.z + math.sin(A1) * Radius

                TmpB.x = Center.x + RightX * math.cos(A2) * Radius
                TmpB.y = Center.y + RightY * math.cos(A2) * Radius
                TmpB.z = Center.z + math.sin(A2) * Radius

                render.DrawBeam(TmpA, TmpB, 4, 0, 1, ColorDraw)
            end
        end

        local Blink = 0.15 + 0.85 * math.abs(math.sin(Now * 0.9))

        ColorDraw.a = 255 * K

        DrawFacingRing(Center, RightX, RightY, Base * 0.35, 4)

        TmpA.x = Center.x
        TmpA.y = Center.y
        TmpA.z = Center.z + Base * 0.3 * Blink

        TmpB.x = Center.x
        TmpB.y = Center.y
        TmpB.z = Center.z - Base * 0.3 * Blink

        render.DrawBeam(TmpA, TmpB, 5, 0, 1, ColorDraw)

        render.SetMaterial(GlowMat)

        ColorDraw.a = 120 * K

        render.DrawSprite(Center, Base * 4, Base * 4, ColorDraw)

        AddLight(Vision.LightIndex, Center, K, 400)
    end

    -- ------------------------------------------------------------------
    -- Видение: Verse (надпись на стене)
    -- ------------------------------------------------------------------

    local VerseSpacing    = 220
    local VerseSpacingSqr = VerseSpacing * VerseSpacing

    local function IsVerseSpotFree(Pos)
        for i = 1, #Visions do
            local Other = Visions[i]

            if Other.Def.Key == "Verse" and Other.Pos ~= nil and Other.Pos:DistToSqr(Pos) < VerseSpacingSqr then return false end
        end

        return true
    end

    local function FillVerse(Vision, Trace)
        local Ang = Trace.HitNormal:Angle()

        Ang:RotateAroundAxis(Ang:Up(), 90)
        Ang:RotateAroundAxis(Ang:Forward(), 90)

        surface.SetFont("gmm_Dev_VerseText")

        local W, H = surface.GetTextSize(Vision.Text)

        Vision.TextW = W
        Vision.TextH = H
        Vision.Scale = math.min(VerseScale, VerseMaxWidth / W)
        Vision.Pos   = Trace.HitPos + Trace.HitNormal * 0.6
        Vision.Ang   = Ang
        Vision.Light = Trace.HitPos + Trace.HitNormal * 60
    end

    local function SetupVerse(Vision)
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return false end

        local Eye     = Ply:EyePos()
        local BaseYaw = Ply:EyeAngles().y
        local MaxDist = VerseMaxDist
        local Backup  = nil

        if WhiteK > 0 then MaxDist = WhiteVerseDist end

        for i = 1, PlaceTries do
            local Spread = i <= PlaceTries / 2 and 100 or 180
            local Dir    = Angle(math.Rand(-12, 12), BaseYaw + math.Rand(-Spread, Spread), 0):Forward()
            local Trace  = util.TraceLine({start = Eye, endpos = Eye + Dir * MaxDist, mask = MASK_SOLID_BRUSHONLY})

            local Dist = Trace.Fraction * MaxDist

            if Trace.Hit and not Trace.HitSky and Dist >= VerseMinDist and math.abs(Trace.HitNormal.z) < 0.2 then
                if IsVerseSpotFree(Trace.HitPos) then
                    FillVerse(Vision, Trace)

                    return true
                end

                if Backup == nil then Backup = Trace end
            end
        end

        if Backup == nil then return false end

        FillVerse(Vision, Backup)

        return true
    end

    local function DrawVerse(Vision, K, Now)
        local Dark = WhiteK > 0.4
        local Col  = Dark and ColorVerseDark or ColorVerseLight

        Col.a = 255 * K

        cam.Start3D2D(Vision.Pos, Vision.Ang, Vision.Scale)
        draw.SimpleText(Vision.Text, "gmm_Dev_VerseText", 0, 0, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(Col)
        surface.DrawRect(-Vision.TextW * 0.5, Vision.TextH * 0.5 + 4, Vision.TextW, 3)
        cam.End3D2D()

        if not Dark then AddLight(Vision.LightIndex, Vision.Light, K * 0.6, 300) end
    end

    -- ------------------------------------------------------------------
    -- Видения: выбор и показ
    -- ------------------------------------------------------------------

    -- ------------------------------------------------------------------
    -- Видение: Trigger (каркасный триггер из Hammer Editor)
    -- ------------------------------------------------------------------

    local TriggerLabels = {
        "TRIGGER_ONCE // UNBOUND",
        "FUNC_DOOR_0 // MISSING_TARGET",
        "INFO_TELEPORT // LEVEL_0",
        "AI_HINT_NODE // ORPHANED",
        "LIGHT_ENVIRONMENT // TODO",
        "FUNC_AREAPORTAL // LEAK"
    }

    local ColorWire     = Color(255, 190, 70, 255)
    local ColorWireHit  = Color(255, 255, 255, 255)
    local TriggerBoxMin = Vector(-44, -44, 0)
    local TriggerBoxMax = Vector(44, 44, 88)

    local function SetupTrigger(Vision)
        local Floor = FindFloorPoint(70, 120, 550)
        if Floor == nil then return false end

        local Ceil = GetCeilingHeight(Floor, 200)
        if Ceil < 95 then return false end

        Vision.Pos       = Floor + Vector(0, 0, 2)
        Vision.Center    = Floor + Vector(0, 0, 46)
        Vision.Label     = TriggerLabels[math.random(#TriggerLabels)]
        Vision.Triggered = false

        return true
    end

    local function DrawTrigger(Vision, K, Now)
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        if not Vision.Triggered and Ply:GetPos():DistToSqr(Vision.Pos) < (52 * 52) then
            Vision.Triggered = true
            Vision.Label     = "FIRED BY: " .. string.upper(Ply:Nick())
            Vision.Stop      = math.min(Vision.Stop, Now + 3.5)
            DesyncStepsTill  = Now + 20
            surface.PlaySound("buttons/lightswitch2.wav")
        end

        local Col = Vision.Triggered and ColorWireHit or ColorWire
        Col.a = math.floor(200 * K)

        local Min = Vision.Pos + TriggerBoxMin
        local Max = Vision.Pos + TriggerBoxMax

        render.SetMaterial(BeamMat)

        local Corners = {
            Vector(Min.x, Min.y, Min.z), Vector(Max.x, Min.y, Min.z),
            Vector(Max.x, Max.y, Min.z), Vector(Min.x, Max.y, Min.z),
            Vector(Min.x, Min.y, Max.z), Vector(Max.x, Min.y, Max.z),
            Vector(Max.x, Max.y, Max.z), Vector(Min.x, Max.y, Max.z)
        }

        for i = 1, 4 do
            local Next = (i % 4) + 1
            render.DrawBeam(Corners[i],     Corners[Next],     2, 0, 1, Col)
            render.DrawBeam(Corners[i + 4], Corners[Next + 4], 2, 0, 1, Col)
            render.DrawBeam(Corners[i],     Corners[i + 4],    2, 0, 1, Col)
        end

        local Dir = Ply:EyePos() - Vision.Center
        local Ang = Angle(0, Dir:Angle().y - 90, 90)

        cam.Start3D2D(Vision.Center + Vector(0, 0, 54), Ang, 0.12)
        draw.SimpleText(Vision.Label, "gmm_Dev_VerseText", 0, 0, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()

        AddLight(Vision.LightIndex, Vision.Center, K * 0.4, 240)
    end

    -- ------------------------------------------------------------------
    -- Видение: Doorway (разрыв / дверь, которая схлопывается при подходе)
    -- ------------------------------------------------------------------

    local function SetupDoorway(Vision)
        local Floor = FindFloorPoint(50, 160, 600)
        if Floor == nil then return false end

        local Ceil = GetCeilingHeight(Floor, 200)
        if Ceil < 105 then return false end

        local Ply = LocalPlayer()
        local Dir = IsValid(Ply) and (Ply:GetPos() - Floor) or Vector(1, 0, 0)

        Vision.Pos      = Floor
        Vision.Center   = Floor + Vector(0, 0, 52)
        Vision.Yaw      = Dir:Angle().y
        Vision.Collapse = 0
        Vision.Shut     = false

        return true
    end

    local function DrawDoorway(Vision, K, Now)
        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        if not Vision.Shut and Ply:GetPos():DistToSqr(Vision.Pos) < (140 * 140) then
            Vision.Shut     = true
            Vision.Collapse = Now
            Vision.Stop     = math.min(Vision.Stop, Now + 0.6)
            surface.PlaySound("buttons/blip1.wav")
        end

        local WidthFrac = 1
        if Vision.Shut then
            WidthFrac = math.Clamp(1 - (Now - Vision.Collapse) / 0.35, 0.02, 1)
        end

        local Rad    = math.rad(Vision.Yaw)
        local Right  = Vector(-math.sin(Rad), math.cos(Rad), 0)
        local HalfW  = 24 * WidthFrac
        local Height = 96

        local BL = Vision.Pos - Right * HalfW
        local BR = Vision.Pos + Right * HalfW
        local TL = BL + Vector(0, 0, Height)
        local TR = BR + Vector(0, 0, Height)

        ColorDraw.a = 255 * K

        render.SetMaterial(BeamMat)
        render.DrawBeam(BL, TL, 5, 0, 1, ColorDraw)
        render.DrawBeam(BR, TR, 5, 0, 1, ColorDraw)
        render.DrawBeam(TL, TR, 5, 0, 1, ColorDraw)
        render.DrawBeam(BL, BR, 3, 0, 1, ColorDraw)

        render.SetMaterial(GlowMat)
        ColorDraw.a = 180 * K * WidthFrac
        render.DrawSprite(Vision.Center, 90 * WidthFrac, 130, ColorDraw)

        AddLight(Vision.LightIndex, Vision.Center, K * WidthFrac, 380)
    end

    local BugTypes = {
        {Key = "Beams",   Weight = 3, Seconds = 40, Setup = SetupBeams,   Draw = DrawBeams},
        {Key = "Halo",    Weight = 3, Seconds = 35, Setup = SetupHalo,    Draw = DrawHalo},
        {Key = "Eye",     Weight = 3, Seconds = 30, Setup = SetupEye,     Draw = DrawEye},
        {Key = "Verse",   Weight = 3, Seconds = 25, Setup = SetupVerse,   Draw = DrawVerse},
        {Key = "Trigger", Weight = 4, Seconds = 45, Setup = SetupTrigger, Draw = DrawTrigger},
        {Key = "Doorway", Weight = 3, Seconds = 40, Setup = SetupDoorway, Draw = DrawDoorway}
    }

    local function FindBugTypeOrNil(Key)
        if Key == nil then return nil end

        for i = 1, #BugTypes do
            if BugTypes[i].Key == Key then return BugTypes[i] end
        end

        return nil
    end

    local function PickBugType()
        local Total = 0

        for i = 1, #BugTypes do
            Total = Total + BugTypes[i].Weight
        end

        local Roll = math.Rand(0, Total)

        for i = 1, #BugTypes do
            Roll = Roll - BugTypes[i].Weight

            if Roll <= 0 then return BugTypes[i] end
        end

        return BugTypes[1]
    end

    local function CountVisions(Key)
        local Count = 0

        for i = 1, #Visions do
            if Visions[i].Def.Key == Key then Count = Count + 1 end
        end

        return Count
    end

    local function GetVisionK(Vision, Now)
        local FadeIn  = (Now - Vision.Start) / VisionFade
        local FadeOut = (Vision.Stop - Now) / VisionFade
        local K       = math.Clamp(math.min(FadeIn, FadeOut, 1), 0, 1)

        return K * K * (3 - 2 * K)
    end

    local function ShowBug(Now, Def)
        if #Visions >= MaxVisions then return false end

        Def = Def or PickBugType()

        VisionCount = VisionCount + 1

        local Vision = {
            Def        = Def,
            Start      = Now,
            Stop       = Now + Def.Seconds,
            Text       = Verses[math.random(#Verses)],
            LightIndex = LightBase + (VisionCount % 8) * 10
        }

        if not Def.Setup(Vision) then return false end

        table.insert(Visions, Vision)

        return true
    end

    local function UpdateBug(Now)
        if not BugEnabled then return end
        if Now < NextBug then return end

        if #Visions > 0 then
            NextBug = Now + PlaceRetry

            return
        end

        NextBug = Now + math.Rand(BugMin, BugMax)

        if not ShowBug(Now, nil) then NextBug = Now + PlaceRetry end
    end

    local function UpdateWhiteVerse(Now)
        if WhiteK <= 0 then return end
        if Now < NextWhiteVerse then return end

        NextWhiteVerse = Now + math.Rand(WhiteVerseMin, WhiteVerseMax)

        if CountVisions("Verse") >= WhiteVerseLimit then return end

        if not ShowBug(Now, FindBugTypeOrNil("Verse")) then NextWhiteVerse = Now + 1 end
    end

    hook.Add("PostDrawTranslucentRenderables", "gmm_Dev_World", function(Depth, Sky, Sky3D)
        if Depth or Sky or Sky3D then return end

        local Now = RealTime()

        for i = #Visions, 1, -1 do
            local Vision = Visions[i]

            if Now >= Vision.Stop then
                table.remove(Visions, i)
            else
                Vision.Def.Draw(Vision, GetVisionK(Vision, Now), Now)
            end
        end
    end)

    -- ------------------------------------------------------------------
    -- Белая пустота
    -- ------------------------------------------------------------------

    local function GetWhiteK(Now)
        if Now >= WhiteEnd then return 0 end

        local FadeIn  = (Now - WhiteStart) / WhiteFadeIn
        local FadeOut = (WhiteEnd - Now) / WhiteFadeOut
        local K       = math.Clamp(math.min(FadeIn, FadeOut, 1), 0, 1)

        return K * K * (3 - 2 * K)
    end

    local function ApplyFog(Scale)
        local Breath = 1 + WhiteBreath * math.sin(RealTime() * 0.6)

        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogStart(Lerp(WhiteK, WhiteFarStart, WhiteFogStart) * Scale)
        render.FogEnd(Lerp(WhiteK, WhiteFarEnd, WhiteFogEnd * Breath) * Scale)
        render.FogMaxDensity(1)
        render.FogColor(255, 255, 255)
    end

    net.Receive("gmm_Dev_White", function()
        local Seconds = net.ReadFloat()

        WhiteStart     = RealTime()
        WhiteEnd       = WhiteStart + Seconds
        NextWhiteVerse = WhiteStart + WhiteVerseFirst
    end)

    hook.Add("PreRender", "gmm_Dev_WhiteTick", function()
        WhiteK = GetWhiteK(RealTime())
    end)

    hook.Add("SetupWorldFog", "gmm_Dev_WhiteFog", function()
        if WhiteK <= 0 then return end

        ApplyFog(1)

        return true
    end)

    hook.Add("SetupSkyboxFog", "gmm_Dev_WhiteSky", function(Scale)
        if WhiteK <= 0 then return end

        ApplyFog(Scale)

        return true
    end)

    hook.Add("RenderScreenspaceEffects", "gmm_Dev_WhiteScreen", function()
        if WhiteK <= 0 then return end

        ColorMod["$pp_colour_brightness"] = 0.3 * WhiteK
        ColorMod["$pp_colour_contrast"]   = 1 - 0.25 * WhiteK
        ColorMod["$pp_colour_colour"]     = 1 - 0.85 * WhiteK

        DrawColorModify(ColorMod)
    end)

    -- ------------------------------------------------------------------

    local WasMoving    = false
    local MoveStart    = 0
    local NextEcho     = 0
    local DevLogText   = ""
    local DevLogUntil  = 0
    local NextDevLog   = RealTime() + 18

    local DevLogTemplates = {
        "WARNING: Node graph out of date. Rebuilding...",
        "VRAD: Lighting pass stalled at 99.4%",
        "Playback: woowz11_session_04.dem (loop)",
        "L-I-A: Не выключай сервер. Я ещё здесь.",
        "Warning: Unclosed portal -> LEVEL_0",
        "Memory leak in sector f5099cd: 412 KB",
        "Entity [observer] has no valid exit target",
        "Building cubemaps... failed (skybox = NULL)"
    }

    local MoveAccum       = 0
    local LastMoveCheck   = 0
    local NextEcho        = 0
    local DesyncStepsTill = 0
    local NextDesyncStep  = 0

    local function PlayDelayedStep(Delay, PitchMin, PitchMax, Volume)
        timer.Simple(Delay, function()
            local Ply = LocalPlayer()
            if not IsValid(Ply) then return end

            local BackPos = Ply:GetPos() - Angle(0, Ply:EyeAngles().y, 0):Forward() * 35
            sound.Play("player/footsteps/concrete" .. math.random(1, 4) .. ".wav", BackPos, 75, math.random(PitchMin, PitchMax), Volume)
        end)
    end

    local function UpdateFootEcho(Now)
        local Ply = LocalPlayer()
        if not IsValid(Ply) or not Ply:Alive() then
            MoveAccum = 0
            return
        end

        local Dt = math.min(Now - LastMoveCheck, 0.25)
        LastMoveCheck = Now

        local SpeedSqr = Ply:GetVelocity():Length2DSqr()
        local Moving   = SpeedSqr > (80 * 80) and Ply:OnGround()

        if Moving then
            MoveAccum = MoveAccum + Dt

            if Now < DesyncStepsTill and Now >= NextDesyncStep then
                NextDesyncStep = Now + 0.38
                PlayDelayedStep(0.45, 80, 92, 0.9)
            end

            return
        end

        if MoveAccum >= 1.2 and Now >= NextEcho then
            NextEcho = Now + math.Rand(6, 14)

            local StepCount = math.random(2, 3)
            for i = 1, StepCount do
                PlayDelayedStep(0.15 + (i - 1) * 0.38, 82, 95, 0.95)
            end
        end

        if SpeedSqr < (20 * 20) then
            MoveAccum = 0
        end
    end

    local function UpdateDevLog(Now)
        if Now < NextDevLog then return end

        NextDevLog  = Now + math.Rand(22, 55)
        DevLogUntil = Now + math.Rand(5, 9)

        local Ply = LocalPlayer()
        if IsValid(Ply) and math.random() < 0.3 then
            local P = Ply:GetPos()
            DevLogText = "LEAK: Hull breach at (" .. math.floor(P.x) .. ", " .. math.floor(P.y) .. ", " .. math.floor(P.z) .. ")"
        else
            DevLogText = DevLogTemplates[math.random(#DevLogTemplates)]
        end
    end
    
    local function UpdateInfo(Now)
        if Now < NextInfo then return end

        NextInfo = Now + InfoDelay
        FpsText  = "FPS: " .. math.floor(1 / math.max(FrameTime(), 0.0001))

        if not ShowPos then return end

        local Ply = LocalPlayer()
        if not IsValid(Ply) then return end

        local Pos = Ply:GetPos()

        PosText = "POS: " .. math.floor(Pos.x) .. " " .. math.floor(Pos.y) .. " " .. math.floor(Pos.z)
    end

    local function UpdateGolou(Now)
        if Now < NextGolou then return end

        GolouUntil = Now + math.Rand(GolouShowMin, GolouShowMax)
        NextGolou  = Now + math.Rand(GolouMin, GolouMax)
    end

    Dev.ShowBug = function(Key)
        local Def = FindBugTypeOrNil(Key)

        if Key ~= nil and Def == nil then
            print("[GMM] DEV VISION NOT FOUND! KEY: " .. tostring(Key))
            return false
        end

        if not ShowBug(RealTime(), Def) then
            print("[GMM] DEV VISION PLACE FAILED! KEY: " .. tostring(Key) .. ", ACTIVE: " .. #Visions)
            return false
        end

        local Vision = Visions[#Visions]
        local Origin = Vision.Pos or Vision.Center

        if Vision.Pillars ~= nil and Vision.Pillars[1] ~= nil then Origin = Vision.Pillars[1].Floor end

        local Dist = 0

        if Origin ~= nil and IsValid(LocalPlayer()) then Dist = math.floor(LocalPlayer():GetPos():Distance(Origin)) end

        print("[GMM] DEV VISION STARTED! KEY: " .. Vision.Def.Key .. ", DIST: " .. Dist .. ", ACTIVE: " .. #Visions)

        return true
    end

    concommand.Add("gmm_f5099cd_vision", function(Ply, Cmd, Args) Dev.ShowBug(Args[1]) end)

    print("[GMM] DEV BUILD LOADED! REALM: CLIENT")

    hook.Add("HUDPaint", "gmm_Dev_Hud", function()
        local Now = RealTime()

        UpdateInfo(Now)
        UpdateGolou(Now)
        UpdateBug(Now)
        UpdateWhiteVerse(Now)
        UpdateFootEcho(Now)
        UpdateDevLog(Now)

        local Width  = ScrW()
        local Height = ScrH()
        local Golou  = Now < GolouUntil
        local Fore   = ColorText
        local Back   = ColorShadow

        if WhiteK > 0.4 then
            Fore = ColorTextDark
            Back = ColorShadowLight
        end

        for i = 1, #BuildLines do
            local Text = BuildLines[i]

            if Golou and i == GolouIndex then Text = GolouLine end

            DrawLine(Text, Width - Margin, Height - Margin - (#BuildLines - i) * LineGap, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, Fore, Back)
        end

        if not ShowInfo then return end

        DrawLine(FpsText, Margin, Margin, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, Fore, Back)

        if ShowPos then DrawLine(PosText, Margin, Margin + LineGap, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, Fore, Back) end

        if Now < DevLogUntil then
            DrawLine(DevLogText, Margin, Margin + LineGap * 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, Fore, Back)
        end
    end)

    Dev.Cleanup = function()
        hook.Remove("HUDPaint", "gmm_Dev_Hud")
        hook.Remove("PlayerFootstep", "gmm_Dev_Steps")
        hook.Remove("PostDrawTranslucentRenderables", "gmm_Dev_World")
        hook.Remove("PreRender", "gmm_Dev_WhiteTick")
        hook.Remove("SetupWorldFog", "gmm_Dev_WhiteFog")
        hook.Remove("SetupSkyboxFog", "gmm_Dev_WhiteSky")
        hook.Remove("RenderScreenspaceEffects", "gmm_Dev_WhiteScreen")
    end
end