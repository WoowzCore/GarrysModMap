concommand.Add("gmm_nav_load", function(Player, CMD, Args)
    if IsValid(Player) and not Player:IsSuperAdmin() then return end

    local Distance = tonumber(Args[1]) or -1

    net.Start("gmm_RequestSyncNav")
        net.WriteFloat(Distance)
    net.Send(Player)
end)

util.AddNetworkString("gmm_CoreReset")
concommand.Add("gmm_core_reset", function(Player, CMD, Args)
    if not IsValid(Player) then return end
    if not Player:IsSuperAdmin() then return end

    net.Start("gmm_CoreReset")
    net.Send(Player)
end)