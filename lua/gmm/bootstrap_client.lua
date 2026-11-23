GMM_C = {
    Func = {},
    
	Debug = nil
}

list.Set("ContentCategoryIcons", "GMM", "icons16/gmm_category")

include("gmm/data/map_assets.lua")

include("gmm/client/utilities.lua")
include("gmm/client/utilities_core.lua")

GMM_C.Func.VoidPower = function()
    local Power = GMM.ConVars.GetFloat("void_power")
    if GMM.Maps.Goofy then return math.max(1, Power) end
    return Power
end

local Start = function()
    if GMM.Valid then
        print("[GMM] CLIENT LOADED")
    end

    GMM_C.Debug = (true and (LocalPlayer():SteamID() == Woowz11)) or GMM.CustomDebug
    
    if GMM_C.Debug then print("[GMM] DEBUG VERSION") end

    -- ----------------------------------------------------------------------

    GMM_C.CameraPosition = Vector(0, 0, 0)

    GMM_C.Player = nil

    -- ----------------------------------------------------------------------

    include("gmm/client/network.lua")
    include("gmm/client/environment.lua")
    include("gmm/client/particle.lua")
    include("gmm/client/debug.lua")
    include("gmm/client/graphic.lua")
    include("gmm/client/void.lua")

    -- ----------------------------------------------------------------------
    
    local PostCleanup = function()
        if GMM.Valid then
            print("[GMM] CLIENT CLEANUP")
        end

        GMM_C.Environment.Create()
    end
    hook.Add("PostCleanupMap", "gmm_PostCleanupMap_Client", PostCleanup)
    PostCleanup()

    -- ----------------------------------------------------------------------

    include("gmm/client/think.lua")
end

-- ----------------------------------------------------------------------

hook.Add("InitPostEntity", "gmm_PlayerLoad", function()
    if GMM_C__Started then return end GMM_C__Started = true
    Start()
end)
if GMM_C__Started then
    Start()
end