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