local MapMin = Vector(-1500, -9000, -70)
local MapMax = Vector( 9000,  2000,  500)

local ToiletCount  = 50
local SpawnDelay   = 0.1
local FindAttempts = 30

local Lift     = Vector(0, 0, 5)
local HullMins = Vector(-8, -8, 0)
local HullMaxs = Vector( 8,  8, 65)

local function GetNavPos(Areas)
    local Area = Areas[math.random(#Areas)]
    return Area:GetRandomPoint() + Lift
end

local function GetTracePos()
    local X = math.Rand(MapMin.x, MapMax.x)
    local Y = math.Rand(MapMin.y, MapMax.y)

    local Tr = util.TraceLine({
        start  = Vector(X, Y, MapMax.z),
        endpos = Vector(X, Y, MapMin.z - 100),
        mask   = MASK_SOLID_BRUSHONLY
    })

    if not Tr.Hit or Tr.HitSky or Tr.StartSolid then return nil end

    return Tr.HitPos + Lift
end

local function IsFree(Pos)
    if not util.IsInWorld(Pos) then return false end

    local Tr = util.TraceHull({
        start  = Pos,
        endpos = Pos,
        mins   = HullMins,
        maxs   = HullMaxs,
        mask   = MASK_NPCSOLID
    })

    return not Tr.StartSolid
end

local function FindPos(Areas)
    local HasNav = #Areas > 0

    for i = 1, FindAttempts do
        local Pos = nil

        if HasNav then
            Pos = GetNavPos(Areas)
        else
            Pos = GetTracePos()
        end

        if Pos and IsFree(Pos) then return Pos end
    end

    return nil
end

local function SpawnToiletMan(Areas)
    local Pos = FindPos(Areas)
    if not Pos then return end

    local Ent = ents.Create("gmm_toiletman")
    if not IsValid(Ent) then return end

    Ent:SetPos(Pos)
    Ent:SetAngles(Angle(0, math.random(0, 360), 0))
    Ent:Spawn()
end

timer.Simple(2, function()
    local Missing = ToiletCount - #ents.FindByClass("gmm_toiletman")
    if Missing <= 0 then return end

    local Areas = navmesh.GetAllNavAreas()

    timer.Create("gmm_ToiletSpawn", SpawnDelay, Missing, function()
        SpawnToiletMan(Areas)
    end)
end)