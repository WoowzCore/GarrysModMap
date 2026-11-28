GMM_S.Anomaly = {}

GMM_S.Anomaly.List = {
    {20, "Shake"       , "Shakigravitosion"},
    {20, "PlaySound"   , "Weirdambientsion"},
    {20, "Interact"    , "Interaction"},
    {10, "SpawnEntity" , "Spawnion"},
    {2 , "Vanish"      , "Deletions"},
    {1 , "RenderGlitch", "Glitchesion"},
}

GMM_S.Anomaly.Spawned = {}

GMM_S.Anomaly.FindEntryOrNil = function(Key)
    local List = GMM_S.Anomaly.List
    for i = 1, #List do
        if List[i][2] == Key then return List[i] end
    end

    return nil
end

GMM_S.Anomaly.GetRandom = function()
    local List = GMM_S.Anomaly.List
    if #List == 0 then return nil end

    local TotalWeight = 0
    for i = 1, #List do
        TotalWeight = TotalWeight + List[i][1]
    end

    local RandomChoice  = math.random(1, TotalWeight)
    local CurrentWeight = 0

    for i = 1, #List do
        CurrentWeight = CurrentWeight + List[i][1]
        if RandomChoice <= CurrentWeight then return GMM_S.Anomaly[List[i][2]] end
    end

    return nil
end

-- ----------------------------------------------------------------------
-- Общие функции
-- ----------------------------------------------------------------------

local function GetAlivePlayers()
    local Result  = {}
    local Players = player.GetAll()

    for i = 1, #Players do
        if Players[i]:Alive() then Result[#Result + 1] = Players[i] end
    end

    return Result
end

local function GetRandomPlayerOrNil()
    local Alive = GetAlivePlayers()
    if #Alive == 0 then return nil end

    return Alive[math.random(#Alive)]
end

local function PickWeighted(List)
    local Total = 0
    for i = 1, #List do
        Total = Total + List[i][1]
    end

    local Roll = math.random() * Total

    for i = 1, #List do
        Roll = Roll - List[i][1]
        if Roll <= 0 then return List[i][2] end
    end

    return List[#List][2]
end

-- ----------------------------------------------------------------------
-- Тряска
-- ----------------------------------------------------------------------

local ShakeRadius     = 1800
local ShakeMaxProps   = 60
local ShakePulses     = 8
local ShakePulseDelay = 0.4
local ShakeQuakeForce = 140
local ShakeAmplitude  = 6
local ShakeFrequency  = 40

local RattleRadius    = 700
local RattleMaxProps  = 25
local RattleSteps     = 40
local RattleDelay     = 0.075
local RattleHopChance = 0.3
local RattleHop       = 40
local RattleSpin      = 60

local FloatRadius     = 600
local FloatMaxProps   = 20
local FloatMin        = 4
local FloatMax        = 8
local FloatRise       = 60
local FloatSpin       = 40

local ShakeTemp = Vector()

local function GetMovablePhysOrNil(Prop)
    if not IsValid(Prop) then return nil end

    local Phys = Prop:GetPhysicsObject()
    if not IsValid(Phys) then return nil end
    if not Phys:IsMotionEnabled() then return nil end

    return Phys
end

local function GetPropsNear(Center, Radius, Max)
    local Props     = GMM_S.Func.GetPhysicsProps()
    local RadiusSqr = Radius * Radius
    local Result    = {}

    for i = 1, #Props do
        local Prop = Props[i]

        if IsValid(Prop) and Prop:GetPos():DistToSqr(Center) < RadiusSqr then
            Result[#Result + 1] = Prop
        end
    end

    local Count = #Result
    local Limit = math.min(Count, Max)

    for i = 1, Limit do
        local j = math.random(i, Count)
        Result[i], Result[j] = Result[j], Result[i]
    end

    for i = Count, Limit + 1, -1 do
        Result[i] = nil
    end

    return Result
end

local function ShakeScatter()
    local Props = GMM_S.Func.GetPhysicsProps()
    if #Props == 0 then return end

    for _, Prop in ipairs(Props) do
        if math.random() > 0.99 then
            GMM_S.Func.ShakeProp(Prop, (math.random() > 0.9 and 10000000 or 10000) * math.random())
        end
    end
end

local function ShakeQuake()
    local Target = GetRandomPlayerOrNil()
    if Target == nil then return end

    local Center = Target:GetPos()
    local Props  = GetPropsNear(Center, ShakeRadius, ShakeMaxProps)
    local Pulse  = 0

    sound.Play("ambient/levels/streetwar/building_rubble" .. math.random(1, 5) .. ".wav", Center, 90, math.random(60, 90), 1)

    timer.Create("gmm_Anomaly_Quake", ShakePulseDelay, ShakePulses, function()
        Pulse = Pulse + 1

        local Power = math.sin(math.pi * Pulse / ShakePulses)
        local Force = ShakeQuakeForce * Power

        util.ScreenShake(Center, ShakeAmplitude * Power, ShakeFrequency, ShakePulseDelay * 1.5, ShakeRadius)

        for i = 1, #Props do
            local Phys = GetMovablePhysOrNil(Props[i])

            if Phys ~= nil then
                ShakeTemp:SetUnpacked(math.Rand(-1, 1) * Force, math.Rand(-1, 1) * Force, math.Rand(0.3, 1) * Force)

                Phys:Wake()
                Phys:AddVelocity(ShakeTemp)
            end
        end
    end)
end

local function ShakeRattle()
    local Target = GetRandomPlayerOrNil()
    if Target == nil then return end

    local Props = GetPropsNear(Target:GetPos(), RattleRadius, RattleMaxProps)
    if #Props == 0 then
        ShakeQuake()
        return
    end

    timer.Create("gmm_Anomaly_Rattle", RattleDelay, RattleSteps, function()
        for i = 1, #Props do
            local Phys = GetMovablePhysOrNil(Props[i])

            if Phys ~= nil then
                Phys:Wake()

                ShakeTemp:SetUnpacked(math.Rand(-RattleSpin, RattleSpin), math.Rand(-RattleSpin, RattleSpin), math.Rand(-RattleSpin, RattleSpin))
                Phys:AddAngleVelocity(ShakeTemp)

                if math.random() < RattleHopChance then
                    ShakeTemp:SetUnpacked(0, 0, math.Rand(RattleHop * 0.3, RattleHop))
                    Phys:AddVelocity(ShakeTemp)
                end
            end
        end
    end)
end

local function ShakeFloat()
    local Target = GetRandomPlayerOrNil()
    if Target == nil then return end

    local Props = GetPropsNear(Target:GetPos(), FloatRadius, FloatMaxProps)
    if #Props == 0 then
        ShakeQuake()
        return
    end

    for i = 1, #Props do
        local Phys = GetMovablePhysOrNil(Props[i])

        if Phys ~= nil then
            Phys:EnableGravity(false)
            Phys:Wake()

            ShakeTemp:SetUnpacked(0, 0, math.Rand(FloatRise * 0.5, FloatRise))
            Phys:AddVelocity(ShakeTemp)

            ShakeTemp:SetUnpacked(math.Rand(-FloatSpin, FloatSpin), math.Rand(-FloatSpin, FloatSpin), math.Rand(-FloatSpin, FloatSpin))
            Phys:AddAngleVelocity(ShakeTemp)
        end
    end

    timer.Simple(math.Rand(FloatMin, FloatMax), function()
        for i = 1, #Props do
            local Prop = Props[i]

            if IsValid(Prop) then
                local Phys = Prop:GetPhysicsObject()

                if IsValid(Phys) then
                    Phys:EnableGravity(true)
                    Phys:Wake()
                end
            end
        end
    end)
end

local ShakeModes = {
    {10, ShakeScatter},
    {1, ShakeQuake},
    {5, ShakeRattle},
    {1, ShakeFloat}
}

GMM_S.Anomaly.Shake = function()
    PickWeighted(ShakeModes)()
end

-- ----------------------------------------------------------------------
-- Звуки
-- ----------------------------------------------------------------------

local SoundLevel        = 95
local SoundMinDist      = 250
local SoundMaxDist      = 900
local SoundSpread       = 35
local SoundWallPad      = 16
local SoundBehindChance = 0.5
local SoundStopAfter    = 60
local SoundEmitterModel = "models/props_junk/PopCan01a.mdl"

local function GetSoundPos(Target)
    local Aim = Target:GetAimVector()
    Aim.z = 0

    if Aim:LengthSqr() < 0.01 then
        Aim = Vector(1, 0, 0)
    else
        Aim:Normalize()
    end

    if math.random() < SoundBehindChance then Aim:Mul(-1) end

    local Dir = Aim:Angle()
    Dir.y = Dir.y + math.Rand(-SoundSpread, SoundSpread)

    local Eye   = Target:EyePos()
    local Start = Eye + Dir:Forward() * math.Rand(SoundMinDist, SoundMaxDist)

    local Trace = util.TraceLine({
        start  = Eye,
        endpos = Start,
        mask   = MASK_SOLID_BRUSHONLY
    })

    if Trace.Hit then return Trace.HitPos + Trace.HitNormal * SoundWallPad end

    return Start
end

local function CreateSoundEmitterOrNil(Pos)
    local Emitter = ents.Create("prop_dynamic")
    if not IsValid(Emitter) then return nil end

    Emitter:SetModel(SoundEmitterModel)
    Emitter:SetPos(Pos)
    Emitter:Spawn()
    Emitter:SetNoDraw(true)
    Emitter:SetNotSolid(true)
    Emitter:DrawShadow(false)

    return Emitter
end

GMM_S.Anomaly.PlaySound = function()
    local Target = GetRandomPlayerOrNil()
    if Target == nil then return end

    local Pool
    if math.random() < 0.1 then
        Pool = GMM.Data.AnomalySounds.Rare
    else
        Pool = GMM.Data.AnomalySounds.Common
    end

    if Pool == nil or #Pool == 0 then
        print("[GMM] ANOMALY SOUND POOL EMPTY!")
        return
    end

    local SoundPath = Pool[math.random(1, #Pool)]

    local Emitter = CreateSoundEmitterOrNil(GetSoundPos(Target))
    if Emitter == nil then
        print("[GMM] ANOMALY SOUND EMITTER FAILED! SOUND: " .. tostring(SoundPath))
        return
    end

    Emitter:EmitSound(SoundPath, SoundLevel, math.random(50, 150), math.Rand(0.3, 1), CHAN_AUTO)

    local Life = SoundDuration(SoundPath)
    if Life <= 0 or Life > SoundStopAfter then
        Life = SoundStopAfter
    else
        Life = Life + 1
    end

    timer.Simple(Life, function()
        if not IsValid(Emitter) then return end

        Emitter:StopSound(SoundPath)
        Emitter:Remove()
    end)
end

-- ----------------------------------------------------------------------
-- Взаимодействие
-- ----------------------------------------------------------------------

local InteractClasses = {
    "func_button",
    "func_rot_button",
    "prop_door_rotating",
    "func_door",
    "func_door_rotating",
    "button_target",
    "prop_button",
    "func_movelinear",
    "func_typewriter"
}

local DoorClasses = {
    ["func_door"]          = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true
}

local InteractNearChance = 0.7
local InteractNearRadius = 1500
local DoorNearRadius     = 900

local AjarMin      = 2
local AjarMax      = 6
local SlamStepsMin = 4
local SlamStepsMax = 9
local SlamDelayMin = 0.15
local SlamDelayMax = 0.4
local KnockCount   = 3
local KnockLong    = 7
local KnockLongChance = 0.15
local KnockDelayMin   = 0.35
local KnockDelayMax   = 0.6

local function IsDoorUsable(Door)
    if GMM_S.Func.CanOpenDoor then
        if not GMM_S.Func.CanOpenDoor(Door) then return false end
        return true
    end

    local Flags = Door:GetInternalVariable("m_spawnflags")
    if Flags and (bit.band(Flags, 2048) ~= 0 or bit.band(Flags, 32) ~= 0 or bit.band(Flags, 512) ~= 0) then return false end

    return true
end

local function GatherInteractables()
    local Doors  = {}
    local Others = {}

    for i = 1, #InteractClasses do
        local Class = InteractClasses[i]
        local List  = ents.FindByClass(Class)

        for j = 1, #List do
            local Ent = List[j]

            if not DoorClasses[Class] then
                Others[#Others + 1] = Ent
            elseif IsDoorUsable(Ent) then
                Doors[#Doors + 1] = Ent
            end
        end
    end

    return Doors, Others
end

local function FilterNear(List, Center, Radius)
    if Center == nil then return List end

    local RadiusSqr = Radius * Radius
    local Result    = {}

    for i = 1, #List do
        local Ent = List[i]

        if IsValid(Ent) and Ent:WorldSpaceCenter():DistToSqr(Center) < RadiusSqr then
            Result[#Result + 1] = Ent
        end
    end

    return Result
end

local function PickNearDoorOrNil(Doors, Center)
    local Near = FilterNear(Doors, Center, DoorNearRadius)
    if #Near == 0 then return nil end

    return Near[math.random(#Near)]
end

local function InteractUse(Doors, Others, Center)
    local All = {}

    for i = 1, #Doors do
        All[#All + 1] = Doors[i]
    end

    for i = 1, #Others do
        All[#All + 1] = Others[i]
    end

    if #All == 0 then return end

    local Pool = All

    if math.random() < InteractNearChance then
        local Near = FilterNear(All, Center, InteractNearRadius)
        if #Near > 0 then Pool = Near end
    end

    local Picked = Pool[math.random(#Pool)]
    if IsValid(Picked) then Picked:Fire("Use") end
end

local function InteractAjar(Doors, Others, Center)
    local Door = PickNearDoorOrNil(Doors, Center)

    if Door == nil then
        InteractUse(Doors, Others, Center)
        return
    end

    Door:Fire("Open")
    Door:Fire("Close", "", math.Rand(AjarMin, AjarMax))
end

local function SlamStep(Door, Left)
    if not IsValid(Door) then return end

    Door:Fire("Toggle")

    if Left <= 1 then
        Door:Fire("Close", "", 0.4)
        return
    end

    timer.Simple(math.Rand(SlamDelayMin, SlamDelayMax), function()
        SlamStep(Door, Left - 1)
    end)
end

local function InteractSlam(Doors, Others, Center)
    local Door = PickNearDoorOrNil(Doors, Center)

    if Door == nil then
        InteractUse(Doors, Others, Center)
        return
    end

    SlamStep(Door, math.random(SlamStepsMin, SlamStepsMax))
end

local function KnockStep(Door, Left)
    if not IsValid(Door) then return end

    sound.Play("physics/wood/wood_crate_impact_hard" .. math.random(1, 5) .. ".wav", Door:WorldSpaceCenter(), 80, math.random(80, 100), 1)

    if Left <= 1 then return end

    timer.Simple(math.Rand(KnockDelayMin, KnockDelayMax), function()
        KnockStep(Door, Left - 1)
    end)
end

local function InteractKnock(Doors, Others, Center)
    local Door = PickNearDoorOrNil(Doors, Center)

    if Door == nil then
        InteractUse(Doors, Others, Center)
        return
    end

    local Count = KnockCount
    if math.random() < KnockLongChance then Count = KnockLong end

    KnockStep(Door, Count)
end

local InteractModes = {
    {5, InteractUse},
    {3, InteractAjar},
    {1, InteractSlam},
    {3, InteractKnock}
}

GMM_S.Anomaly.Interact = function()
    local Doors, Others = GatherInteractables()
    if #Doors + #Others == 0 then return end

    local Target = GetRandomPlayerOrNil()
    local Center = nil
    if Target ~= nil then Center = Target:GetPos() end

    PickWeighted(InteractModes)(Doors, Others, Center)
end

-- ----------------------------------------------------------------------
-- Спавн
-- ----------------------------------------------------------------------

local SpawnTries           = 24
local SpawnMinDist         = 600
local SpawnMaxDist         = 1800
local SpawnDrop            = 1500
local SpawnNavDrop         = 64
local SpawnFloorNormal     = 0.9
local SpawnLift            = 1
local SpawnHullPad         = 1.15
local SpawnRareChance      = 0.05
local SpawnSuperRareChance = 0.01

local SpawnGroupChance = 0.03
local SpawnGroupMin    = 2
local SpawnGroupMax    = 20
local SpawnGroupTries  = 8
local SpawnGroupSpread = 200
local SpawnGroupDrop   = 48

local SpawnWallChance  = 0.04
local SpawnWallMinDist = 250
local SpawnWallReach   = 1500
local SpawnWallTries   = 12
local SpawnWallDepth   = 12

local SpawnMinDistSqr     = SpawnMinDist * SpawnMinDist
local SpawnWallMinDistSqr = SpawnWallMinDist * SpawnWallMinDist

local DefaultHullMins = Vector(-16, -16, 0)
local DefaultHullMaxs = Vector(16, 16, 72)

local function IsInSolid(Pos)
    return bit.band(util.PointContents(Pos), CONTENTS_SOLID) ~= 0
end

local function IsFarFromPlayers(Pos, Players, MinSqr)
    for i = 1, #Players do
        if Players[i]:GetPos():DistToSqr(Pos) < MinSqr then return false end
    end

    return true
end

local function GetGroupCap(Radius)
    if Radius > 80 then return 3 end
    if Radius > 40 then return 8 end

    return SpawnGroupMax
end

local function MeasureHull(Ent)
    local Mins, Maxs = Ent:GetModelBounds()

    if Mins == nil or Maxs == nil or Maxs:LengthSqr() < 1 then
        Mins = DefaultHullMins
        Maxs = DefaultHullMaxs
    end

    local Radius = math.max(Maxs.x, -Mins.x, Maxs.y, -Mins.y) * SpawnHullPad

    return Vector(-Radius, -Radius, Mins.z), Vector(Radius, Radius, Maxs.z), Radius
end

local function TryFloor(Start, Drop, HullMins, HullMaxs)
    local Trace = util.TraceHull({
        start  = Start,
        endpos = Start - Vector(0, 0, Drop),
        mins   = HullMins,
        maxs   = HullMaxs,
        mask   = MASK_SOLID_BRUSHONLY
    })

    if Trace.StartSolid then return nil end
    if not Trace.Hit then return nil end
    if Trace.HitSky or Trace.HitNoDraw then return nil end
    if Trace.HitNormal.z < SpawnFloorNormal then return nil end

    local Pos = Trace.HitPos + Vector(0, 0, SpawnLift)

    if not util.IsInWorld(Pos) then return nil end
    if bit.band(util.PointContents(Pos), MASK_WATER) ~= 0 then return nil end

    local Free = util.TraceHull({
        start  = Pos,
        endpos = Pos,
        mins   = HullMins,
        maxs   = HullMaxs,
        mask   = MASK_SOLID
    })

    if Free.StartSolid or Free.Hit then return nil end

    return Pos
end

local function FindNavAreas(Center)
    if not navmesh.IsLoaded() then return nil end

    local Areas = navmesh.Find(Center, SpawnMaxDist, 200, 200)
    if #Areas == 0 then return nil end

    return Areas
end

local function GetCandidate(Center, Areas, HullMins)
    if Areas ~= nil then
        local Point = Areas[math.random(#Areas)]:GetRandomPoint()
        return Point + Vector(0, 0, 8 - HullMins.z), SpawnNavDrop
    end

    local Rad   = math.rad(math.random(0, 359))
    local Dist  = math.Rand(SpawnMinDist, SpawnMaxDist)
    local Start = Center + Vector(math.cos(Rad) * Dist, math.sin(Rad) * Dist, math.Rand(32, 300))

    if IsInSolid(Start) then return nil, 0 end

    return Start, SpawnDrop
end

local function FindSpawnPos(Target, Players, HullMins, HullMaxs)
    local Center = Target:GetPos()
    local Areas  = FindNavAreas(Center)

    for i = 1, SpawnTries do
        local Start, Drop = GetCandidate(Center, Areas, HullMins)

        if Start ~= nil then
            local Pos = TryFloor(Start, Drop, HullMins, HullMaxs)

            if Pos ~= nil and IsFarFromPlayers(Pos, Players, SpawnMinDistSqr) then return Pos end
        end
    end

    return nil
end

local function FindGroupPos(Anchor, HullMins, HullMaxs, Radius)
    for i = 1, SpawnGroupTries do
        local Rad   = math.rad(math.random(0, 359))
        local Dist  = math.Rand(Radius * 2, Radius * 2 + SpawnGroupSpread)
        local Start = Anchor + Vector(math.cos(Rad) * Dist, math.sin(Rad) * Dist, 8)
        local Pos   = TryFloor(Start, SpawnGroupDrop, HullMins, HullMaxs)

        if Pos ~= nil then return Pos end
    end

    return nil
end

local function TrackSpawned(Ent)
    local List = GMM_S.Anomaly.Spawned

    for i = #List, 1, -1 do
        if not IsValid(List[i]) then table.remove(List, i) end
    end

    List[#List + 1] = Ent
end

local function IsStuck(Ent)
    local Pos = Ent:GetPos()

    local Trace = util.TraceHull({
        start  = Pos,
        endpos = Pos,
        mins   = Ent:OBBMins(),
        maxs   = Ent:OBBMaxs(),
        mask   = MASK_SOLID,
        filter = Ent
    })

    return Trace.StartSolid
end

local function CreateSpawnEntity(Class, Model)
    local Ent = ents.Create(Class)

    if not IsValid(Ent) then
        print("[GMM] ANOMALY SPAWN CLASS INVALID! CLASS: " .. tostring(Class))
        return nil
    end

    if Model ~= nil then
        Ent:SetModel(Model)

        local SkinCount = Ent:SkinCount()
        if SkinCount > 1 then Ent:SetSkin(math.random(0, SkinCount - 1)) end
    end

    return Ent
end

local function PlaceEntity(Ent, Pos)
    Ent:SetPos(Pos)
    Ent:SetAngles(Angle(0, math.random(0, 359), 0))

    Ent.PhysgunDisabled = true

    Ent:Spawn()
    Ent:Activate()

    if IsStuck(Ent) then
        Ent:Remove()
        return false
    end

    if Ent:IsNPC() then Ent:SetSchedule(SCHED_FORCED_GO_RUN) end

    TrackSpawned(Ent)

    return true
end

local function PlaceInWall(Ent, Target, Players)
    local Origin = Target:GetPos() + Vector(0, 0, math.Rand(24, 64))

    for i = 1, SpawnWallTries do
        local Dir = Angle(math.Rand(-20, 20), math.random(0, 359), 0):Forward()

        local Trace = util.TraceLine({
            start  = Origin,
            endpos = Origin + Dir * SpawnWallReach,
            mask   = MASK_SOLID_BRUSHONLY
        })

        if Trace.Hit and not Trace.HitSky and not Trace.HitNoDraw and IsFarFromPlayers(Trace.HitPos, Players, SpawnWallMinDistSqr) then
            Ent:SetPos(Trace.HitPos - Trace.HitNormal * math.Rand(0, SpawnWallDepth))
            Ent:SetAngles(AngleRand())

            Ent.PhysgunDisabled = true

            Ent:Spawn()
            Ent:Activate()

            local Phys = Ent:GetPhysicsObject()
            if IsValid(Phys) then Phys:EnableMotion(false) end

            TrackSpawned(Ent)

            return true
        end
    end

    return false
end

local function PickSpawnPool()
    local Data  = GMM.Data.AnomalySpawn
    local Super = Data.SuperRare
    local Roll  = math.random()

    if Super ~= nil and #Super > 0 and Roll < SpawnSuperRareChance then return Super, true end
    if Roll < SpawnSuperRareChance + SpawnRareChance then return Data.Rare, false end

    return Data.Common, false
end

GMM_S.Anomaly.SpawnEntity = function()
    local Alive = GetAlivePlayers()
    if #Alive == 0 then return end

    local Target  = Alive[math.random(#Alive)]
    local Players = player.GetAll()

    local Pool, Single = PickSpawnPool()
    local Class        = Pool[math.random(#Pool)]
    local Model        = nil

    if Class == "prop_physics" then
        local Models = GMM.Data.AnomalySpawn.Models
        Model = Models[math.random(#Models)]
    end

    local First = CreateSpawnEntity(Class, Model)
    if First == nil then return end

    if Class == "prop_physics" and math.random() < SpawnWallChance and PlaceInWall(First, Target, Players) then return end

    local HullMins, HullMaxs, Radius = MeasureHull(First)

    local Pos = FindSpawnPos(Target, Players, HullMins, HullMaxs)
    if Pos == nil then
        First:Remove()
        return
    end

    if not PlaceEntity(First, Pos) then return end

    local Count = 1
    if not Single and math.random() < SpawnGroupChance then
        Count = math.min(math.random(SpawnGroupMin, SpawnGroupMax), GetGroupCap(Radius))
    end

    for i = 2, Count do
        local Ent = CreateSpawnEntity(Class, Model)
        if Ent == nil then return end

        local GroupPos = FindGroupPos(Pos, HullMins, HullMaxs, Radius)

        if GroupPos == nil then
            Ent:Remove()
        else
            PlaceEntity(Ent, GroupPos)
        end
    end
end

-- ----------------------------------------------------------------------
-- Исчезновение
-- ----------------------------------------------------------------------

local VanishMinDist  = 2000
local VanishMax      = 25
local VanishDelayMax = 6

local VanishMinDistSqr = VanishMinDist * VanishMinDist

local function IsVanishable(Prop, Players)
    if not IsValid(Prop) then return false end
    if Prop:IsPlayerHolding() then return false end
    if not IsFarFromPlayers(Prop:GetPos(), Players, VanishMinDistSqr) then return false end

    return true
end

local function GatherVanishable(Players)
    local Result = {}
    local Seen   = {}
    local Props  = GMM_S.Func.GetPhysicsProps()

    for i = 1, #Props do
        local Prop = Props[i]

        if GetMovablePhysOrNil(Prop) ~= nil and IsVanishable(Prop, Players) then
            Seen[Prop]           = true
            Result[#Result + 1]  = Prop
        end
    end

    local Spawned = GMM_S.Anomaly.Spawned

    for i = 1, #Spawned do
        local Ent = Spawned[i]

        if not Seen[Ent] and IsVanishable(Ent, Players) then
            Result[#Result + 1] = Ent
        end
    end

    return Result
end

GMM_S.Anomaly.Vanish = function()
    local Players = GetAlivePlayers()
    if #Players == 0 then return end

    local Found = GatherVanishable(Players)
    local Count = #Found
    if Count == 0 then return end

    local Limit = math.min(Count, math.random(1, VanishMax))

    for i = 1, Limit do
        local j = math.random(i, Count)
        Found[i], Found[j] = Found[j], Found[i]
    end

    for i = 1, Limit do
        local Prop = Found[i]

        timer.Simple(math.Rand(0, VanishDelayMax), function()
            if not IsVanishable(Prop, GetAlivePlayers()) then return end

            Prop:Remove()
        end)
    end
end

-- ----------------------------------------------------------------------
-- Глитч
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Глитч
-- ----------------------------------------------------------------------

local NetRenderGlitch = "gmm_Anomaly_RenderGlitch"

if SERVER then
    util.AddNetworkString(NetRenderGlitch)
end

local GlitchMinStrength = 0.5
local GlitchMaxStrength = 1.5

local GlitchDurationWeights = {
    { Weight = 70, Min = 0.8,  Max = 1.3  },
    { Weight = 18, Min = 4.5,  Max = 5.5  },
    { Weight = 9,  Min = 9.0,  Max = 11.0 },
    { Weight = 3,  Min = 28.0, Max = 32.0 } 
}

local function PickGlitchDuration()
    local Total = 0
    for i = 1, #GlitchDurationWeights do
        Total = Total + GlitchDurationWeights[i].Weight
    end

    local Roll = math.Rand(0, Total)
    for i = 1, #GlitchDurationWeights do
        local Entry = GlitchDurationWeights[i]
        Roll = Roll - Entry.Weight
        if Roll <= 0 then
            return math.Rand(Entry.Min, Entry.Max)
        end
    end

    return 1.0
end

local function PickGlitchOrigin()
    local AllPlayers   = player.GetAll()
    local AlivePlayers = {}

    for i = 1, #AllPlayers do
        local Ply = AllPlayers[i]
        if IsValid(Ply) and Ply:Alive() then
            AlivePlayers[#AlivePlayers + 1] = Ply
        end
    end

    if #AlivePlayers > 0 then
        local Picked = AlivePlayers[math.random(1, #AlivePlayers)]
        return Picked:EyePos()
    elseif #AllPlayers > 0 and IsValid(AllPlayers[1]) then
        return AllPlayers[1]:EyePos()
    end

    return Vector(0, 0, 0)
end

GMM_S.Anomaly.RenderGlitch = function()
    local StartTime = CurTime()
    local Duration  = PickGlitchDuration()
    local Strength  = math.Rand(GlitchMinStrength, GlitchMaxStrength)
    local Seed      = math.random(1, 2147483647)
    local Origin    = PickGlitchOrigin()

    net.Start(NetRenderGlitch)
    net.WriteBool(true)
    net.WriteFloat(StartTime)
    net.WriteFloat(Duration)
    net.WriteFloat(Strength)
    net.WriteUInt(Seed, 31)
    net.WriteVector(Origin)
    net.Broadcast()
end