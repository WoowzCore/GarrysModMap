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

GMM.CustomDebug = GMM_DEBUG or false
GMM.CurrentMap = game.GetMap()

GMM.Func.ThatMap = function(Map) return GMM.CurrentMap == Map end

--[[
# Версии карт которые я хочу сделать.

* [ ] повторяющиеся комнаты
* [X] Старая версия
* [ ] Версия покрытая снегом и замёршая
* [ ] Горящая версия
* [X] Хоррор версия без света
* [X] Глючная упоротая версия?
* [ ] Реалистичная рп версия
* [ ] Солнечная версия, куча неба 
* [ ] Брутализм версия (всё из бетона)
* [ ] бекрумс версия, всё будет в обоях
* [ ] Пещерная версия, везде будут пещеры и скалы
* [ ] Пустынная версия?
* [ ] TOILETMAP версия
* [ ] увеличенная в масштабе версия?
* [ ] Пустая версия, чистые комнаты без декора
* [ ] средневековая версия?
* [ ] Особняк версия, всё богато
* [ ] WoowzCore версия, с столбами персонажами и т.д
* [ ] Литуимская версия, всё в микросхемах и т.д.
]]

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

GMM.Func.DoAnomalies = function()
    local Mode = GMM.ConVars.GetInt("anomalies")

    if Mode == 2 then return true end
    if Mode ~= 1 then return false end

    if not GMM.Valid then return false end
    if GMM.Maps.Real then return false end

    return true
end

-- ----------------------------------------------------------------------

Woowz11 = "STEAM_0:0:158204257"

ErrorPosition = Vector(-100000, -100000, -100000)

-- ----------------------------------------------------------------------

include("gmm/shared/convars.lua")
include("gmm/shared/playermodels.lua")

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