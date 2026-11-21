GMM_S.Anomaly = {}

GMM_S.Anomaly.List = {
    {1, function() return GMM_S.Anomaly.Shake end},
    {1, function() return GMM_S.Anomaly.PlaySound end},
    {1, function() return GMM_S.Anomaly.Interact end},
    {1, function() return GMM_S.Anomaly.SpawnEntity end}
}

GMM_S.Anomaly.GetRandom = function()
    local TotalWeight = 0
    for _, A in ipairs(GMM_S.Anomaly.List) do
        TotalWeight = TotalWeight + A[1]
    end

    local RandomChoice = math.random(1, TotalWeight)
    local CurrentWeight = 0

    for _, A in ipairs(GMM_S.Anomaly.List) do
        CurrentWeight = CurrentWeight + A[1]
        if RandomChoice <= CurrentWeight then
            return A[2]()
        end
    end
    
    return nil
end

-- ----------------------------------------------------------------------

GMM_S.Anomaly.Shake = function()
    local Props = GMM_S.Func.GetPhysicsProps()

    if #Props == 0 then return end

    for _, Prop in ipairs(Props) do
        if math.random() > 0.99 then
            GMM_S.Func.ShakeProp(Prop, (math.random() > 0.9 and 10000000 or 10000) * math.random())
        end
    end
end

GMM_S.Anomaly.PlaySound = function()
    local Pool
    if math.random() < 0.1 then
        Pool = GMM.Data.AnomalySounds.Rare
    else
        Pool = GMM.Data.AnomalySounds.Common
    end

    local SoundPath = Pool[math.random(1, #Pool)]

    for _, Player in ipairs(player.GetAll()) do
        if IsValid(Player) then
            Player:EmitSound(SoundPath, 100, math.random(50, 150), math.random() * math.random(), CHAN_AUTO)

            local TargetPly = Player
            local TargetSound = SoundPath
            timer.Simple(60, function()
                if IsValid(TargetPly) then
                    TargetPly:StopSound(TargetSound)
                end
            end)
        end
    end
end

GMM_S.Anomaly.Interact = function()
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

    local Found = {}
    for _, Class in ipairs(InteractClasses) do
        local EntsByClass = ents.FindByClass(Class)
        for _, Entity in ipairs(EntsByClass) do
            local Skip = false

            if Entity:GetClass():find("door") then
                if GMM_S.Func.CanOpenDoor then
                    if not GMM_S.Func.CanOpenDoor(Entity) then
                        Skip = true
                    end
                else
                    local Flags = Entity:GetInternalVariable("m_spawnflags")
                    if Flags and (bit.band(Flags, 2048) ~= 0 or bit.band(Flags, 32) ~= 0 or bit.band(Flags, 512) ~= 0) then
                        Skip = true
                    end
                end
            end

            if not Skip then
                table.insert(Found, Entity)
            end
        end
    end

    if #Found == 0 then return end

    local Random = Found[math.random(1, #Found)]

    if IsValid(Random) then
        Random:Fire("Use")
    end
end

GMM_S.Anomaly.SpawnEntity = function()
    local Players = player.GetAll()
    if #Players == 0 then return end
    local TargetPlayer = Players[math.random(#Players)]
    if not IsValid(TargetPlayer) then return end

    local SpawnPosition = nil

    for i = 1, 10 do
        local RandomOffset = Vector(math.random(-1500, 1500), math.random(-1500, 1500), math.random(-1500, 1500))
        local ChestPosition = TargetPlayer:GetPos() + RandomOffset

        local Trace = util.TraceLine({
            start = ChestPosition,
            endpos = ChestPosition - Vector(0, 0, 1000),
            mask = MASK_SOLID_BRUSHONLY
        })

        if Trace.Hit and not Trace.HitSky then
            local PotentialPosition = Trace.HitPos + Vector(0, 0, 20)

            local TooClose = false
            for _, Ply in ipairs(Players) do
                if Ply:GetPos():Distance(PotentialPosition) < 600 then
                    TooClose = true
                    break
                end
            end

            if not TooClose then
                local CheckEnts = ents.FindInSphere(PotentialPosition, 30)
                if #CheckEnts == 0 then
                    SpawnPosition = PotentialPosition
                    break
                end
            end
        end
    end

    if not SpawnPosition then return end

    local Pool = (math.random() > 0.95) and GMM.Data.AnomalySpawn.Rare or GMM.Data.AnomalySpawn.Common
    local Class = Pool[math.random(#Pool)]

    local Model = Class == "prop_physics" and GMM.Data.AnomalySpawn.Models[math.random(#GMM.Data.AnomalySpawn.Models)] or ""

    local SpawnCount = 1
    if math.random() > 0.97 then
        SpawnCount = math.random(2, 20)
    end

    for i = 1, SpawnCount do
        local Angle__ = math.rad((i / SpawnCount) * 360)
        local Radius = (i == 1) and 0 or 60
        local Offset = Vector(math.cos(Angle__) * Radius, math.sin(Angle__) * Radius, 0)

        local Ent = ents.Create(Class)
        if not IsValid(Ent) then return end

        Ent:SetPos(SpawnPosition + Offset)
        Ent:SetAngles(Angle(0, math.random(0, 360), 0))

        if Class == "prop_physics" then
            Ent:SetModel(Model)

            local SkinCount = Ent:SkinCount()
            if SkinCount > 1 then
                Ent:SetSkin(math.random(0, SkinCount - 1))
            end
        end

        Ent.PhysgunDisabled = true

        Ent:Spawn()
        Ent:Activate()

        if Ent:IsNPC() then
            Ent:SetSchedule(SCHED_FORCED_GO_RUN)
        end
    end
end