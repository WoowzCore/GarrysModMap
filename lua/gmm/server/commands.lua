concommand.Add("gmm_anomaly", function(Player, CMD, Args)
    if IsValid(Player) and not Player:IsAdmin() then return end

    print("[GMM] Fire anomaly!")
    GMM.Func.FireAnomaly()
end)

concommand.Add("gmm_nav_load", function(Player, CMD, Args)
    if IsValid(Player) and not Player:IsSuperAdmin() then return end

    local Distance = tonumber(Args[1]) or -1

    net.Start("gmm_RequestSyncNav")
        net.WriteFloat(Distance)
    net.Send(Player)
end)

net.Receive("gmm_SyncNav", function(L, Player)
    if not Player:IsSuperAdmin() then return end

    local NavData = net.ReadTable()

    navmesh.ClearWalkableSeeds()

    local Count = 0
    for _, Data in ipairs(NavData) do
        local Position = Data[1]
        if Position then
            navmesh.AddWalkableSeed(Position, Vector(0, 0, 1))
            Count = Count + 1
        end
    end

    print("[GMM] Loaded " .. Count .. " nav points!")
end)