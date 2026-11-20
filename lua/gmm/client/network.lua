GMM_C.Data = {}

timer.Create("gmm_GetServerData", 0.1, 0, function()
    net.Start("gmm_Get_ServerData")
    net.SendToServer()
end)

net.Receive("gmm_Send_ServerData", function()
    GMM_C.Data = net.ReadTable()
end)

-- ----------------------------------------------------------------------

net.Receive("gmm_RequestSyncNav", function()
    local MaxDistance = net.ReadFloat()
    local Result = {}
    local PlayerPosition = Player:GetPos()

    if MaxDistance > 0 then
        for _, Data in ipairs(GMM_C.Environment.Nav) do
            local Position = Data[1]
            if Position and Position:Distance(PlayerPosition) <= MaxDistance then
                table.insert(Result, Data)
            end
        end

        print("[GMM] Send " .. #Result .. " nav points! (in radius " .. MaxDistance .. ")")
    else
        Result = GMM_C.Environment.Nav
        print("[GMM] Send " .. #Result .. " nav points!")
    end

    if #Result == 0 then return end

    net.Start("gmm_SyncNav")
    net.WriteTable(Result)
    net.SendToServer()
end)