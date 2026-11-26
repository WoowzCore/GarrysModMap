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
* [ ] Frutigier aero версия
* [ ] Пляжная версия
* [ ] Гнилая, полная трупов, расчленёнки и крови версия, postal отсылка, ржавый металл
* [ ] Китайский бекрумс версия
* [ ] Арбузная версия, всё в арбузах, вся карта арбуз
* [ ] Мясная версия, карта из мяса, карта живая
* [ ] Заставить кого-то по памяти построить мою gmm карту
]]

GMM.Maps = {
    Default = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_map_garry_game"),
    Flood   = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_flooded_water_blob"),
    Old     = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_old_alpha_beta"),
    Real    = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_real_rp_normal"),
    Dark    = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_dark_horror_night"),
    Goofy   = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_help_me"),
    Pavel   = GMM.Func.ThatMap("gmm_garrymod_map_by_woowz_pavel_pis_tv"),
    f5099cd = GMM.Func.ThatMap("gmm_garrymod_0_f5099cd"),

    SToilet = GMM.Func.ThatMap("toiletmap")
}
GMM.Func.GetMapKeyOrNil = function()
    for Key, IsThisMap in pairs(GMM.Maps) do
        if IsThisMap then return Key end
    end
    return nil
end

GMM.Valid = (string.match(GMM.CurrentMap, "^gmm_") ~= nil) or GMM.Maps.SToilet

GMM.NoValidExtra = function()
    return not GMM.Valid or GMM.Maps.Real or GMM.Maps.f5099cd
end

GMM.Func.DoAnomalies = function()
    local Mode = GMM.ConVars.GetInt("anomalies")

    if Mode == 2 then return true end
    if Mode ~= 1 then return false end

    if GMM.NoValidExtra() then return false end

    return true
end

GMM.Func.DoEntitiesUnlock = function()
    return GMM.Valid or GMM.ConVars.GetBool("entities_unlock")
end

GMM.Func.DoVoid = function()
    local Mode = GMM.ConVars.GetInt("void")

    if Mode == 2 then return true end
    if Mode ~= 1 then return false end

    if GMM.NoValidExtra() then return false end

    return true
end

GMM.ExtraIDs = {
    HelpMe = "3776326993",
}

GMM.ExtraNames = {
    HelpMe = {"goofy"},
}

local function NormalizeName(Text)
    return string.lower(string.Trim(tostring(Text or "")))
end

local function GetWorkshopAddons()
    local Ok, Addons = pcall(engine.GetAddons)

    if not Ok then
        print("[GMM] ADDON LIST FAILED! ERROR: " .. tostring(Addons))
        return {}
    end

    return Addons
end

local function GetLocalNames()
    local Names       = {}
    local _, Folders  = file.Find("addons/*", "GAME")

    for i = 1, #Folders do
        local Folder = Folders[i]

        Names[NormalizeName(Folder)] = true

        local Json = file.Read("addons/" .. Folder .. "/addon.json", "GAME")

        if Json ~= nil then
            local Data = util.JSONToTable(Json)

            if Data ~= nil and Data.title ~= nil then Names[NormalizeName(Data.title)] = true end
        end
    end

    return Names
end

local function IsIdMounted(Id, Addons)
    if Id == nil or Id == "" or Id == "0" then return false end

    local Target = tostring(Id)

    for i = 1, #Addons do
        local Addon = Addons[i]

        if tostring(Addon.wsid) == Target and Addon.mounted then return true end
    end

    return false
end

local function IsNameMounted(Name, Addons, LocalNames)
    local Target = NormalizeName(Name)

    if Target == "" then return false end
    if LocalNames[Target] then return true end

    for i = 1, #Addons do
        local Addon = Addons[i]

        if Addon.mounted and NormalizeName(Addon.title) == Target then return true end
    end

    return false
end

GMM.Func.IsExtraLoaded = function(Id, Names)
    local Addons = GetWorkshopAddons()

    if IsIdMounted(Id, Addons) then return true end
    if Names == nil or #Names == 0 then return false end

    local LocalNames = GetLocalNames()

    for i = 1, #Names do
        if IsNameMounted(Names[i], Addons, LocalNames) then return true end
    end

    return false
end

GMM.Extra = {
    HelpMe = GMM.Func.IsExtraLoaded("3776326993", {"goofy"})
}

-- ----------------------------------------------------------------------

Woowz11 = "STEAM_0:0:158204257"

ErrorPosition = Vector(-100000, -100000, -100000)

-- ----------------------------------------------------------------------

local function IncludeBoth(ScriptName)
    if SERVER then AddCSLuaFile(ScriptName) end
    include(ScriptName)
end

IncludeBoth("gmm/shared/convars.lua")
IncludeBoth("gmm/shared/playermodels.lua")
IncludeBoth("gmm/shared/graphic_zones.lua")

if GMM.Maps.f5099cd then
    IncludeBoth("gmm/server/f5099cd.lua")
end

if SERVER then
    for _, ScriptName in ipairs(file.Find("gmm/client/*.lua", "LUA")) do
        AddCSLuaFile("gmm/client/" .. ScriptName)
    end

    AddCSLuaFile("gmm/data/map_assets.lua")

	AddCSLuaFile("gmm/bootstrap_client.lua")
    include("gmm/bootstrap_server.lua")
end

if CLIENT then
    include("gmm/bootstrap_client.lua")
end

IncludeBoth("gmm/shared/other.lua")