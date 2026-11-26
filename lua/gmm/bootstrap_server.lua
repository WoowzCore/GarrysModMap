GMM_S = {
    Func = {}
}

include("gmm/data/anomaly_sounds.lua")
include("gmm/data/anomaly_spawn.lua")

include("gmm/server/doors.lua")
include("gmm/server/props.lua")
include("gmm/server/entity_schedule.lua")

local Start = function()
    if GMM.Valid then
        print("[GMM] SERVER LOADED")

        local MapKey = GMM.Func.GetMapKeyOrNil()
        if MapKey ~= nil then
            print("[GMM] Map: " .. MapKey)
        else
            print("[GMM] Map: GMM не учитывает эту карту (" .. GMM.CurrentMap .. ")!")
        end
    end

    include("gmm/server/network.lua")
    include("gmm/server/commands.lua")
    include("gmm/server/anomalies.lua")

    -- ----------------------------------------------------------------------

    local PostCleanup = function()
        print("[GMM] SERVER CLEANUP")

        GMM_S.DetectMapEntities()
    end

    hook.Add("PostCleanupMap", "gmm_PostCleanupMap_Server", PostCleanup)
    PostCleanup()

    -- ----------------------------------------------------------------------

    if GMM.Maps.SToilet then
        include("gmm/server/toiletmap.lua")
    end

    -- ----------------------------------------------------------------------

    include("gmm/server/anomaly_core.lua")
    include("gmm/server/network_anomaly.lua")
end

hook.Add("InitPostEntity", "gmm_MapLoad", function()
	if GMM_S__Started then return end GMM_S__Started = true
    Start()
end)
if GMM_S__Started then
    Start()
end