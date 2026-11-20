do
    for EventName, Hooks in pairs(hook.GetTable()) do
        for HookName, _ in pairs(Hooks) do
            if type(HookName) == "string" and string.StartWith(HookName, "gmm_") then
                hook.Remove(EventName, HookName)
            end
        end
    end
end

-- ----------------------------------------------------------------------
    
GMM = {}
GMM.Func = {}

GMM.DoAnomalies = true
GMM.CustomDebug = GMM_DEBUG or false
GMM.CurrentMap = game.GetMap()

GMM.Func.ThatMap = function(Map) return GMM.CurrentMap == Map end
GMM.Maps = {
    Default = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_map_garry_game"),
    Flood   = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_flooded_water_blob"),
    Old     = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_old_alpha_beta"),
    Real    = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_real_rp_normal"),
    Dark    = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_dark_horror_night"),
    Goofy   = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_help_me"),
    Pavel   = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_pavel_pis_tv"),

    SToilet = GMM.Func.ThatMap("toiletmap")
}
GMM.Func.GetMapKeyOrNil = function()
    for Key, IsThisMap in pairs(GMM.Maps) do
        if IsThisMap then return Key end
    end
    return nil
end

GMM.Valid = (string.match(GMM.CurrentMap, "^gmm_") ~= nil) or GMM.Maps.SToilet

-- ----------------------------------------------------------------------

if GMM.Maps.Real then GMM.DoAnomalies = false end

-- ----------------------------------------------------------------------

Woowz11 = "STEAM_0:0:158204257"

ErrorPosition = Vector(-100000, -100000, -100000)

if SERVER then
    AddCSLuaFile("gmm/bootstrap_client.lua")

    for _, ScriptName in ipairs(file.Find("gmm/client/*.lua", "LUA")) do
        AddCSLuaFile("gmm/client/" .. ScriptName)
    end

    AddCSLuaFile("gmm/data/map_assets.lua")
    
    include("gmm/bootstrap_server.lua")
end

if CLIENT then
    include("gmm/bootstrap_client.lua")
end