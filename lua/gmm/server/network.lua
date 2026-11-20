GMM_S.Clients = {}

GMM_S.Data = {
    Positions = {}
}

util.AddNetworkString("gmm_Get_ServerData" )
util.AddNetworkString("gmm_Send_ServerData")

net.Receive("gmm_Get_ServerData", function(L, Player)
    net.Start("gmm_Send_ServerData")
    net.WriteTable(GMM_S.Data)
    net.Send(Player)
end)

-- ----------------------------------------------------------------------

util.AddNetworkString("gmm_ClientInfo")
util.AddNetworkString("gmm_SyncNav")
util.AddNetworkString("gmm_RequestSyncNav")

net.Receive("gmm_ClientInfo", function(L, Player)
    GMM_S.Clients[Player] = net.ReadTable()
end)

-- ----------------------------------------------------------------------

GMM_S.DetectMapEntities = function()
    local MapEntities = {}
    for _, Entity in ipairs(ents.GetAll()) do
        if IsValid(Entity) then
            local Name = Entity:GetName()
            if Name ~= "" then
                MapEntities[Name] = Entity
            end
        end
    end

    -- ----------------------------------------------------------------------

    if GMM.Maps.Default or GMM.Maps.Flood or GMM.Maps.Old then
        local __PROP_CASE = MapEntities["PROP_CASE"  ]
        local __SPEAKER   = MapEntities["SPEAKER"    ]
        local __TURTLE    = MapEntities["PROP_TURTLE"]

        local ReportEntity = function(Entity, ID)
            if IsValid(Entity) then
                GMM_S.Data["Positions"][ID] = Entity:GetPos()
            else
                GMM_S.Data["Positions"][ID] = ErrorPosition
            end
        end

        hook.Add("Think", "gmm_MapThink", function()
            ReportEntity(__PROP_CASE, 0)
            ReportEntity(__SPEAKER  , 1)
            ReportEntity(__TURTLE   , 2)
        end)

    end
end