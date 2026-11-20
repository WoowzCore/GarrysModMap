local MapMin = Vector(-1500, -9000, -70)
local MapMax = Vector( 9000,  2000,  500)

local SpawnToiletManAtRandomPos = function()
    for OuterAttempt = 1, 5 do

        for Attempt = 1, 20 do
            local RandomPos = Vector(
                    math.random(MapMin.x, MapMax.x),
                    math.random(MapMin.y, MapMax.y),
                    math.random(500, 3000)
            )

            local Tr = util.TraceLine({
                start  = RandomPos,
                endpos = RandomPos - Vector(0, 0, 6000),
                mask   = MASK_SOLID_BRUSHONLY
            })

            if Tr.Hit and not Tr.HitSky then
                local SpawnPos = Tr.HitPos + Vector(0, 0, 5)

                local HullTr = util.TraceHull({
                    start  = SpawnPos,
                    endpos = SpawnPos,
                    mins   = Vector(-8, -8, 0),
                    maxs   = Vector(8, 8, 65),
                    mask   = MASK_NPCSOLID
                })

                if not HullTr.StartSolid and util.IsInWorld(SpawnPos) then
                    local Ent = ents.Create("gmm_toiletman")
                    if IsValid(Ent) then
                        Ent:SetPos(SpawnPos)
                        Ent:SetAngles(Angle(0, math.random(0, 360), 0))
                        Ent:Spawn()
                        Ent:Activate()

                        return Ent
                    end
                end
            end
        end

    end

    return nil
end

timer.Simple(2, function()
    for i = 1, 200 do
        local Ent = SpawnToiletManAtRandomPos()
    end
end)