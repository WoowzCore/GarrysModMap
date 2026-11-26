
GMM_S.FearBehavior = {
    FLEE = 1,
    APPROACH = 2,
    AGGRESSIVE = 3
}

-- ----------------------------------------------------------------------
-- Группы сущностей
-- ----------------------------------------------------------------------

GMM_S.FearEntityGroups = {
    COMBINE = {
        "npc_metropolice",
        "npc_combine_s",
        "npc_combine_e",
        "npc_combine_elite"
    },

    REBELS = {
        "npc_citizen",
        "npc_alyx",
        "npc_barney",
        "npc_monk",
        "npc_kleiner",
        "npc_magnusson",
        "npc_mossman",
        "npc_breen"
    },

    ZOMBIES = {
        "npc_zombie",
        "npc_fastzombie",
        "npc_poisonzombie",
        "npc_zombine",
        "npc_zombie_torso",
        "npc_fastzombie_torso"
    },

    HEADCRABS = {
        "npc_headcrab",
        "npc_headcrab_fast",
        "npc_headcrab_black",
        "npc_headcrab_poison"
    },

    ANTILIONS = {
        "npc_antlion",
        "npc_antlionguard",
        "npc_antlion_worker"
    },

    ANIMALS = {
        "npc_crow",
        "npc_seagull",
        "npc_pigeon",
        "npc_bird",
        "npc_crow"
    },

    MACHINES = {
        "npc_turret_floor",
        "npc_turret_ceiling",
        "npc_rollermine",
        "npc_cscanner",
        "npc_clawscanner",
        "npc_combinegunship",
        "npc_helicopter",
        "npc_combinedropship"
    },

    MILITARY = {
        "npc_hunter",
        "npc_strider",
        "npc_manhack"
    },

    VORTIGAUNTS = {
        "npc_vortigaunt"
    },

    ANIMALS_HOSTILE = {
        "npc_antlion",
        "npc_antlionguard",
        "npc_antlion_worker"
    }
}

-- ----------------------------------------------------------------------
-- Данные
-- ----------------------------------------------------------------------

local FearConfig = {
    ThinkDelay = 0.15,
    StopDelay = 1,
    MoveDist = 2,
    FleeDistance = 1500,
    RepathDelay = 0.75
}

local FearTargets = {}

local FearIgnore = {
    npc_turret_floor = true,
    npc_turret_ceiling = true,
    npc_rollermine = true
}

local FearNPCIgnore = {
    npc_bullseye = true,
    npc_grenade_frag = true,
    npc_satchel = true,
    npc_tripmine = true,
    npc_furniture = true,
    npc_crow = true,
    npc_seagull = true,
    npc_pigeon = true,
    npc_cscanner = true,
    npc_clawscanner = true,
    npc_combinegunship = true,
    npc_helicopter = true,
    npc_combinedropship = true
}

local FearMeleeWeapons = {
    weapon_crowbar = true,
    weapon_stunstick = true,
    weapon_physcannon = true,
    weapon_physgun = true,
    weapon_frag = true,
    weapon_slam = true
}

local AiDisabledVar = GetConVar("ai_disabled")

-- ----------------------------------------------------------------------
-- Проверка групп
-- ----------------------------------------------------------------------

local function IsClassInGroup(Class, Group)
    if Group == nil then return false end

    for i = 1, #Group do
        if Group[i] == Class then
            return true
        end
    end

    return false
end

local function IsAntlion(Class)
    return IsClassInGroup(Class, GMM_S.FearEntityGroups.ANTILIONS)
end

-- ----------------------------------------------------------------------
-- Проверка оружия
-- ----------------------------------------------------------------------

local function HasFearFirearm(Npc)
    if not IsValid(Npc) or not Npc.GetActiveWeapon then return false end

    local Weapon = Npc:GetActiveWeapon()

    if not IsValid(Weapon) then return false end

    local WeaponClass = Weapon:GetClass()

    if FearMeleeWeapons[WeaponClass] then return false end

    if string.StartWith(WeaponClass, "weapon_") then
        return true
    end

    return false
end

-- ----------------------------------------------------------------------
-- Регистрация угроз
-- ----------------------------------------------------------------------

local function RegisterFearTarget(Class, Config)
    if type(Class) ~= "string" or Class == "" then return false end

    Config = Config or {}

    FearTargets[Class] = {
        Range = Config.Range or 1200,
        Priority = Config.Priority or 99,

        Behavior = Config.Behavior or GMM_S.FearBehavior.FLEE,
        Speed = Config.Speed,

        FleeDistance = Config.FleeDistance or FearConfig.FleeDistance,
        ApproachDistance = Config.ApproachDistance or 100,
        RepathDelay = Config.RepathDelay or FearConfig.RepathDelay,
        StopDelay = Config.StopDelay or FearConfig.StopDelay,
        MoveDist = Config.MoveDist or FearConfig.MoveDist,

        ViewDistance = Config.ViewDistance,
        ViewFOV = Config.ViewFOV or 360,

        RequireVisibility = Config.RequireVisibility ~= false,
        StopWhenHidden = Config.StopWhenHidden ~= false,

        Schedule = Config.Schedule,
        ApproachSchedule = Config.ApproachSchedule or SCHED_FORCED_GO_RUN,
        AttackSchedule = Config.AttackSchedule or SCHED_RANGE_ATTACK1,

        Condition = Config.Condition,
        NPCCondition = Config.NPCCondition,
        TargetCondition = Config.TargetCondition,
        VisibilityCheck = Config.VisibilityCheck,

        OnStart = Config.OnStart,
        OnUpdate = Config.OnUpdate,
        OnStop = Config.OnStop
    }

    return true
end

GMM_S.Func.AddFearTarget = function(Class, Config)
    if type(Class) == "string" then
        return RegisterFearTarget(Class, Config)
    end

    if type(Class) ~= "table" then return false end

    local Registered = false

    for i = 1, #Class do
        if RegisterFearTarget(Class[i], Config) then
            Registered = true
        end
    end

    return Registered
end

GMM_S.Func.RemoveFearTarget = function(Class)
    if type(Class) == "string" then
        FearTargets[Class] = nil
        return
    end

    if type(Class) ~= "table" then return end

    for i = 1, #Class do
        FearTargets[Class[i]] = nil
    end
end

GMM_S.Func.AddFearIgnoreNPC = function(Class)
    FearIgnore[Class] = true
end

GMM_S.Func.RemoveFearIgnoreNPC = function(Class)
    FearIgnore[Class] = nil
end

GMM_S.Func.AddFearNPCIgnore = function(Class)
    FearNPCIgnore[Class] = true
end

GMM_S.Func.RemoveFearNPCIgnore = function(Class)
    FearNPCIgnore[Class] = nil
end

-- ----------------------------------------------------------------------
-- Получение настроек
-- ----------------------------------------------------------------------

local function GetFearValue(Value, Npc, Threat, Default)
    if type(Value) == "function" then
        local Result = Value(Npc, Threat)

        if Result ~= nil then return Result end

        return Default
    end

    if Value ~= nil then return Value end

    return Default
end

local function GetFearBehavior(Npc, Threat, Config)
    return GetFearValue(Config.Behavior, Npc, Threat, GMM_S.FearBehavior.FLEE)
end

local function GetFearSpeed(Npc, Threat, Config)
    return GetFearValue(Config.Speed, Npc, Threat, nil)
end

-- ----------------------------------------------------------------------
-- Проверка видимости
-- ----------------------------------------------------------------------

local function IsThreatVisible(Npc, Threat, Config)
    if Config.VisibilityCheck ~= nil then
        return Config.VisibilityCheck(Npc, Threat)
    end

    return Npc:Visible(Threat)
end

local function IsThreatInFOV(Npc, Threat, FOV)
    if FOV >= 360 then return true end

    local Direction = Threat:GetPos() - Npc:GetPos()

    if Direction:LengthSqr() < 1 then return true end

    Direction:Normalize()

    local Dot = Npc:GetForward():Dot(Direction)
    local MinDot = math.cos(math.rad(FOV * 0.5))

    return Dot >= MinDot
end

-- ----------------------------------------------------------------------
-- Поиск угрозы
-- ----------------------------------------------------------------------

local function GetNearestFearTarget(Npc, Targets)
    local NpcPos = Npc:GetPos()

    local BestTarget = nil
    local BestConfig = nil
    local BestDistSqr = math.huge

    for i = 1, #Targets do
        local Data = Targets[i]
        local Target = Data.Entity
        local Config = Data.Config

        if IsValid(Target) then
            local CanTarget = true

            if Config.NPCCondition ~= nil and not Config.NPCCondition(Npc, Target) then
                CanTarget = false
            end

            if CanTarget and Config.TargetCondition ~= nil and not Config.TargetCondition(Target, Npc) then
                CanTarget = false
            end

            if CanTarget and Config.Condition ~= nil and not Config.Condition(Npc, Target) then
                CanTarget = false
            end

            if CanTarget then
                local DistSqr = NpcPos:DistToSqr(Target:GetPos())

                local Range = GetFearValue(Config.Range, Npc, Target, 1200)
                local ViewDistance = GetFearValue(Config.ViewDistance, Npc, Target, Range)
                local ViewFOV = GetFearValue(Config.ViewFOV, Npc, Target, 360)

                local MaxDistance = math.min(Range, ViewDistance)

                if DistSqr < MaxDistance * MaxDistance then
                    if IsThreatInFOV(Npc, Target, ViewFOV) then
                        local CheckVisibility = Config.RequireVisibility or Config.StopWhenHidden
                        local IsVisible = true

                        if CheckVisibility then
                            IsVisible = IsThreatVisible(Npc, Target, Config)
                        end

                        if IsVisible and DistSqr < BestDistSqr then
                            BestTarget = Target
                            BestConfig = Config
                            BestDistSqr = DistSqr
                        end
                    end
                end
            end
        end
    end

    return BestTarget, BestConfig
end

-- ----------------------------------------------------------------------
-- Остановка страха
-- ----------------------------------------------------------------------

local function StopFear(Npc)
    if Npc.GMMFearTarget ~= nil then
        local OldTarget = Npc.GMMFearTarget
        local OldConfig = Npc.GMMFearConfig

        if OldConfig ~= nil and OldConfig.OnStop ~= nil then
            OldConfig.OnStop(Npc, OldTarget)
        end
    end

    Npc.GMMFearTarget = nil
    Npc.GMMFearConfig = nil
    Npc.GMMFearLastPos = nil
    Npc.GMMFearLastMove = nil
    Npc.GMMFearNextMove = nil
    Npc.GMMFearSchedule = nil
    Npc.GMMFearBehavior = nil
end

-- ----------------------------------------------------------------------
-- Скорость NPC
-- ----------------------------------------------------------------------

local function ApplyFearSpeed(Npc, Threat, Config)
    local Speed = GetFearSpeed(Npc, Threat, Config)

    if Speed == nil then return end
    if Speed <= 0 then return end
    if not Npc.SetSaveValue then return end

    Npc:SetSaveValue("m_flSpeed", Speed)
end

-- ----------------------------------------------------------------------
-- Направление движения
-- ----------------------------------------------------------------------

local function GetFearPosition(Npc, Threat, Behavior, Config)
    local NpcPos = Npc:GetPos()
    local ThreatPos = Threat:GetPos()

    local Direction = NpcPos - ThreatPos

    if Direction:LengthSqr() < 1 then
        Direction = Vector(1, 0, 0)
    end

    Direction.z = 0
    Direction:Normalize()

    if Behavior == GMM_S.FearBehavior.FLEE then
        local Distance = GetFearValue(Config.FleeDistance, Npc, Threat, FearConfig.FleeDistance)

        return NpcPos + Direction * Distance
    end

    if Behavior == GMM_S.FearBehavior.APPROACH then
        local Distance = GetFearValue(Config.ApproachDistance, Npc, Threat, 100)

        return ThreatPos + Direction * Distance
    end

    return ThreatPos
end

-- ----------------------------------------------------------------------
-- Применение страха
-- ----------------------------------------------------------------------

local function MakeFear(Npc, Threat, Config)
    if not IsValid(Npc) or not IsValid(Threat) then return end
    if Npc:Health() <= 0 then return end

    local Class = Npc:GetClass()

    if FearNPCIgnore[Class] or FearIgnore[Class] then
        StopFear(Npc)
        return
    end

    local Now = CurTime()
    local Pos = Npc:GetPos()

    local Behavior = GetFearBehavior(Npc, Threat, Config)
    local Priority = GetFearValue(Config.Priority, Npc, Threat, 99)

    local Schedule

    if Behavior == GMM_S.FearBehavior.FLEE then
        Schedule = GetFearValue(Config.Schedule, Npc, Threat, SCHED_FORCED_GO_RUN or SCHED_MOVE_AWAY_FROM_ENEMY)
        Npc:AddEntityRelationship(Threat, D_FR, Priority)

    elseif Behavior == GMM_S.FearBehavior.APPROACH then
        Schedule = GetFearValue(Config.ApproachSchedule, Npc, Threat, SCHED_FORCED_GO_RUN)
        Npc:AddEntityRelationship(Threat, D_LI, Priority)

    elseif Behavior == GMM_S.FearBehavior.AGGRESSIVE then
        Schedule = GetFearValue(Config.AttackSchedule, Npc, Threat, SCHED_RANGE_ATTACK1)
        Npc:AddEntityRelationship(Threat, D_HT, Priority)

    else
        StopFear(Npc)
        return
    end

    if Npc.GMMFearTarget ~= Threat or Npc.GMMFearBehavior ~= Behavior then
        StopFear(Npc)

        Npc.GMMFearTarget = Threat
        Npc.GMMFearConfig = Config
        Npc.GMMFearBehavior = Behavior
        Npc.GMMFearLastPos = Pos
        Npc.GMMFearLastMove = Now
        Npc.GMMFearNextMove = 0

        if Behavior == GMM_S.FearBehavior.FLEE or Behavior == GMM_S.FearBehavior.AGGRESSIVE then
            Npc:SetEnemy(Threat)
            Npc:UpdateEnemyMemory(Threat, Threat:GetPos())

            if Npc.SetUnforgettable then
                Npc:SetUnforgettable(Threat, true)
            end
        end

        if Config.OnStart ~= nil then
            Config.OnStart(Npc, Threat, Behavior)
        end
    end

    if Config.OnUpdate ~= nil then
        Config.OnUpdate(Npc, Threat, Behavior)
    end

    if Behavior == GMM_S.FearBehavior.AGGRESSIVE then
        if Npc:GetEnemy() ~= Threat then
            Npc:SetEnemy(Threat)
        end

        Npc:UpdateEnemyMemory(Threat, Threat:GetPos())

        if Schedule ~= nil then
            if not Npc:IsCurrentSchedule(Schedule) then
                Npc:SetSchedule(Schedule)
            end
        end

        return
    end

    ApplyFearSpeed(Npc, Threat, Config)

    if Pos:DistToSqr(Npc.GMMFearLastPos) >= Config.MoveDist ^ 2 then
        Npc.GMMFearLastPos = Pos
        Npc.GMMFearLastMove = Now
    end

    local IsStuck = Now - Npc.GMMFearLastMove >= Config.StopDelay
    local ShouldRepath = Now >= Npc.GMMFearNextMove

    local IsCorrectSchedule = false

    if Schedule ~= nil and Npc.IsCurrentSchedule then
        IsCorrectSchedule = Npc:IsCurrentSchedule(Schedule)
    end

    if not ShouldRepath and not IsStuck and IsCorrectSchedule then return end

    local Goal = GetFearPosition(Npc, Threat, Behavior, Config)

    Npc:SetLastPosition(Goal)

    if Schedule ~= nil then
        Npc:SetSchedule(Schedule)
    end

    Npc.GMMFearLastPos = Pos
    Npc.GMMFearLastMove = Now
    Npc.GMMFearNextMove = Now + GetFearValue(Config.RepathDelay, Npc, Threat, FearConfig.RepathDelay)
    Npc.GMMFearSchedule = Schedule
end

-- ----------------------------------------------------------------------
-- Контроллер
-- ----------------------------------------------------------------------

timer.Remove("gmm_Fear_Controller")

timer.Create("gmm_Fear_Controller", FearConfig.ThinkDelay, 0, function()
    if AiDisabledVar ~= nil and AiDisabledVar:GetBool() then return end

    local Targets = {}

    for Class, Config in pairs(FearTargets) do
        for _, Ent in ipairs(ents.FindByClass(Class)) do
            if IsValid(Ent) then
                Targets[#Targets + 1] = {
                    Entity = Ent,
                    Config = Config
                }
            end
        end
    end

    for _, Npc in ipairs(ents.GetAll()) do
        if IsValid(Npc) and Npc:IsNPC() then
            if Npc:Health() <= 0 then
                StopFear(Npc)
            else
                local Class = Npc:GetClass()

                if FearNPCIgnore[Class] or FearIgnore[Class] then
                    StopFear(Npc)
                else
                    local Threat, Config = GetNearestFearTarget(Npc, Targets)

                    if IsValid(Threat) then
                        MakeFear(Npc, Threat, Config)
                    else
                        StopFear(Npc)
                    end
                end
            end
        end
    end
end)

-- ----------------------------------------------------------------------
-- Стандартные угрозы
-- ----------------------------------------------------------------------

GMM_S.Func.AddFearTarget("gmm_pavelzombie", {
    Range = 1500,
    ViewDistance = 1500,
    ViewFOV = 120,

    RequireVisibility = true,
    StopWhenHidden = true,

    Behavior = function(Npc, Threat)
        local Class = Npc:GetClass()
        local Distance = Npc:GetPos():Distance(Threat:GetPos())

        -- Antlions всегда атакуют Павла.
        if IsAntlion(Class) then
            return GMM_S.FearBehavior.AGGRESSIVE
        end

        -- Если NPC уже убегает, он продолжает это делать,
        -- пока не отдалится на достаточное расстояние.
        if Npc.GMMFearBehavior == GMM_S.FearBehavior.FLEE then
            if Distance <= 280 then
                return GMM_S.FearBehavior.FLEE
            end
        elseif Distance <= 180 then
            return GMM_S.FearBehavior.FLEE
        end

        -- Любой NPC с огнестрельным оружием атакует Павла.
        if HasFearFirearm(Npc) then
            return GMM_S.FearBehavior.AGGRESSIVE
        end

        -- Безоружные NPC убегают.
        return GMM_S.FearBehavior.FLEE
    end,

    AttackSchedule = function(Npc, Threat)
        if IsAntlion(Npc:GetClass()) then
            return SCHED_CHASE_ENEMY
        end

        return SCHED_RANGE_ATTACK1
    end,

    Speed = 250,

    Priority = 99,

    FleeDistance = 500,
    ApproachDistance = 100,

    RepathDelay = 0.75,
    StopDelay = 1,
    MoveDist = 2
})